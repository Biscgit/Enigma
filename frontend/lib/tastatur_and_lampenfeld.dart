import 'package:flutter/material.dart';
import 'lampenfeld.dart';
import 'tastatur.dart';

class MainScreen extends StatelessWidget {

  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final align = MediaQuery.of(context).size.height / 8 * 2.5;
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: align,
          child: Lampfield(),),
        Positioned(
          top: align,
          left: 0,
          right: 0,
          bottom: 0,
          child: const Tastatur(),
        ),
      ],
    );
  }
}
