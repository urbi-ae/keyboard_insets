/// A class representing the keyboard state, including visibility and animation status.
///
//// [isVisible] indicates whether the keyboard is currently visible.
//// [isAnimating] indicates whether the keyboard is in the process of showing or hiding.
final class KeyboardState {
  /// Indicates whether the keyboard is currently visible.
  final bool isVisible;

  /// Indicates whether the keyboard is in the process of showing or hiding.
  final bool isAnimating;

  /// Creates a [KeyboardState] instance with the given visibility and animation status.
  const KeyboardState({
    required this.isVisible,
    required this.isAnimating,
  });

  @override
  String toString() =>
      'KeyboardState: visible=$isVisible, animating=$isAnimating';
}
