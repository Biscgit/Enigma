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
  final List<GlobalKey<SquareButtonState>> listOfGlobalKeys =
      List.generate(26, (index) => GlobalKey<SquareButtonState>());

  var keyPressQueue = TaskQueue();
  List<int>? keyPerformanceAVG;
  bool barShown = false;

  String lightUpLetter([Map<dynamic, dynamic> params = const {"encKey": "O"}]) {
    var characterToLightUp = params["encKey"];
    //This method converts all inputs to uppercase, looks at only the first character and then subtracts the 65 that are added to every index due to ASCII indeces
    //(Example: A is "0th" letter of the alphabet -> ASCII value is 65)
    //Then, the respective key is accessed to change the background of the corresponding letter to the specified highlightColor.

    int letter = characterToLightUp.toUpperCase().codeUnitAt(0) - 65;
    for (int i = 0; i < 26; i++) {
      setState(() {
        listOfGlobalKeys[i].currentState?.changeColor(letter == i);
      });
    }
    return characterToLightUp;
  }

  @override
  void initState() {
    super.initState();
    setFordFocus();
    Cookie.setReactor("set_focus_keyboard", setFordFocus);
    Cookie.setReactor("update_keyboard", lightUpLetter);
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

      // check performance
      final endTime = DateTime.now();
      final executionTime = endTime.difference(startTime);
      setState(() {
        if (keyPerformanceAVG == null) {
          keyPerformanceAVG = List.filled(
            5,
            executionTime.inMilliseconds,
            growable: true,
          );
        } else {
          keyPerformanceAVG!.insert(0, executionTime.inMilliseconds);
          keyPerformanceAVG!.removeLast();
        }
      });

      if (kDebugMode) {
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

                SquareButton(
                    label: 'Q', key: listOfGlobalKeys[16], tastaturState: this),
                SquareButton(
                    label: 'W', key: listOfGlobalKeys[22], tastaturState: this),
                SquareButton(
                    label: 'E', key: listOfGlobalKeys[4], tastaturState: this),
                SquareButton(
                    label: 'R', key: listOfGlobalKeys[17], tastaturState: this),
                SquareButton(
                    label: 'T', key: listOfGlobalKeys[19], tastaturState: this),
                SquareButton(
                    label: 'Z', key: listOfGlobalKeys[25], tastaturState: this),
                SquareButton(
                    label: 'U', key: listOfGlobalKeys[20], tastaturState: this),
                SquareButton(
                    label: 'I', key: listOfGlobalKeys[8], tastaturState: this),
                SquareButton(
                    label: 'O', key: listOfGlobalKeys[14], tastaturState: this),
                SquareButton(
                    label: 'P', key: listOfGlobalKeys[15], tastaturState: this),
              ],
            ),
            SizedBox(height: seizedBoxHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareButton(
                    label: 'A', key: listOfGlobalKeys[0], tastaturState: this),
                SquareButton(
                    label: 'S', key: listOfGlobalKeys[18], tastaturState: this),
                SquareButton(
                    label: 'D', key: listOfGlobalKeys[3], tastaturState: this),
                SquareButton(
                    label: 'F', key: listOfGlobalKeys[5], tastaturState: this),
                SquareButton(
                    label: 'G', key: listOfGlobalKeys[6], tastaturState: this),
                SquareButton(
                    label: 'H', key: listOfGlobalKeys[7], tastaturState: this),
                SquareButton(
                    label: 'J', key: listOfGlobalKeys[9], tastaturState: this),
                SquareButton(
                    label: 'K', key: listOfGlobalKeys[10], tastaturState: this),
                SquareButton(
                    label: 'L', key: listOfGlobalKeys[11], tastaturState: this),
              ],
            ),
            SizedBox(height: seizedBoxHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareButton(
                    label: 'Y', key: listOfGlobalKeys[24], tastaturState: this),
                SquareButton(
                    label: 'X', key: listOfGlobalKeys[23], tastaturState: this),
                SquareButton(
                    label: 'C', key: listOfGlobalKeys[2], tastaturState: this),
                SquareButton(
                    label: 'V', key: listOfGlobalKeys[21], tastaturState: this),
                SquareButton(
                    label: 'B', key: listOfGlobalKeys[1], tastaturState: this),
                SquareButton(
                    label: 'N', key: listOfGlobalKeys[13], tastaturState: this),
                SquareButton(
                    label: 'M', key: listOfGlobalKeys[12], tastaturState: this)
              ],
            ),
            SizedBox(height: seizedBoxHeight / 2),
            Text(
              "Average Response: "
              "${(keyPerformanceAVG?.reduce((a, b) => a + b) ?? 0) ~/ 5}ms",
              style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.2)),
            ),
          ],
        ),
      ),
    );
  }
}

class SquareButton extends StatefulWidget {
  final double size = 50;
  final Color colorLightMode = Colors.black;
  final Color colorDarkMode = Colors.grey.shade600;
  final Color colorHighlighted = Colors.yellow;
  final String label;
  final TastaturState tastaturState;

  SquareButton({
    super.key,
    required this.label,
    required this.tastaturState,
  });

  Color returnColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return colorLightMode;
    } else {
      return colorDarkMode;
    }
  }

  @override
  SquareButtonState createState() => SquareButtonState();
}

class SquareButtonState extends State<SquareButton> {
  late Color colorBox;
  late String label;
  int highlighted = 0;

  @override
  void initState() {
    super.initState();
    label = widget.label;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    colorBox = widget.returnColor(context);
  }

  void changeColor(bool color) {
    setState(() {
      if (color) {
        colorBox = widget.colorHighlighted;
        highlighted = 1;
      } else {
        colorBox = widget.colorDarkMode;
        highlighted = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      key: ValueKey("Tastatur-Key-$label-$highlighted"),
      child: ElevatedButton(
        key: ValueKey("Tastatur-Button-$label"),
        onPressed: () {
          widget.tastaturState.sendKeyInput(label);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorBox, // background color lol
          overlayColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // rounded corners
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
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
      key: ValueKey("Tastatur-Key-$label"),
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
