# 📦 Keyboard Insets

A Flutter plugin that provides **real-time keyboard insets and visibility state** across **iOS** and **Android**.  
Unlike `MediaQuery.viewInsets`, this package gives you **frame-by-frame updates** from the native views without relying on `BuildContext`.


## ✨ Features

-   **Real-time keyboard height stream**
-   **Keyboard state stream** (visibility + animation status)
-   **Persistent safe area support** (bottom insets independent of keyboard)
-   Automatic lifecycle: native observers start/stop based on active listeners
-   Lightweight, FFI-based (no MethodChannels)

## 📦 Installation

Add the package to your `pubspec.yaml`:
```yaml
dependencies:
    keyboard_insets: ^0.1.0
```

### iOS Setup

Make sure your **iOS deployment target is at least 13.0**

Open `ios/Podfile` and set:

```ruby
platform :ios, '13.0'
```

## ⚙️ Platform Details
||||
--|--|--|
Platform|Implementation|Notes
**iOS**|`CASpringAnimation`|Requires iOS 13.0+
**Android**|`WindowInsetsAnimationCompat` + FFI|Reads per-frame inset updates|
**Web**|Uses `visualViewport.onresize`|Lightweight JavaScript interop
**Desktop**|Dummy implementation|Always returns zero insets

## 🚀 Usage

### Keyboard Height
```dart
KeyboardInsets.insets.listen((height) {
  print('Keyboard height: $height');
});
```
### Keyboard State
```dart
KeyboardInsets.stateStream.listen((state) {
  print('Visible: ${state.isVisible}, Animating: ${state.isAnimating}');
});
```

### Persistent Safe Area Bottom

To listen to **bottom safe area** (home indicator / navigation bar) height, which **stays constant** during keyboard animations:

```dart
SafeAreaBottom.safeAreaStream.listen((bottomInset) {
  print('Safe area bottom: $bottomInset');
});
```

## 🧱 Widgets

### 🟦 PersistentSafeArea

A drop-in replacement for Flutter’s SafeArea that preserves bottom padding even when the keyboard opens or closes.

```dart
PersistentSafeArea(
  child: Scaffold(
    body: Center(child: Text("I ignore keyboard changes!")),
  ),
)
```
||||
--|--|--|--
Name|Type|Description
`child`|`Widget`|The widget below this safe area.
`maintainBottomInset`|`bool`|Whether to apply bottom padding independent of keyboard. Defaults to `true`.

### 🟩 `PersistentSafeAreaBottom`
A minimal widget that **only applies** bottom padding equal to the current system safe area (home indicator height).  
Perfect for sticky buttons or bottom bars.

```dart
PersistentSafeAreaBottom(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: ElevatedButton(
      onPressed: () {},
      child: Text("Continue"),
    ),
  ),
)
```

This padding stays **stable** while the keyboard animates, and only updates when the system safe area itself changes (like orientation rotation or system UI change).

## 📖 API Reference

### Keyboard Insets

||||
--|--|--|--
API|Type|Description
`KeyboardInsets.insets`|`Stream<double>`|Real-time keyboard height (px)
`KeyboardInsets.stateStream`|`Stream<KeyboardState>`|Visibility + animation state
`KeyboardInsets.keyboardHeight`|`double`|Persistent keyboard height
`KeyboardInsets.isVisible`|`bool`|Whether the keyboard is visible
`KeyboardInsets.isAnimating`|`bool`|Whether keyboard is animating

## 🤝 Contribution
Contributions are welcome! Please open issues for bugs or feature requests. Submit pull requests with clear descriptions and tests.

See [CONTRIBUTING.md](keyboard_insets/CONTRIBUTING.md) for guidelines.

## 📜 License

BSD-2 License. See [LICENSE](keyboard_insets/LICENSE) for details.