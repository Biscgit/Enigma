import 'package:enigma/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:synchronized/synchronized.dart';

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

  var keyboardLock = Lock();
  int inQueue = 0;

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
      if (char.compareTo('a') >= 0 && char.compareTo('z') <= 0) {
        // limit keyboard speed
        if (inQueue > 3) return;
        inQueue++;

        // ensure synchronized access
        await keyboardLock.synchronized(() async {
          final encryptedLetter = await sendPressedKeyToRotors(char);

          Cookie.trigger("update");
          Cookie.trigger(
              "update_history", {"clear": char, "encrypted": encryptedLetter});
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

                SquareButton(label: 'Q', key: listOfGlobalKeys[16], context: context),
                SquareButton(label: 'W', key: listOfGlobalKeys[22], context: context),
                SquareButton(label: 'E', key: listOfGlobalKeys[4], context: context),
                SquareButton(label: 'R', key: listOfGlobalKeys[17], context: context),
                SquareButton(label: 'T', key: listOfGlobalKeys[19], context: context),
                SquareButton(label: 'Z', key: listOfGlobalKeys[25], context: context),
                SquareButton(label: 'U', key: listOfGlobalKeys[20], context: context),
                SquareButton(label: 'I', key: listOfGlobalKeys[8], context: context),
                SquareButton(label: 'O', key: listOfGlobalKeys[14], context: context),
                SquareButton(label: 'P', key: listOfGlobalKeys[15], context: context),
              ],
            ),
            SizedBox(height: seizedBoxHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareButton(label: 'A', key: listOfGlobalKeys[0], context: context),
                SquareButton(label: 'S', key: listOfGlobalKeys[18], context: context),
                SquareButton(label: 'D', key: listOfGlobalKeys[3], context: context),
                SquareButton(label: 'F', key: listOfGlobalKeys[5], context: context),
                SquareButton(label: 'G', key: listOfGlobalKeys[6], context: context),
                SquareButton(label: 'H', key: listOfGlobalKeys[7], context: context),
                SquareButton(label: 'J', key: listOfGlobalKeys[9], context: context),
                SquareButton(label: 'K', key: listOfGlobalKeys[10], context: context),
                SquareButton(label: 'L', key: listOfGlobalKeys[11], context: context),
              ],
            ),
            SizedBox(height: seizedBoxHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareButton(label: 'Y', key: listOfGlobalKeys[24], context: context),
                SquareButton(label: 'X', key: listOfGlobalKeys[23], context: context),
                SquareButton(label: 'C', key: listOfGlobalKeys[2], context: context),
                SquareButton(label: 'V', key: listOfGlobalKeys[21], context: context),
                SquareButton(label: 'B', key: listOfGlobalKeys[1], context: context),
                SquareButton(label: 'N', key: listOfGlobalKeys[13], context: context),
                SquareButton(label: 'M', key: listOfGlobalKeys[12], context: context)
              ],
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
  final BuildContext context;

  SquareButton({
    super.key,
    required this.label,
    required this.context,
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
      //colorBox == widget.defaultColorBox;
      // if (text == "O") {
      //   //For testing; remove once backend communicates to frontend
      //   colorBox = widget.highlightedColor;
      //   highlighted = 1;
      // } else {
      //     if(Theme.of(widget.context).brightness == Brightness.light) {
      //       colorBox = widget.defaultColorBoxLightMode;
      //     }
      //     else {
      //       colorBox = widget.defaultColorBoxDarkMode;
      //     }
      // }
      //colorBox = widget.returnColor(context);
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
        if(Theme.of(widget.context).brightness == Brightness.light) {
          colorBox = widget.colorLightMode;
        }
        else {
          colorBox = widget.colorDarkMode;
        }
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
        onPressed: () async {
          //changeColor(true);
          final letter = label;
          final encryptedLetter = await sendPressedKeyToRotors(letter);
          Cookie.trigger("update");
          Cookie.trigger("update_history",
              {"clear": letter, "encrypted": encryptedLetter});
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorBox, // background color lol
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
