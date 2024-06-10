import 'package:enigma/utils.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Tastatur());
}

class Tastatur extends StatefulWidget {
  const Tastatur({super.key});

  @override
  State<Tastatur> createState() => TastaturState();
}

void sendPressedKeyToRotors(String s) async {
  String token = await Cookie.read('token');
  String machineID = await Cookie.read('machineID');
  Map<String, dynamic> body = {
    'token': token,
    'key': s,
    'machine': machineID
  };
  APICaller.post("key_press", body);
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
            const Row(
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
            const Row(
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
            const Row(
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
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      key: ValueKey("Tastatur-Button-$label"), 
      child: ElevatedButton(
        onPressed: () {
          sendPressedKeyToRotors(label);
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