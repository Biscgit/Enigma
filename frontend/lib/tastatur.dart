import 'package:enigma/utils.dart';
import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

class Tastatur extends StatefulWidget {
  const Tastatur({super.key});

  @override
  State<Tastatur> createState() => TastaturState();
}

class TastaturState extends State<Tastatur> {
  final double seizedBoxHeight = 10;
  final FocusNode _focusNode = FocusNode();

  var keyboardLock = Lock();
  int inQueue = 0;

  @override
  void initState() {
    super.initState();
    setFordFocus();
    Cookie.setReactor("set_focus_keyboard", setFordFocus);
  }

  void setFordFocus([Map<dynamic, dynamic> params = const {}]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) async {
    if (event.character != null) {
      String char = event.character!.toLowerCase();
      if (char.compareTo('a') >= 0 && char.compareTo('z') <= 0) {
        // limit keyboard speed
        if (inQueue > 3) return;
        inQueue++;

        // ensure synchronized access
        await keyboardLock.synchronized(() async {
          final encryptedLetter = await sendPressedKeyToRotors(char);

          Cookie.trigger("update");
          Cookie.trigger("update_history", {"clear": char, "encrypted": encryptedLetter});
          inQueue--;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
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
  final double size = 50;
  final Color colorLightMode = Colors.black;
  final Color colorDarkMode = Colors.grey.shade600;
  final String label;

  SquareButton({
    super.key,
    required this.label,
  });

  Color? returnColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return colorLightMode;
    } else {
      return colorDarkMode;
    }
  }

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
          Cookie.trigger("update");
          Cookie.trigger("update_history", {"clear": letter, "encrypted": encryptedLetter});
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: returnColor(context), // background color lol
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // rounded corners
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
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
