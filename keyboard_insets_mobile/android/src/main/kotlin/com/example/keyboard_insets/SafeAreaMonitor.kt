package com.example.keyboard_insets

import android.app.Activity
import android.os.Build
import android.view.View
import androidx.annotation.Keep
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsCompat.Type

// Native bridge callback into the C core
private external fun platform_update_safe_area(inset: Float)

/**
 * Observes bottom system gesture or navigation bar insets.
 *
 * The value remains constant when the keyboard appears or hides,
 * and updates only when the actual safe area changes (e.g., rotation or gesture mode toggle).
 */
@Keep
object SafeAreaMonitor {
    private const val TAG = "SafeAreaMonitor"

    private var activity: Activity? = null
    private var rootView: View? = null
    private var lastInsetPx: Int = -1

    fun setActivity(act: Activity?) {
        activity = act
    }

    @Keep
    @JvmStatic
    fun startSafeAreaObserver() {
        val act = activity ?: run {
            return
        }
        val view = act.window?.decorView ?: run {
            return
        }

        rootView = view

        // Initial read
        val initialInsets = ViewCompat.getRootWindowInsets(view)
        pushSafeAreaInset(initialInsets)

        // Listen for changes
        ViewCompat.setOnApplyWindowInsetsListener(view) { _, insets ->
            pushSafeAreaInset(insets)
            insets
        }
    }

    @Keep
    @JvmStatic
    fun stopSafeAreaObserver() {
        rootView?.let {
            ViewCompat.setOnApplyWindowInsetsListener(it, null)
        }
        rootView = null
    }

    private fun pushSafeAreaInset(insets: WindowInsetsCompat?) {
        if (insets == null) return
        val act = activity ?: return

        // Get bottom system gesture or navigation bar inset
        val bottomInsetPx = when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q -> {
                // Use systemGestureInsets for gesture navigation
                insets.getInsets(Type.systemGestures()).bottom
                    .coerceAtLeast(insets.getInsets(Type.systemBars()).bottom)
            }
            else -> {
                insets.getInsets(Type.systemBars()).bottom
            }
        }

        if (bottomInsetPx == lastInsetPx) return
        lastInsetPx = bottomInsetPx

        val density = act.resources.displayMetrics.density
        val insetDp = bottomInsetPx / density
        platform_update_safe_area(insetDp)
    }
}
