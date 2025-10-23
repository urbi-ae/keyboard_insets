import 'package:flutter/widgets.dart';
import 'package:keyboard_insets/persistent_safe_area/persistent_safe_area.dart';
import 'package:keyboard_insets_platform_interface/keyboard_insets_platform_interface.dart';

/// Provides access to the system's **bottom safe area** (home indicator or navigation bar).
///
/// This class exposes a [ValueNotifier] that tracks the current **bottom safe area height** —
/// typically the system UI padding at the bottom of the screen, such as:
/// - the **home indicator** on iOS, or
/// - the **navigation bar** on Android.
///
/// The bottom inset value remains **stable during keyboard animations** and updates
/// only when the system layout changes (for example, due to orientation or navigation mode changes).
///
/// ---
///
/// ### Example
/// ```dart
/// import 'package:keyboard_insets/keyboard_insets.dart';
///
/// void main() {
///   runApp(const MyApp());
/// }
///
/// class MyApp extends StatefulWidget {
///   const MyApp({super.key});
///
///   @override
///   State<MyApp> createState() => _MyAppState();
/// }
///
/// class _MyAppState extends State<MyApp> {
///   @override
///   void initState() {
///     super.initState();
///     // Begin observing the native safe area changes.
///     PersistentSafeAreaBottom.startObserving();
///   }
///
///   @override
///   void dispose() {
///     // Stop observing when the widget is removed from the tree.
///     PersistentSafeAreaBottom.stopObserving();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: Scaffold(
///         body: ValueListenableBuilder<double>(
///           valueListenable: PersistentSafeAreaBottom.notifier!,
///           builder: (context, bottomInset, _) {
///             return Padding(
///               padding: EdgeInsets.only(bottom: bottomInset),
///               child: Center(
///                 child: Text('Bottom safe area: $bottomInset'),
///               ),
///             );
///           },
///         ),
///       ),
///     );
///   }
/// }
/// ```
///
/// ---
///
/// ### Lifecycle
/// - You only can manually manage observation lifecycle by calling
///   [startObserving] and [stopObserving].
///
/// ---
///
/// ### See also
/// * [PersistentSafeArea], a widget that applies the bottom safe area padding to its child
///   and keeps it stable during keyboard animations.
final class PersistentSafeAreaBottom {
  const PersistentSafeAreaBottom._();

  /// A [ValueNotifier] representing the current bottom safe area height in logical pixels.
  ///
  /// Emits new values whenever the system layout changes (for example, when the
  /// device orientation changes or navigation mode toggles between gesture and button navigation).
  static ValueNotifier<double>? get notifier =>
      KeyboardInsetsPlatform.instance.safeArea;

  /// Starts observing system safe area changes.
  ///
  /// Begins monitoring the device’s safe area (e.g., home indicator or navigation bar)
  /// and updates [notifier] whenever it changes.
  ///
  /// Typically called in `initState()` or when your UI becomes active.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   PersistentSafeAreaBottom.startObservingSafeArea();
  /// }
  /// ```
  static void startObserving() =>
      KeyboardInsetsPlatform.instance.startObservingSafeArea();

  /// Stops observing system safe area changes.
  ///
  /// Call this when your UI is no longer visible or being disposed of to avoid
  /// unnecessary updates and potential memory leaks.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   PersistentSafeAreaBottom.stopObservingSafeArea();
  ///   super.dispose();
  /// }
  /// ```
  static void stopObserving() =>
      KeyboardInsetsPlatform.instance.stopObservingSafeArea();
}
