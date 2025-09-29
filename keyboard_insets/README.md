# 📦 Keyboard Insets

A Flutter plugin that provides **real-time keyboard insets and visibility state** across iOS, Android.
Unlike `MediaQuery.viewInsets`, this package gives you **frame-by-frame updates** from the native views without using `BuildContext`.


## ✨ Features

-   **Real-time keyboard height stream**
-   **Keyboard state stream** (visibility + animation status)
-   Automatically starts/stops native observers when streams are listened to or canceled  
   
----------

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

-   **iOS** → Uses `CASpringAnimation` with native UIKit parameters.  
    Requires **iOS 13.0+** (due to `UIWindowScene` and insets API)
-   **Android** → Uses `WindowInsetsAnimationCompat` for frame-by-frame updates.


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

## 📖 API

### Streams
-   `KeyboardInsets.insets` → `Stream<double>` (keyboard height).
    
-   `KeyboardInsets.stateStream` → `Stream<KeyboardState>` (visibility + animation state).
    

### Synchronous Getters
-   `KeyboardInsets.keyboardHeight` → `double`
-   `KeyboardInsets.isVisible` → `bool`
-   `KeyboardInsets.isAnimating` → `bool`

### KeyboardState

```dart
class KeyboardState {
  final bool isVisible;   // true if keyboard is shown
  final bool isAnimating; // true if keyboard is opening/closing
}
```

## 🤝 Contribution
Contributions are welcome! Please open issues for bugs or feature requests. Submit pull requests with clear descriptions and tests.

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📜 License

BSD-2 License. See [LICENSE](LICENSE) for details.