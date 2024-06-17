import 'package:enigma/keyhistory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:enigma/utils.dart';

class Lampfield extends StatefulWidget {
  static final GlobalKey<LampfieldState> lampFieldKey =
      GlobalKey<LampfieldState>();

  // const Lampfield({super.key});
  final KeyHistoryList keyHistory;

  const Lampfield({super.key, required this.keyHistory});

  @override
  State<Lampfield> createState() => LampfieldState();

  void sendToHistory(String clear, String encrypted) {
    keyHistory.addKey(clear, encrypted);
  }
}

class LampfieldState extends State<Lampfield> {
  int counter = 0;
  final double seizedBoxHeight = 5;
  final List<GlobalKey<CircularTextBoxState>> listOfGlobalKeys =
      List.generate(26, (index) => GlobalKey<CircularTextBoxState>());

  final TextEditingController _controller = TextEditingController();

  String lightUpLetter(String characterToLightUp) {
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

  Future<void> sendTextInputToLampfieldAsync(String input) async {
    //API to send textinputs as async calls
    for (int i = 0; i < input.length; i++) {
      lightUpLetter(input[i]);
    }
  }

  void sendTextInputToLampfield(String input) {
    //API to send textinputs without utilising async calls
    for (int i = 0; i < input.length; i++) {
      lightUpLetter(input[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Initialises 26 textboxes that look like lamps in a QWERTZ keyboard layout. Globalkey-index is spot_in_alphabet - 1.
              CircularTextBox(key: listOfGlobalKeys[16], text: 'Q', context: context),
              CircularTextBox(key: listOfGlobalKeys[22], text: 'W', context: context),
              CircularTextBox(key: listOfGlobalKeys[4], text: 'E', context: context),
              CircularTextBox(key: listOfGlobalKeys[17], text: 'R', context: context),
              CircularTextBox(key: listOfGlobalKeys[19], text: 'T', context: context),
              CircularTextBox(key: listOfGlobalKeys[25], text: 'Z', context: context),
              CircularTextBox(key: listOfGlobalKeys[20], text: 'U', context: context),
              CircularTextBox(key: listOfGlobalKeys[8], text: 'I', context: context),
              CircularTextBox(key: listOfGlobalKeys[14], text: 'O', context: context),
              CircularTextBox(key: listOfGlobalKeys[15], text: 'P', context: context),
            ],
          ),
          SizedBox(height: seizedBoxHeight),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularTextBox(key: listOfGlobalKeys[0], text: 'A', context: context),
              CircularTextBox(key: listOfGlobalKeys[18], text: 'S', context: context),
              CircularTextBox(key: listOfGlobalKeys[3], text: 'D', context: context),
              CircularTextBox(key: listOfGlobalKeys[5], text: 'F', context: context),
              CircularTextBox(key: listOfGlobalKeys[6], text: 'G', context: context),
              CircularTextBox(key: listOfGlobalKeys[7], text: 'H', context: context),
              CircularTextBox(key: listOfGlobalKeys[9], text: 'J', context: context),
              CircularTextBox(key: listOfGlobalKeys[10], text: 'K', context: context),
              CircularTextBox(key: listOfGlobalKeys[11], text: 'L', context: context),
            ],
          ),
          SizedBox(height: seizedBoxHeight),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularTextBox(key: listOfGlobalKeys[24], text: 'Y', context: context),
              CircularTextBox(key: listOfGlobalKeys[23], text: 'X', context: context),
              CircularTextBox(key: listOfGlobalKeys[2], text: 'C', context: context),
              CircularTextBox(key: listOfGlobalKeys[21], text: 'V', context: context),
              CircularTextBox(key: listOfGlobalKeys[1], text: 'B', context: context),
              CircularTextBox(key: listOfGlobalKeys[13], text: 'N', context: context),
              CircularTextBox(key: listOfGlobalKeys[12], text: 'M', context: context)
            ],
          ),
          SizedBox(
            //ONLY FOR MANUAL TEXT INPUTS!!!!! TO BE REMOVED LATER!!
            width: 300,
            child: TextField(
              key: const ValueKey('keyInput'),
              controller: _controller,
              onChanged: (String value) async {
                if (value.isNotEmpty) {
                  final letter = value.substring(value.length - 1);
                  final encryptedLetter = await sendPressedKeyToRotors(
                      value.substring(value.length - 1));
                  widget.sendToHistory(letter, encryptedLetter);
                }
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zr]')),
                // Allow only letters and space
                UpperCaseTextInputFormatter(),
                // Convert all letters to uppercase
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircularTextBox extends StatefulWidget {
  //Helper class that creates textboxes which are not rectangles.
  final String text;
  final Color colorText;
  //final Color defaultColorBox;
  final Color highlightedColor;
  final double fontSize;
  final double diameter;
  final Color defaultColorBoxLightMode;
  final Color defaultColorBoxDarkMode;
  final BuildContext context;

  const CircularTextBox({
    super.key,
    required this.text,
    required this.context,
    this.colorText = Colors.black54,
    this.highlightedColor = Colors.yellow,
    this.fontSize = 25,
    //this.defaultColorBox = Colors.black12,
    this.defaultColorBoxLightMode = Colors.black12,
    this.defaultColorBoxDarkMode  = Colors.white70,
    this.diameter = 45,
  });

  @override
  CircularTextBoxState createState() => CircularTextBoxState();
}

class CircularTextBoxState extends State<CircularTextBox> {
  late Color colorBox;
  late String text;
  int highlighted =
      0; //acts as a boolean value; used in testing to find whether button lights up

  @override
  void initState() {
    super.initState();
    text = widget.text;
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

    colorBox = widget.defaultColorBoxDarkMode;
  }

  void changeColor(bool color) {
    setState(() {
      if (color) {
        colorBox = widget.highlightedColor;
        highlighted = 1;
      } else {
        if(Theme.of(widget.context).brightness == Brightness.light) {
          colorBox = widget.defaultColorBoxLightMode;
        }
        else {
          colorBox = widget.defaultColorBoxDarkMode;
        }
        highlighted = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.diameter,
      height: widget.diameter,
      key: ValueKey("Lamppanel-Key-$text-$highlighted"),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorBox,
      ),
      alignment: Alignment.center,
      margin: const EdgeInsets.all(5),
      child: Text(
        widget.text,
        style: TextStyle(
            color: widget.colorText,
            fontSize: widget.fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: "Wallau",
        ),
      ),
    );
  }
}

class UpperCaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
