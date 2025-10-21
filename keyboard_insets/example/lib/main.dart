import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_insets/keyboard_insets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    PersistentSafeAreaBottom.stream.listen((inset) {
      if (kDebugMode) {
        print('Safe area height: $inset');
      }
    });
    KeyboardInsets.stateStream.listen((event) {
      if (kDebugMode) {
        print(
            'Keyboard height: ${event.isAnimating} v=${event.isVisible} ${KeyboardInsets.keyboardHeight}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 16);

    return MaterialApp(
      home: Material(
        child: StreamBuilder(
          stream: KeyboardInsets.insets,
          builder: (context, snapshot) {
            return Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    margin: EdgeInsets.only(
                      bottom: max(0, (snapshot.data ?? 0)),
                    ),
                    color: Colors.red,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: Text(
                          'insets: ${snapshot.data}',
                          style: textStyle,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Focus to see view inset change',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
