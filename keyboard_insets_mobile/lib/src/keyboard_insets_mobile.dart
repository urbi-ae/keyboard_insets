import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:keyboard_insets_mobile/bindings/keyboard_insets_bindings_generated.dart';
import 'package:keyboard_insets_platform_interface/keyboard_insets_platform_interface.dart';

part '../bindings/native_bindings.dart';

/// Mobile implementation of the KeyboardInsetsPlatform.
///
/// This implementation uses FFI to communicate with native code on iOS and Android.
class KeyboardInsetsMobile extends KeyboardInsetsPlatform {
  KeyboardInsetsMobile._();

  static void registerWith() {
    KeyboardInsetsPlatform.instance = KeyboardInsetsMobile._();
  }

  @override
  Stream<double> get insets => _insetStreamController.stream;

  @override
  Stream<KeyboardState> get stateStream => _stateStreamController.stream;

  @override
  double get keyboardHeight => _bindings.get_keyboard_height();

  @override
  bool get isVisible => _bindings.is_keyboard_visible();

  @override
  bool get isAnimating => _bindings.is_keyboard_animating();

  // ---- Internals ------------------------------------------------------------------------

  static NativeCallable<KeyboardInsetUpdateCallbackFunction>? _insetCallable;
  static final StreamController<double> _insetStreamController =
      StreamController<double>.broadcast(
    onListen: () {
      void onResponse(double height) {
        _insetStreamController.sink.add(height);
      }

      _insetCallable ??=
          NativeCallable<KeyboardInsetUpdateCallbackFunction>.listener(
              onResponse);
      _bindings.register_inset_callback(_insetCallable!.nativeFunction);
    },
    onCancel: () {
      _bindings.unregister_inset_callback();
      if (!_stateStreamController.hasListener) {
        _bindings.stop_listening_insets();
      } else {
        _bindings.set_keyboard_animation(false);
      }
      _insetCallable?.close();
      _insetCallable = null;
    },
  );

  static NativeCallable<KeyboardStateUpdateCallbackFunction>? _stateCallable;
  static final StreamController<KeyboardState> _stateStreamController =
      StreamController<KeyboardState>.broadcast(
    onListen: () {
      void onResponse(bool isVisible, bool isAnimating) {
        _stateStreamController.sink
            .add(KeyboardState(isVisible: isVisible, isAnimating: isAnimating));
      }

      if (!_insetStreamController.hasListener) {
        _bindings.set_keyboard_animation(false);
      }

      _stateCallable ??=
          NativeCallable<KeyboardStateUpdateCallbackFunction>.listener(
              onResponse);
      _bindings.register_state_callback(_stateCallable!.nativeFunction);
    },
    onCancel: () {
      _bindings.unregister_state_callback();
      if (!_insetStreamController.hasListener) {
        _bindings.stop_listening_insets();
      }

      _stateCallable?.close();
      _stateCallable = null;
    },
  );

  @override
  Stream<double> get safeAreaStream => _safeAreaStreamController.stream;

  static NativeCallable<SafeAreaInsetUpdateCallbackFunction>? _safeAreaCallable;
  static final StreamController<double> _safeAreaStreamController =
      StreamController<double>.broadcast(
    onListen: () {
      void onResponse(double inset) {
        _safeAreaStreamController.sink.add(inset);
      }

      _safeAreaCallable ??=
          NativeCallable<SafeAreaInsetUpdateCallbackFunction>.listener(
              onResponse);
      _bindings
          .register_safe_area_inset_callback(_safeAreaCallable!.nativeFunction);
    },
    onCancel: () {
      _bindings.unregister_safe_area_inset_callback();
      _safeAreaCallable?.close();
      _safeAreaCallable = null;
    },
  );
}
