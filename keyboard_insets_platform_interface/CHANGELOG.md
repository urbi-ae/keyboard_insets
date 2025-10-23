## 1.0.0

### ✨ Initial release of Shared platform interface

#### Features

- **Real-time keyboard height updates**
  - Emits keyboard height on every animation frame.
  - Stays perfectly in sync with native animations.

- **Keyboard state stream**
  - Provides visibility (`isVisible`) and animation (`isAnimating`) status.
  - Automatically starts/stops native listeners when streams are active or paused.

- **Persistent Safe Area API**
  - Added [`PersistentSafeAreaBottom`](lib/src/persistent_safe_area_bottom.dart) for real-time bottom safe area tracking.
  - Stays stable during keyboard animations.
  - Exposes:
    - `ValueNotifier<double>? safeArea`
    - `startObserving()`
    - `stopObserving()`

- **PersistentSafeArea widget**
  - A drop-in alternative to Flutter’s `SafeArea` that keeps bottom padding stable while the keyboard animates.
  - Supports manual or automatic lifecycle handling via `handleObserver`.

- **Cross-platform support**
  - **iOS**: Uses native UIKit safe area and keyboard frame observers.
  - **Android**: Uses `WindowInsetsAnimationCompat` for high-frequency keyboard insets.
  - **Web**: Fallback implementation using browser viewport APIs.

---

### 🧩 Packages

This release introduces a modular architecture:

| Package | Description |
|----------|--------------|
| `keyboard_insets` | Main plugin (public API + widget layer) |
| `keyboard_insets_mobile` | Native iOS + Android FFI implementations |
| `keyboard_insets_web` | Web fallback implementation |
| `keyboard_insets_platform_interface` | Shared platform interface |