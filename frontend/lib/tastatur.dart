import 'package:enigma/utils.dart';
import 'package:flutter/material.dart';
import 'package:enigma/keyhistory.dart';
import 'package:flutter/services.dart';

// void main() {
//   runApp(const Tastatur());
// }

class Tastatur extends StatefulWidget {
  final KeyHistoryList keyHistory;

  const Tastatur({super.key, required this.keyHistory});

  @override
  State<Tastatur> createState() => TastaturState();
}

class TastaturState extends State<Tastatur> {
  final double seizedBoxHeight = 10;

  @override
  Widget build(BuildContext context) {
    final history = widget.keyHistory;

    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Initialises 26 buttons that make up a QWERTZ keyboard layout, just like for the lamp panel.

                SquareButton(label: 'Q', keyHistory: history),
                SquareButton(label: 'W', keyHistory: history),
                SquareButton(label: 'E', keyHistory: history),
                SquareButton(label: 'R', keyHistory: history),
                SquareButton(label: 'T', keyHistory: history),
                SquareButton(label: 'Z', keyHistory: history),
                SquareButton(label: 'U', keyHistory: history),
                SquareButton(label: 'I', keyHistory: history),
                SquareButton(label: 'O', keyHistory: history),
                SquareButton(label: 'P', keyHistory: history),
              ],
            ),
            SizedBox(height: seizedBoxHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareButton(label: 'A', keyHistory: history),
                SquareButton(label: 'S', keyHistory: history),
                SquareButton(label: 'D', keyHistory: history),
                SquareButton(label: 'F', keyHistory: history),
                SquareButton(label: 'G', keyHistory: history),
                SquareButton(label: 'H', keyHistory: history),
                SquareButton(label: 'J', keyHistory: history),
                SquareButton(label: 'K', keyHistory: history),
                SquareButton(label: 'L', keyHistory: history),
              ],
            ),
            SizedBox(height: seizedBoxHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareButton(label: 'Y', keyHistory: history),
                SquareButton(label: 'X', keyHistory: history),
                SquareButton(label: 'C', keyHistory: history),
                SquareButton(label: 'V', keyHistory: history),
                SquareButton(label: 'B', keyHistory: history),
                SquareButton(label: 'N', keyHistory: history),
                SquareButton(label: 'M', keyHistory: history)
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
  final KeyHistoryList keyHistory;

  SquareButton({
    required this.label,
    required this.keyHistory,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      key: ValueKey("Tastatur-Button-$label"),
      child: ElevatedButton(
        onPressed: () async {
          final letter = label;
          final encryptedLetter = await sendPressedKeyToRotors(letter);
          keyHistory.addKey(letter, encryptedLetter);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // background color lol
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // rounded corners
          ),
        ),
        child: Text(label),
      ),
    );
  }

// This can be used for manual debugging kind of; shows an alertDialog whenever a button is pressed; shows error or correct functionality
/*@override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      key: ValueKey("Tastatur-Button-$label"),
      child: ElevatedButton(
        onPressed: () {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              return FutureBuilder<String>(
                future: sendPressedKeyToRotors(label),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasError) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: Text('Error: ${snapshot.data}'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  } else {
                    return AlertDialog(
                      title: const Text('Result'),
                      key: const ValueKey('ResultKey'),
                      content: Text(snapshot.data ?? 'No response'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  }
                },
              );
            },
          );
        },
        child: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // rounded corners
          ),
        ),
      ),
    );
  }*/
}
