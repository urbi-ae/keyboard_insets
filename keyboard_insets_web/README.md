# keyboard_insets_web

Web implementation of the [`keyboard_insets`](https://pub.dev/packages/keyboard_insets) plugin.

## Features

- Detects keyboard height on mobile browsers using `window.visualViewport`.
- Emits:
  - Keyboard height.
  - Visibility + animation state.

## Limitations

- Many desktop browsers report no keyboard → height will stay at `0.0`.
- Accuracy depends on browser support for `visualViewport`.

## Usage
This package is **not intended to be used directly**.
Depend on [`keyboard_insets`](https://pub.dev/packages/keyboard_insets) instead.

This package will be selected automatically on web builds.
