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
    Task { @MainActor in
        _startKeyboardObserverMain()
    }
}

@_cdecl("stop_keyboard_observer")
public func stop_keyboard_observer() {
    Task { @MainActor in
        _stopKeyboardObserverMain()
    }
}

@MainActor
private func _startKeyboardObserverMain() {
    if let observer = keyboardObserver {
        NotificationCenter.default.removeObserver(observer)
        keyboardObserver = nil
    }

    keyboardObserver = NotificationCenter.default.addObserver(
        forName: UIResponder.keyboardWillChangeFrameNotification,
        object: nil,
        queue: .main
    ) { note in
        guard
            let frameValue = note.userInfo?[
                UIResponder.keyboardFrameEndUserInfoKey
            ] as? NSValue
        else { return }
        let frame = frameValue.cgRectValue
        let screenHeight = UIScreen.main.bounds.height
        let animationDuration =
            (note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
            as? NSNumber)?
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
        displayLink = nil
        animationLayer?.removeAllAnimations()
        animationLayer?.removeFromSuperlayer()
        animationLayer = nil
        settleWorkItem?.cancel()
        settleWorkItem = nil

        let layer = CALayer()
        layer.position = .zero

        if let window = currentWindow() {
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
            selector: #selector(DisplayLinkProxy.tick(_:))
        )

        let maxFPS: Int
        if #available(iOS 15.0, *) {
            maxFPS = UIScreen.main.maximumFramesPerSecond
        } else {
            maxFPS = 60
        }
        displayLink?.preferredFramesPerSecond = maxFPS
        displayLink?.add(to: .main, forMode: .common)

        let workItem = DispatchWorkItem { [weak layer] in
            currentInset = Float(targetInset)
            platform_update_inset(currentInset, Float(targetInset))
            displayLink?.invalidate()
            displayLink = nil
            layer?.removeFromSuperlayer()
            animationLayer = nil
            settleWorkItem = nil
        }
        settleWorkItem = workItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + animationDuration,
            execute: workItem
        )
    }
}

@MainActor
private func _stopKeyboardObserverMain() {
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

@MainActor
func currentWindow() -> UIWindow? {
    let scene = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .first { $0.activationState == .foregroundActive }

    guard let windowScene = scene else {
        return nil
    }

    if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
        return keyWindow
    }

    return windowScene.windows.first {
        $0.windowLevel == .normal && !$0.isHidden && $0.alpha > 0
    }
}

private class DisplayLinkProxy {
    static let shared = DisplayLinkProxy()

    @objc func tick(_ link: CADisplayLink) {
        guard let animLayer = animationLayer,
            let pres = animLayer.presentation(),
            let tNumber = pres.value(forKeyPath: "position.y") as? NSNumber
        else {
            return
        }

        let t = CGFloat(truncating: tNumber)
        let interpolated = startInset + (targetInset - startInset) * t
        currentInset = Float(interpolated)
        platform_update_inset(Float(currentInset), Float(targetInset))
    }
}

@_cdecl("start_safe_area_observer")
public func start_safe_area_observer() {
    Task { @MainActor in
        _startSafeAreaObserverMain()
    }
}

@_cdecl("stop_safe_area_observer")
public func stop_safe_area_observer() {
    Task { @MainActor in
        _stopSafeAreaObserverMain()
    }
}

@MainActor
private func _startSafeAreaObserverMain() {
    guard
        let window = currentWindow()
    else {
        return
    }

    // Remove previous monitor (if any)
    safeAreaMonitor?.removeFromSuperview()
    safeAreaMonitor = nil

    // Create and attach monitor view
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
    DispatchQueue.main.async {
        updateSafeArea(window.safeAreaInsets.bottom)
    }
}

@MainActor
private func _stopSafeAreaObserverMain() {
    safeAreaMonitor?.removeFromSuperview()
    safeAreaMonitor = nil
}

@_cdecl("updateSafeArea")
public func updateSafeArea(_ newInset: CGFloat) {
    lastSafeAreaBottom = newInset
    platform_update_safe_area(Float(newInset))
}

@MainActor
final class SafeAreaMonitorView: UIView {

    /// Callback triggered when the bottom safe area inset changes.
    var onSafeAreaChange: ((CGFloat) -> Void)?

    /// Cache the last reported inset to avoid duplicate updates.
    private var lastReportedInset: CGFloat = -1
    private var orientationObserver: NSObjectProtocol?
    private var statusBarObserver: NSObjectProtocol?

    override func didMoveToWindow() {
        assert(Thread.isMainThread)
        super.didMoveToWindow()

        // Recalculate when attached to a new window
        updateSafeAreaIfNeeded()
        registerForOrientationChanges()
    }

    override func removeFromSuperview() {
        assert(Thread.isMainThread)
        unregisterForOrientationChanges()
        super.removeFromSuperview()
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
        let nc = NotificationCenter.default
        orientationObserver = nc.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleOrientationChange()
        }

        statusBarObserver = nc.addObserver(
            forName: UIApplication.didChangeStatusBarFrameNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleOrientationChange()
        }
    }

    private func unregisterForOrientationChanges() {
        let nc = NotificationCenter.default
        if let t = orientationObserver {
            nc.removeObserver(t)
            orientationObserver = nil
        }
        if let t = statusBarObserver {
            nc.removeObserver(t)
            statusBarObserver = nil
        }
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

        if abs(newInset - lastReportedInset) > 0.5 { /// Threshold to avoid noise
            lastReportedInset = newInset
            onSafeAreaChange?(newInset)
        }
    }
}
