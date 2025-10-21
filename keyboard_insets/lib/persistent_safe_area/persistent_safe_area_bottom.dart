import 'package:keyboard_insets/persistent_safe_area/persistent_safe_area.dart';
import 'package:keyboard_insets_platform_interface/keyboard_insets_platform_interface.dart';

/// Main class to access the system's bottom safe area (home indicator or navigation bar).
///
/// This class provides a stream of the current **bottom safe area height** —
/// typically representing the system UI padding at the bottom of the screen,
/// such as the **home indicator** on iOS or the **navigation bar** on Android.
///
/// The safe area height remains stable during keyboard animations and updates
/// only when the system layout changes (e.g., when the orientation or navigation
/// mode changes).
///
/// ### Example:
/// ```dart
/// import 'package:view_insets/view_insets.dart';
///
/// void main() {
///   runApp(const MyApp());
/// }
///
/// class MyApp extends StatefulWidget {
///   const MyApp({super.key});
///   @override
///   State<MyApp> createState() => _MyAppState();
/// }
///
/// class _MyAppState extends State<MyApp> {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: Scaffold(
///         body: StreamBuilder<double>(
///           stream: PersistentSafeAreaBottom.stream,
///           builder: (context, snapshot) {
///             final bottomInset = snapshot.data ?? 0.0;
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
/// If there are no listeners, the native safe area observer is stopped to save resources.
/// When a listener is added, the observer restarts automatically.
/// This lifecycle is managed internally by the platform implementation.
///
///  See also:
///
///  * [PersistentSafeArea], a widget that insets its child by the current bottom safe area,
/// staying stable during keyboard animations.
final class PersistentSafeAreaBottom {
  const PersistentSafeAreaBottom._();

  /// Broadcast stream of the system's bottom safe area height.
  ///
  /// Emits the safe area height in logical pixels whenever it changes.
  /// The value remains constant during keyboard animations and updates
  /// only when system layout changes occur.
  ///
  /// ### Example:
  /// ```dart
  /// PersistentSafeAreaBottom.stream.listen((inset) {
  ///   print('Bottom safe area: $inset');
  /// });
  /// ```
  ///
  /// Use this to adjust layout elements that should avoid system UI overlap,
  /// such as bottom navigation bars or floating action buttons.
  static Stream<double> get stream =>
      KeyboardInsetsPlatform.instance.safeAreaStream;
}
