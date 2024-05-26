import 'package:flutter/material.dart';

void main() {
  runApp(const Tastatur());
}

class Tastatur extends StatefulWidget {
  const Tastatur({super.key});

  @override
  State<Tastatur> createState() => TastaturState();
}

class TastaturState extends State<Tastatur> {
  final double seizedBoxHeight = 10;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Initialises 26 buttons that make up a QWERTZ keyboard layout, just like for the lamp panel.

                SquareButton(label: 'Q'),
                SquareButton(label: 'W'),
                SquareButton(label: 'E'),
                SquareButton(label: 'R'),
                SquareButton(label: 'T'),
                SquareButton(label: 'Z'),
                SquareButton(label: 'U'),
                SquareButton(label: 'I'),
                SquareButton(label: 'O'),
                SquareButton(label: 'P'),
              ],
            ),
            SizedBox(height: seizedBoxHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareButton(label: 'A'),
                SquareButton(label: 'S'),
                SquareButton(label: 'D'),
                SquareButton(label: 'F'),
                SquareButton(label: 'G'),
                SquareButton(label: 'H'),
                SquareButton(label: 'J'),
                SquareButton(label: 'K'),
                SquareButton(label: 'L'),
              ],
            ),
            SizedBox(height: seizedBoxHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareButton(label: 'Y'),
                SquareButton(label: 'X'),
                SquareButton(label: 'C'),
                SquareButton(label: 'V'),
                SquareButton(label: 'B'),
                SquareButton(label: 'N'),
                SquareButton(label: 'M')
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SquareButton extends StatelessWidget {
  final double size = 60;
  final Color color = Colors.black;
  final String label;

  const SquareButton({
    required this.label,
  });

  String event() { //Insert API for rotors here when possible
    return this.label;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: () {
          event();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // rounded corners
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: size * 0.3, // font size relative to button size
            color: Colors.white, // text color
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}