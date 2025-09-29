import 'dart:async';
import 'dart:html';
import 'package:keyboard_insets_platform_interface/keyboard_insets_platform_interface.dart';

/// Web implementation of [KeyboardInsetsPlatform].
///
/// Uses `window.visualViewport` to estimate keyboard height.
/// - On desktop browsers: always returns 0.
/// - On mobile browsers: returns `screenHeight - visualViewport.height`.
class KeyboardInsetsWeb extends KeyboardInsetsPlatform {
  final StreamController<double> _insetController =
      StreamController<double>.broadcast();
  final StreamController<KeyboardState> _stateController =
      StreamController<KeyboardState>.broadcast();

  bool _isAnimating = false;
  double _lastHeight = 0;

  KeyboardInsetsWeb() {
    window.visualViewport?.addEventListener('resize', _onResize);
    window.visualViewport?.addEventListener('scroll', _onResize);
  }

  static void registerWith(KeyboardInsetsPlatform registrar) {
    KeyboardInsetsPlatform.instance = KeyboardInsetsWeb();
  }

  void _onResize([_]) {
    final viewport = window.visualViewport;
    if (viewport == null) return;

    final totalHeight = window.innerHeight ?? 0;
    final visibleHeight = viewport.height ?? totalHeight;

    final keyboardHeight =
        (totalHeight - visibleHeight).clamp(0, double.infinity);

    final isVisible = keyboardHeight > 0;
    _isAnimating = keyboardHeight != _lastHeight;

    _lastHeight = keyboardHeight.toDouble();

    _insetController.add(keyboardHeight.toDouble());
    _stateController.add(
      KeyboardState(isVisible: isVisible, isAnimating: _isAnimating),
    );
  }

  @override
  Stream<double> get insets => _insetController.stream;

  @override
  Stream<KeyboardState> get stateStream => _stateController.stream;

  @override
  double get keyboardHeight => _lastHeight;

  @override
  bool get isVisible => _lastHeight > 0;

  @override
  bool get isAnimating => _isAnimating;

  void dispose() {
    window.visualViewport?.removeEventListener('resize', _onResize);
    window.visualViewport?.removeEventListener('scroll', _onResize);
    _insetController.close();
    _stateController.close();
  }
}
