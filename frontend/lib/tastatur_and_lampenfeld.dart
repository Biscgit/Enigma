import 'package:flutter/material.dart';
import 'lampenfeld.dart';
import 'tastatur.dart';
import 'package:enigma/keyhistory.dart';

// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MainScreen(),
//     );
//   }
// }

class MainScreen extends StatelessWidget {
  final KeyHistoryList keyHistory;

  const MainScreen({super.key, required this.keyHistory});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).size.height / 8 * 2.5,
          child: Lampfield(
            key: Lampfield.lampFieldKey,
            keyHistory: keyHistory,
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 8 * 2.5,
          left: 0,
          right: 0,
          bottom: 0,
          child: Tastatur(
            keyHistory: keyHistory,
          ),
        ),
      ],
    );
  }
}
