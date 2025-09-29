import 'dart:async';

import 'package:keyboard_insets_platform_interface/src/keyboard_state.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

export 'src/keyboard_state.dart';

/// The common platform interface for keyboard_insets.
///
/// This class is used to define the API that all platform-specific
/// implementations must implement. Platform implementations should extend this
/// class rather than implement it as `implements` would not work correctly.
///
/// See:
/// https://pub.dev/packages/plugin_platform_interface#how-to-implement-a-plugin-platform-interface
abstract class KeyboardInsetsPlatform extends PlatformInterface {
  KeyboardInsetsPlatform() : super(token: _token);

  static final Object _token = Object();

  static KeyboardInsetsPlatform _instance = _DummyKeyboardInsets();

  /// The default instance of [KeyboardInsetsPlatform] to use.
  static KeyboardInsetsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// class that extends [KeyboardInsetsPlatform] when they register themselves.
  static set instance(KeyboardInsetsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Broadcast stream of the keyboard height changes.
  ///
  /// Emits the keyboard height in pixels on every animation frame
  /// while the keyboard is showing or hiding.
  ///
  /// If the keyboard is hidden, it emits `0.0`.
  ///
  /// ### Example:
  /// ```dart
  /// KeyboardInsets.insets.listen((height) {
  ///   print('Keyboard height: $height');
  /// });
  /// ```
  /// If there are no listeners, the native inset listening is stopped to save resources.
  /// When a listener is added, the native inset listening is started again.
  /// This is handled automatically by the stream.
  @mustBeOverridden
  Stream<double> get insets;

  /// Broadcast stream of the keyboard state changes.
  ///
  /// Emits a [KeyboardState] object whenever the keyboard visibility or animation state changes.
  ///
  /// ### Example:
  /// ```dart
  /// KeyboardInsets.stateStream.listen((state) {
  ///  print('Keyboard is visible: ${state.isVisible}, is animating: ${
  /// state.isAnimating}');
  /// });
  /// ```
  ///
  /// If there are no listeners, the native state listening is stopped to save resources.
  /// When a listener is added, the native state listening is started again.
  /// This is handled automatically by the stream.
  @mustBeOverridden
  Stream<KeyboardState> get stateStream;

  /// Get current keyboard height in pixels.
  ///
  /// For this value to be updated, you need to subscribe to any of the streams
  @mustBeOverridden
  double get keyboardHeight;

  /// Get current keyboard visibility.
  /// Returns `true` if the keyboard is visible, `false` otherwise.
  ///
  /// This is a synchronous call to the native code.
  ///
  /// ### Example:
  /// ```dart
  /// bool visible = KeyboardInsets.isVisible;
  /// print('Is keyboard visible: $visible');
  /// ```
  ///
  /// For this value to be updated, you need to subscribe to any of the streams
  @mustBeOverridden
  bool get isVisible;

  /// Get current keyboard animation status.
  /// Returns `true` if the keyboard is in the process of showing or hiding, `false` otherwise.
  ///
  /// ### Example:
  /// ```dart
  /// bool animating = KeyboardInsets.isAnimating;
  /// print('Is keyboard animating: $animating');
  /// ```
  ///
  /// For this value to be updated, you need to subscribe to any of the streams
  @mustBeOverridden
  bool get isAnimating;
}

/// Default dummy implementation of [KeyboardInsetsPlatform].
/// Returns default values and does not interact with any native code.
class _DummyKeyboardInsets extends KeyboardInsetsPlatform {
  @override
  Stream<double> get insets => Stream<double>.value(0.0);

  @override
  Stream<KeyboardState> get stateStream => Stream.value(
        const KeyboardState(isVisible: false, isAnimating: false),
      );

  @override
  double get keyboardHeight => 0.0;

  @override
  bool get isVisible => false;

  @override
  bool get isAnimating => false;
}
