part of '../src/keyboard_insets_mobile.dart';

const String _libName = 'keyboard_insets_mobile';

final DynamicLibrary _dylib = () {
  print('KeyboardInsetsMobile: Loading dynamic library for $_libName');
  if (Platform.isIOS) {
    return DynamicLibrary.process();
  }
  if (Platform.isAndroid) {
    return DynamicLibrary.open('lib$_libName.so');
  }

  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

final _bindings = KeyboardInsetsBindings(_dylib);
