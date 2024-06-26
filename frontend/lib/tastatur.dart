import 'package:enigma/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'queue.dart';

class Tastatur extends StatefulWidget {
  const Tastatur({super.key});

  @override
  State<Tastatur> createState() => TastaturState();
}

class TastaturState extends State<Tastatur> {
  final double seizedBoxHeight = 10;
  final FocusNode _focusNode = FocusNode();

  var keyPressQueue = TaskQueue();
  bool barShown = false;

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
    // filter unwanted events
    if (HardwareKeyboard.instance.isAltPressed ||
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed) return;

    if (event.character != null) {
      String char = event.character!.toLowerCase();
      await sendKeyInput(char);
    }
  }

  Future<void> sendKeyInput(String char) async {
    char = char.toLowerCase();
    if (char.compareTo('a') >= 0 && char.compareTo('z') <= 0) {
      assert(char.length == 1);

      final startTime = DateTime.now();
      await keyPressQueue.addTask(() async {
        // message on too fast typing instead of skipping inputs
        if (keyPressQueue.getLength() > 5 && !barShown) {
          barShown = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("You are typing too fast!"),
                backgroundColor: Colors.deepOrange,
                duration: Duration(hours: 24)),
          );
        } else if (barShown && keyPressQueue.getLength() < 3) {
          barShown = false;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }

        final encryptedLetter = await sendPressedKeyToRotors(char);

        Cookie.trigger("update");
        Cookie.trigger(
          "update_history",
          {"clear": char, "encrypted": encryptedLetter},
        );
      });

      // check performance in debug mode
      if (kDebugMode) {
        final endTime = DateTime.now();
        final executionTime = endTime.difference(startTime);
        print('Full keypress execution: ${executionTime.inMilliseconds}ms');
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
                SquareButton(label: 'Q', tastaturState: this),
                SquareButton(label: 'W', tastaturState: this),
                SquareButton(label: 'E', tastaturState: this),
                SquareButton(label: 'R', tastaturState: this),
                SquareButton(label: 'T', tastaturState: this),
                SquareButton(label: 'Z', tastaturState: this),
                SquareButton(label: 'U', tastaturState: this),
                SquareButton(label: 'I', tastaturState: this),
                SquareButton(label: 'O', tastaturState: this),
                SquareButton(label: 'P', tastaturState: this),
              ],
            ),
            SizedBox(height: seizedBoxHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareButton(label: 'A', tastaturState: this),
                SquareButton(label: 'S', tastaturState: this),
                SquareButton(label: 'D', tastaturState: this),
                SquareButton(label: 'F', tastaturState: this),
                SquareButton(label: 'G', tastaturState: this),
                SquareButton(label: 'H', tastaturState: this),
                SquareButton(label: 'J', tastaturState: this),
                SquareButton(label: 'K', tastaturState: this),
                SquareButton(label: 'L', tastaturState: this),
              ],
            ),
            SizedBox(height: seizedBoxHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareButton(label: 'Y', tastaturState: this),
                SquareButton(label: 'X', tastaturState: this),
                SquareButton(label: 'C', tastaturState: this),
                SquareButton(label: 'V', tastaturState: this),
                SquareButton(label: 'B', tastaturState: this),
                SquareButton(label: 'N', tastaturState: this),
                SquareButton(label: 'M', tastaturState: this),
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
  final TastaturState tastaturState;

  SquareButton({
    super.key,
    required this.label,
    required this.tastaturState,
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
        onPressed: () {
          tastaturState.sendKeyInput(label);
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
