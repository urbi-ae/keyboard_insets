package com.example.keyboard_insets

import android.app.Activity
import androidx.annotation.Keep
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsAnimationCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsCompat.Type

// Native callback (into C)
private external fun platform_update_inset(inset: Float, target: Float)

object KeyboardInsets {
    private var activity: Activity? = null
    private var rootView: android.view.View? = null
    private var targetInsetDp: Float = 0f
    private var isKeyboardAnimationEnabled: Boolean = true

    fun setActivity(act: Activity?) {
        activity = act
    }

    private val density: Float
        get() = activity?.resources?.displayMetrics?.density ?: 1f

    @Keep
    @JvmStatic
    fun setKeyboardAnimation(isEnabled: Boolean) {
        isKeyboardAnimationEnabled = isEnabled
    }

    @Keep
    @JvmStatic
    fun startKeyboardObserver() {
        rootView =
                activity?.window?.decorView
                        ?: run {
                            return
                        }
        val view = rootView!!

        // First immediate push
        val insets = ViewCompat.getRootWindowInsets(view)
        pushInset(insets)

        // Listen for changes
        ViewCompat.setOnApplyWindowInsetsListener(view) { _, newInsets ->
            pushInset(newInsets)
            newInsets
        }

        // Animation callback
        ViewCompat.setWindowInsetsAnimationCallback(
                view,
                object :
                        WindowInsetsAnimationCompat.Callback(
                                WindowInsetsAnimationCompat.Callback
                                        .DISPATCH_MODE_CONTINUE_ON_SUBTREE
                        ) {
                    override fun onStart(
                            animation: WindowInsetsAnimationCompat,
                            bounds: WindowInsetsAnimationCompat.BoundsCompat
                    ): WindowInsetsAnimationCompat.BoundsCompat {
                        targetInsetDp = bounds.upperBound.bottom / density
                        return bounds
                    }

                    override fun onProgress(
                            insets: WindowInsetsCompat,
                            runningAnimations: MutableList<WindowInsetsAnimationCompat>
                    ): WindowInsetsCompat {
                        if (isKeyboardAnimationEnabled) {
                            pushInset(insets)
                        }
                        return insets
                    }
                }
        )
    }

    @Keep
    @JvmStatic
    fun stopKeyboardObserver() {
        rootView?.let { view ->
            ViewCompat.setOnApplyWindowInsetsListener(view, null)
            ViewCompat.setWindowInsetsAnimationCallback(view, null)
        }
        rootView = null
    }

    private fun pushInset(insets: WindowInsetsCompat?) {
        val navBottom = insets?.getInsets(WindowInsetsCompat.Type.systemBars())?.bottom ?: 0

        val imeBottomPx = ((insets?.getInsets(Type.ime())?.bottom
                ?: 0) - navBottom).coerceAtLeast(0)
        val keyboardDp = imeBottomPx / density
        val target = (targetInsetDp - navBottom / density).coerceAtLeast(0f).toFloat()

        platform_update_inset(keyboardDp.toFloat(), target)
    }
}
