import 'package:keyboard_insets_platform_interface/keyboard_insets_platform_interface.dart';

export 'persistent_safe_area/persistent_safe_area.dart';
export 'persistent_safe_area/persistent_safe_area_bottom.dart';

/// Main class to access keyboard insets and state.
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
///   void initState() {
///     super.initState();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: Material(
///         child: StreamBuilder(
///           stream: KeyboardInsets.insets,
///           builder: (context, snapshot) {
///             return Center(
///               child: Text('Keyboard height: ${snapshot.data}'),
///             );
///           },
///         ),
///       ),
///     );
///   }
/// }
/// ```
final class KeyboardInsets {
  const KeyboardInsets._();

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

  static Stream<double> get insets => KeyboardInsetsPlatform.instance.insets;

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
  static Stream<KeyboardState> get stateStream =>
      KeyboardInsetsPlatform.instance.stateStream;

  /// Get current keyboard height in logical pixels.
  ///
  /// For this value to be updated, you need to subscribe to any of the streams
  static double get keyboardHeight =>
      KeyboardInsetsPlatform.instance.keyboardHeight;

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
  static bool get isVisible => KeyboardInsetsPlatform.instance.isVisible;

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
  static bool get isAnimating => KeyboardInsetsPlatform.instance.isAnimating;
}
