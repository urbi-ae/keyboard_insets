import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:keyboard_insets/persistent_safe_area/persistent_safe_area_bottom.dart';

/// A widget that insets its child by the current safe area padding
/// (such as the home indicator or navigation bar) which stays stable
/// during keyboard animations.
///
/// Unlike Flutter’s built-in [SafeArea], this widget ensures the bottom inset
/// remains stable during keyboard animations.
///
/// It listens to the [PersistentSafeAreaBottom.notifier] notifier to apply
/// the correct bottom padding dynamically.
///
/// ---
///
/// ### Example
/// ```dart
/// PersistentSafeArea(
///   child: Scaffold(
///     backgroundColor: Colors.black,
///     body: Center(child: Text('Safe content area')),
///   ),
/// )
/// ```
///
/// ---
///
/// ### Lifecycle Handling
/// By default, the widget doesn't start and stop observing native safe area
/// changes automatically when it’s inserted or removed from the widget tree.
///
/// You must manage the observation manually (for example, via
/// `PersistentSafeAreaBottom.startObservingSafeArea()` in your own lifecycle),
/// to prevent duplicate observers or set [handleObserver] to `true` and let
/// this widget handle it automatically.
///
/// ---
///
/// ### Parameters
/// * [child] — The widget below this widget in the tree.
/// * [handleObserver] — Whether the widget should automatically start and stop
///   native safe area observation. Defaults to `false`.
///
/// When `handleObserver` is `false`, you must manage the lifecycle manually:
///
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   PersistentSafeAreaBottom.startObservingSafeArea();
/// }
///
/// @override
/// void dispose() {
///   PersistentSafeAreaBottom.stopObservingSafeArea();
///   super.dispose();
/// }
/// ```
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

  /// Whether to automatically manage the lifecycle of the
  /// [PersistentSafeAreaBottom] observer.
  ///
  /// Defaults to `true`. If set to `false`, you must call
  /// [PersistentSafeAreaBottom.startObservingSafeArea] and
  /// [PersistentSafeAreaBottom.stopObservingSafeArea] manually.
  final bool handleObserver;

  /// Creates a widget that insets its child by the system safe area padding,
  /// keeping the bottom inset stable during keyboard animations.
  ///
  /// This constructor behaves similarly to Flutter’s [SafeArea] widget,
  /// but uses native platform observers to provide more consistent layout
  /// behavior when the keyboard is shown or hidden.
  ///
  /// ---
  ///
  /// ### Behavior
  /// - Uses a [ValueNotifier] to track the bottom safe area in real time.
  /// - Remains stable while the keyboard animates in or out.
  /// - Updates automatically on system layout changes (e.g., orientation or navigation mode).
  /// - Can optionally manage native observer lifecycle automatically via [handleObserver].
  ///
  /// ---
  ///
  /// ### Parameters
  ///
  /// * [child] — The widget below this widget in the tree.
  ///
  /// * [left] — Whether to apply the system safe area padding on the left side.
  ///   Defaults to `true`.
  ///
  /// * [top] — Whether to apply the system safe area padding on the top side.
  ///   Defaults to `true`.
  ///
  /// * [right] — Whether to apply the system safe area padding on the right side.
  ///   Defaults to `true`.
  ///
  /// * [bottom] — Whether to apply the system safe area padding on the bottom side.
  ///   Defaults to `true`.
  ///
  /// * [minimum] — The minimum padding to apply on each side, even if the
  ///   system inset for that side is smaller. Defaults to [EdgeInsets.zero].
  ///
  /// * [handleObserver] — Whether the widget should automatically start and stop
  ///   observing the native safe area changes.
  ///
  ///   - If `true`, observation starts when this widget is inserted into the tree,
  ///     and stops when it’s removed.
  ///   - If `false` (default), you must manually call
  ///     [PersistentSafeAreaBottom.startObservingSafeArea] and
  ///     [PersistentSafeAreaBottom.stopObservingSafeArea] to manage lifecycle.
  ///
  /// ---
  ///
  /// ### Example
  /// ```dart
  /// PersistentSafeArea(
  ///   handleObserver: true,
  ///   child: Scaffold(
  ///     backgroundColor: Colors.black,
  ///     body: Center(child: Text('Safe content area')),
  ///   ),
  /// )
  /// ```
  const PersistentSafeArea({
    required this.child,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.handleObserver = false,
    this.minimum = EdgeInsets.zero,
    super.key,
  });

  @override
  State<PersistentSafeArea> createState() => _PersistentSafeAreaState();
}

class _PersistentSafeAreaState extends State<PersistentSafeArea> {
  @override
  void initState() {
    super.initState();
    if (widget.handleObserver) {
      PersistentSafeAreaBottom.startObserving();
    }
  }

  @override
  void dispose() {
    if (widget.handleObserver) {
      PersistentSafeAreaBottom.startObserving();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.left;
    final top = widget.top;
    final right = widget.right;
    final bottom = widget.bottom;
    final minimum = widget.minimum;
    final notifier = PersistentSafeAreaBottom.notifier;

    if (notifier == null) {
      return SafeArea(
        bottom: false,
        child: widget.child,
      );
    }

    return ValueListenableBuilder(
      valueListenable: notifier,
      child: MediaQuery.removePadding(
        context: context,
        removeLeft: left,
        removeTop: top,
        removeRight: right,
        removeBottom: bottom,
        child: widget.child,
      ),
      builder: (context, bottomInset, child) {
        final EdgeInsets padding =
            MediaQuery.paddingOf(context).copyWith(bottom: bottomInset);

        return Padding(
          padding: EdgeInsets.only(
            left: math.max(left ? padding.left : 0.0, minimum.left),
            top: math.max(top ? padding.top : 0.0, minimum.top),
            right: math.max(right ? padding.right : 0.0, minimum.right),
            bottom: math.max(bottom ? padding.bottom : 0.0, minimum.bottom),
          ),
          child: child,
        );
      },
    );
  }
}
