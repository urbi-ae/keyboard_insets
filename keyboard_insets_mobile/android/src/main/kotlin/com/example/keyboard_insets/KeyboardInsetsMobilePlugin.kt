package com.example.keyboard_insets

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

class KeyboardInsetsMobilePlugin : FlutterPlugin, ActivityAware {
    companion object {
        init {
            System.loadLibrary("keyboard_insets_mobile")
        }

        @JvmStatic
        external fun nativeInit()
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        nativeInit()
    }

    // --- ActivityAware ---
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        KeyboardInsets.setActivity(binding.activity)
    }

    override fun onDetachedFromActivity() {
        KeyboardInsets.setActivity(null)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        KeyboardInsets.setActivity(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        KeyboardInsets.setActivity(binding.activity)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        KeyboardInsets.setActivity(null)
    }
}
