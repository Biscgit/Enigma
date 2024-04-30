import 'package:flutter/material.dart';

/*

--------------- TODO ---------------

- Add comments
- Add tests
- Restructure some variables
- Clean up code?

*/


void main() {
  runApp(Lampfield());
}

class Lampfield extends StatefulWidget {
  runApp(const Lampfield());
}

class Lampfield extends StatefulWidget {
  const Lampfield({super.key});
  @override
  LampfieldState createState() => LampfieldState();
}

class LampfieldState extends State<Lampfield> {
  int counter = 0;
  final List<GlobalKey<_CircularTextBoxState>>listOfGlobalKeys = List.generate(26, (index) => GlobalKey<_CircularTextBoxState>());

  String lightUpLetter(String characterToLightUp) {
    int letter = characterToLightUp.toUpperCase().codeUnitAt(0) - 65;
    for(int i = 0; i < 26; i++) {
      setState(() {
        if(letter == i) {
          listOfGlobalKeys[i].currentState?.changeColor(Colors.yellow.shade700);
        }
        else {
          listOfGlobalKeys[i].currentState?.changeColor(null);
        }
      });
    }
    return characterToLightUp;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lamppanel deluxe'),
        ),
        body: Positioned(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularTextBox(key: listOfGlobalKeys[16], text: 'Q'),
                  CircularTextBox(key: listOfGlobalKeys[22], text: 'W'),
                  CircularTextBox(key: listOfGlobalKeys[4], text: 'E'),
                  CircularTextBox(key: listOfGlobalKeys[17], text: 'R'),
                  CircularTextBox(key: listOfGlobalKeys[19], text: 'T'),
                  CircularTextBox(key: listOfGlobalKeys[25], text: 'Z'),
                  CircularTextBox(key: listOfGlobalKeys[20], text: 'U'),
                  CircularTextBox(key: listOfGlobalKeys[8], text: 'I'),
                  CircularTextBox(key: listOfGlobalKeys[14], text: 'O'),
                  CircularTextBox(key: listOfGlobalKeys[15], text: 'P'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularTextBox(key: listOfGlobalKeys[0], text: 'A'),
                  CircularTextBox(key: listOfGlobalKeys[18], text: 'S'),
                  CircularTextBox(key: listOfGlobalKeys[3], text: 'D'),
                  CircularTextBox(key: listOfGlobalKeys[5], text: 'F'),
                  CircularTextBox(key: listOfGlobalKeys[6], text: 'G'),
                  CircularTextBox(key: listOfGlobalKeys[7], text: 'H'),
                  CircularTextBox(key: listOfGlobalKeys[9], text: 'J'),
                  CircularTextBox(key: listOfGlobalKeys[10], text: 'K'),
                  CircularTextBox(key: listOfGlobalKeys[11], text: 'L'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularTextBox(key: listOfGlobalKeys[24], text: 'Y'),
                  CircularTextBox(key: listOfGlobalKeys[23], text: 'X'),
                  CircularTextBox(key: listOfGlobalKeys[2], text: 'C'),
                  CircularTextBox(key: listOfGlobalKeys[21], text: 'V'),
                  CircularTextBox(key: listOfGlobalKeys[1], text: 'B'),
                  CircularTextBox(key: listOfGlobalKeys[13], text: 'N'),
                  CircularTextBox(key: listOfGlobalKeys[12], text: 'M'),
                  TextButton(
                    onPressed: () {
                      if(counter % 2 == 0) {
                        lightUpLetter("A");
                      }
                      else {
                        lightUpLetter("G");
                      }
                      counter++;
                    },
                    child: Text("bruh")
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircularTextBox extends StatefulWidget {
  final String text;
  final Color colorText;
  final Color defaultColorBox;
  final Color highlightedColor;
  final double fontSize;
  final double diameter;

  const CircularTextBox({
    Key? key,
    required this.text,
    this.colorText = Colors.black,
    this.defaultColorBox = Colors.grey,
    this.highlightedColor = Colors.yellow,
    this.fontSize = 20,
    this.diameter = 50,
  }) : super(key: key);

  @override
  _CircularTextBoxState createState() => _CircularTextBoxState();
}

class _CircularTextBoxState extends State<CircularTextBox> {
  late Color _colorBox;

  @override
  void initState() {
    super.initState();
    _colorBox = widget.defaultColorBox;
  }

  void changeColor(Color? color) {
    setState(() {
      if(color == null) {
        _colorBox = widget.defaultColorBox;
      }
      else {
        _colorBox = widget.highlightedColor;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.diameter,
      height: widget.diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _colorBox,
      ),
      alignment: Alignment.center,
      margin: EdgeInsets.all(5),
      child: Text(
        widget.text,
        style: TextStyle(
          color: widget.colorText,
          fontSize: widget.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

