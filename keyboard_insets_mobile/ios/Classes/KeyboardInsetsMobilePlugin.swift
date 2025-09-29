import UIKit
import QuartzCore

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
        guard let frameValue = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let frame = frameValue.cgRectValue
        let screenHeight = UIScreen.main.bounds.height
        let animationDuration = (note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber )?.doubleValue ?? 0.25

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
        
        displayLink = CADisplayLink(target: DisplayLinkProxy.shared,
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
              let t = pres.value(forKeyPath: "position.y") as? CGFloat else {
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
