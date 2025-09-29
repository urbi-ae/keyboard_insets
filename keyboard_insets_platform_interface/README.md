# keyboard_insets_platform_interface

Platform interface for the [`keyboard_insets`](https://pub.dev/packages/keyboard_insets) plugin.

This package defines the common API surface (abstract methods, model classes) 
used by platform-specific implementations.

## Usage

This package is **not intended to be used directly**.
Depend on [`keyboard_insets`](https://pub.dev/packages/keyboard_insets) instead.

## Notes

- Provides `KeyboardInsetsPlatform` base class.
- Provides `KeyboardState` model.
- Includes a `DummyKeyboardInsets` implementation (used for desktop).
