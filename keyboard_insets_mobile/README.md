# keyboard_insets_mobile

Android + iOS implementation of the [`keyboard_insets`](https://pub.dev/packages/keyboard_insets) plugin.

## Features

- Native **FFI-based** bindings for Android and iOS.
- Streams real-time keyboard height and visibility.
- Uses platform-native APIs:
  - iOS: `UIKeyboardWillShow/Hide` notifications + `CADisplayLink` for per-frame updates.
  - Android: `WindowInsetsCompat` + `WindowInsetsAnimationCompat`.

## Requirements

- iOS minimum deployment target: **13.0**
- Android: API 21+

## Usage

This package is **not intended to be used directly**.
Depend on [`keyboard_insets`](https://pub.dev/packages/keyboard_insets) instead.

This package will be selected automatically on Android and iOS.