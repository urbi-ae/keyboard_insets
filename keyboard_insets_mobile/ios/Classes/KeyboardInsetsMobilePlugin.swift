import QuartzCore
import UIKit

private var keyboardObserver: NSObjectProtocol?
private var displayLink: CADisplayLink?
private var animationLayer: CALayer?
private var settleWorkItem: DispatchWorkItem?
private var startInset: CGFloat = 0
private var targetInset: CGFloat = 0
private var currentInset: Float = 0
private var isKeyboardAnimationEnabled: Bool = true

private let springDamping: CGFloat = 56.72061538696289
private let springMass: CGFloat = 1
private let springStiffness: CGFloat = 804.3070068359375
private let springInitialVelocity: CGFloat = 0

private var lastSafeAreaBottom: CGFloat = 0
private var safeAreaMonitor: SafeAreaMonitorView?

@_cdecl("simulate_keyboard_animation")
public func simulate_keyboard_animation(_ isEnabled: Bool) {
    isKeyboardAnimationEnabled = isEnabled
}

@_cdecl("start_keyboard_observer")
public func start_keyboard_observer() {
    if let observer = keyboardObserver {
        NotificationCenter.default.removeObserver(observer)
        keyboardObserver = nil
    }

    keyboardObserver = NotificationCenter.default.addObserver(
        forName: UIResponder.keyboardWillChangeFrameNotification,
        object: nil,
        queue: .main
    ) { note in
        guard let frameValue = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return }
        let frame = frameValue.cgRectValue
        let screenHeight = UIScreen.main.bounds.height
        let animationDuration =
            (note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?
            .doubleValue ?? 0.25

        startInset = CGFloat(currentInset)
        targetInset = max(0, screenHeight - frame.origin.y)

        if !isKeyboardAnimationEnabled {
            currentInset = Float(targetInset)
            platform_update_inset(Float(targetInset), Float(targetInset))
            return
        }

        // Cancel old animation + cleanup
        displayLink?.invalidate()
        animationLayer?.removeAllAnimations()
        animationLayer?.removeFromSuperlayer()
        displayLink = nil
        animationLayer = nil
        settleWorkItem?.cancel()

        let layer = CALayer()
        layer.position = .zero

        if let window = UIApplication.shared.windows.first {
            window.layer.addSublayer(layer)
        }

        let keyboardAnimation = CASpringAnimation(keyPath: "position.y")
        keyboardAnimation.fromValue = 0
        keyboardAnimation.toValue = 1
        keyboardAnimation.damping = springDamping
        keyboardAnimation.mass = springMass
        keyboardAnimation.stiffness = springStiffness
        keyboardAnimation.initialVelocity = springInitialVelocity
        keyboardAnimation.isRemovedOnCompletion = false
        keyboardAnimation.fillMode = .forwards
        layer.add(keyboardAnimation, forKey: "keyboardSpring")
        animationLayer = layer

        displayLink = CADisplayLink(
            target: DisplayLinkProxy.shared,
            selector: #selector(DisplayLinkProxy.tick))
        displayLink?.preferredFramesPerSecond = 120
        displayLink?.add(to: .main, forMode: .common)

        let workItem = DispatchWorkItem {
            currentInset = Float(targetInset)
            platform_update_inset(currentInset, Float(targetInset))
            displayLink?.invalidate()
            animationLayer?.removeFromSuperlayer()
            displayLink = nil
            animationLayer = nil
            settleWorkItem = nil
        }
        settleWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration, execute: workItem)
    }
}

private class DisplayLinkProxy {
    static let shared = DisplayLinkProxy()

    @objc func tick(link: CADisplayLink) {
        guard let animLayer = animationLayer,
            let pres = animLayer.presentation(),
            let t = pres.value(forKeyPath: "position.y") as? CGFloat
        else {
            return
        }

        let interpolated = startInset + (targetInset - startInset) * t
        currentInset = Float(interpolated)
        platform_update_inset(Float(currentInset), Float(targetInset))
    }
}

@_cdecl("stop_keyboard_observer")
public func stop_keyboard_observer() {
    if let observer = keyboardObserver {
        NotificationCenter.default.removeObserver(observer)
        keyboardObserver = nil
    }
    displayLink?.invalidate()
    displayLink = nil
    animationLayer?.removeAllAnimations()
    animationLayer?.removeFromSuperlayer()
    animationLayer = nil
    settleWorkItem?.cancel()
    settleWorkItem = nil
}

@_cdecl("start_safe_area_observer")
public func start_safe_area_observer() {
    DispatchQueue.main.async {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first(where: { $0.isKeyWindow })
        else { return }

        // Remove previous monitor if any
        safeAreaMonitor?.removeFromSuperview()

        // Create a hidden monitor view
        let monitor = SafeAreaMonitorView(frame: .zero)
        monitor.isUserInteractionEnabled = false
        monitor.backgroundColor = .clear
        monitor.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(monitor)

        NSLayoutConstraint.activate([
            monitor.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            monitor.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            monitor.topAnchor.constraint(equalTo: window.topAnchor),
            monitor.bottomAnchor.constraint(equalTo: window.bottomAnchor),
        ])

        monitor.onSafeAreaChange = { bottomInset in
            updateSafeArea(bottomInset)
        }

        safeAreaMonitor = monitor

        // Initial update
        updateSafeArea(window.safeAreaInsets.bottom)
    }
}

@_cdecl("stop_safe_area_observer")
public func stop_safe_area_observer() {
    DispatchQueue.main.async {
        safeAreaMonitor?.removeFromSuperview()
        safeAreaMonitor = nil
    }
}

@_cdecl("updateSafeArea")
public func updateSafeArea(_ newInset: CGFloat) {
    // guard abs(newInset - lastSafeAreaBottom) > 0.5 else { return }
    lastSafeAreaBottom = newInset
    platform_update_safe_area(Float(newInset))
}

/// A hidden view that observes changes to the window's safe area insets.
/// Used to track home indicator height or bottom safe area changes across orientation changes.
final class SafeAreaMonitorView: UIView {

    /// Callback triggered when the bottom safe area inset changes.
    var onSafeAreaChange: ((CGFloat) -> Void)?

    /// Cache the last reported inset to avoid duplicate updates.
    private var lastReportedInset: CGFloat = -1

    override func didMoveToWindow() {
        super.didMoveToWindow()

        // Recalculate when attached to a new window
        updateSafeAreaIfNeeded()
        registerForOrientationChanges()
    }

    override func removeFromSuperview() {
        super.removeFromSuperview()
        unregisterForOrientationChanges()
    }

    /// Called automatically whenever safe area insets change.
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        updateSafeAreaIfNeeded()
    }

    /// Handle device orientation or size class changes.
    @objc private func handleOrientationChange() {
        DispatchQueue.main.async { [weak self] in
            self?.updateSafeAreaIfNeeded()
        }
    }

    private func registerForOrientationChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOrientationChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOrientationChange),
            name: UIApplication.didChangeStatusBarFrameNotification,
            object: nil
        )
    }

    private func unregisterForOrientationChanges() {
        NotificationCenter.default.removeObserver(self)
    }

    /// Compare and send only when safe area bottom changes.
    private func updateSafeAreaIfNeeded() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.updateSafeAreaIfNeeded()
            }
            return
        }

        guard let window = self.window else { return }
        let newInset = window.safeAreaInsets.bottom

        if abs(newInset - lastReportedInset) > 0.5 {  // avoid tiny floating-point noise
            lastReportedInset = newInset
            onSafeAreaChange?(newInset)
        }
    }
}
