import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:keyboard_insets/persistent_safe_area/persistent_safe_area_bottom.dart';

/// A widget that insets its child by the current bottom safe area (home indicator or navigation bar),
/// staying stable during keyboard animations.
///
/// Unlike Flutter's built-in [SafeArea], this widget **does not shrink**
/// when the keyboard appears. Instead, it tracks the persistent system safe area
/// using [PersistentSafeAreaBottom.stream].
///
/// ### Example:
/// ```dart
/// PersistentSafeArea(
///   child: Align(
///     alignment: Alignment.bottomCenter,
///     child: Padding(
///       padding: const EdgeInsets.all(16),
///       child: ElevatedButton(
///         onPressed: () {},
///         child: const Text('Continue'),
///       ),
///     ),
///   ),
/// )
/// ```
///
/// ### Behavior
/// - Uses a stream to track the bottom safe area in real time.
/// - Remains stable while the keyboard animates in or out.
/// - Updates automatically on system layout changes (e.g., orientation or navigation mode).
class PersistentSafeArea extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// Whether to avoid system intrusions on the left.
  final bool left;

  /// Whether to avoid system intrusions at the top of the screen, typically the
  /// system status bar.
  final bool top;

  /// Whether to avoid system intrusions on the right.
  final bool right;

  /// Whether to avoid system intrusions on the bottom side of the screen.
  final bool bottom;

  /// This minimum padding to apply.
  ///
  /// The greater of the minimum insets and the media padding will be applied.
  final EdgeInsets minimum;

  /// A widget that insets its child by the current bottom safe area (home indicator or navigation bar),
  /// staying stable during keyboard animations.
  ///
  /// Unlike Flutter's built-in [SafeArea], this widget **does not shrink**
  /// when the keyboard appears. Instead, it tracks the persistent system safe area
  /// using [PersistentSafeAreaBottom.stream].
  ///
  /// ### Example:
  /// ```dart
  /// PersistentSafeArea(
  ///   child: Align(
  ///     alignment: Alignment.bottomCenter,
  ///     child: Padding(
  ///       padding: const EdgeInsets.all(16),
  ///       child: ElevatedButton(
  ///         onPressed: () {},
  ///         child: const Text('Continue'),
  ///       ),
  ///     ),
  ///   ),
  /// )
  /// ```
  ///
  /// ### Behavior
  /// - Uses a stream to track the bottom safe area in real time.
  /// - Remains stable while the keyboard animates in or out.
  /// - Updates automatically on system layout changes (e.g., orientation or navigation mode).
  const PersistentSafeArea({
    required this.child,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    super.key,
  });

  @override
  State<PersistentSafeArea> createState() => _PersistentSafeAreaState();
}

class _PersistentSafeAreaState extends State<PersistentSafeArea> {
  late StreamSubscription<double> _subscription;
  double _bottomInset = 0.0;

  @override
  void initState() {
    super.initState();
    _subscription = PersistentSafeAreaBottom.stream.listen((inset) {
      if (mounted) {
        setState(() => _bottomInset = inset);
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.left;
    final top = widget.top;
    final right = widget.right;
    final bottom = widget.bottom;
    final minimum = widget.minimum;
    final EdgeInsets padding =
        MediaQuery.paddingOf(context).copyWith(bottom: _bottomInset);

    return Padding(
      padding: EdgeInsets.only(
        left: math.max(left ? padding.left : 0.0, minimum.left),
        top: math.max(top ? padding.top : 0.0, minimum.top),
        right: math.max(right ? padding.right : 0.0, minimum.right),
        bottom: math.max(bottom ? padding.bottom : 0.0, minimum.bottom),
      ),
      child: MediaQuery.removePadding(
        context: context,
        removeLeft: left,
        removeTop: top,
        removeRight: right,
        removeBottom: bottom,
        child: widget.child,
      ),
    );
  }
}
