import 'package:flutter/material.dart';

class RotorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enigma Rotors'),
      ),
      body: Stack(
        children: [
          Center(
            child: EnigmaWidget(),
          ),
          Positioned(
            top: 20,
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: FloatingActionButton.extended(
              onPressed: () {
                // Logik für den Startbutton kommt hierhin
              },
              label: Text(
                  'Start'), //Speicherbutton, falls nicht benötigt, wieder entfernen
              backgroundColor: Colors.green,
              icon: Icon(Icons.play_arrow, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: () {
                // Hier evtl. die Logik für Speicherbutton, falls dieser auf der Rotorseite sein soll
              },
              label: Text('Konfiguration speichern',
                  style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.lightBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class EnigmaWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          List.generate(5, (index) => RotorWidget(rotorNumber: index + 1)),
    );
  }
}

class RotorWidget extends StatefulWidget {
  final int rotorNumber;
  RotorWidget({required this.rotorNumber});

  @override
  _RotorWidgetState createState() => _RotorWidgetState();
}

class _RotorWidgetState extends State<RotorWidget> {
  int selectedRotor = 1;
  int ringSetting = 0;
  int position = 0;

  void _changeRingSetting(int change) {
    setState(() {
      ringSetting = (ringSetting + change + 26) % 26;
    });
  }

  void _changePosition(int change) {
    setState(() {
      position = (position + change + 26) % 26;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Rotor ${widget.rotorNumber}', style: TextStyle(fontSize: 16)),
          DropdownButton<int>(
            value: selectedRotor,
            items: List.generate(
                5,
                (index) => DropdownMenuItem(
                      child: Text('Rotor ${index + 1}'),
                      value: index + 1,
                    )),
            onChanged: (value) {
              setState(() {
                selectedRotor = value!;
              });
            },
          ),
          SizedBox(height: 10),
          Text('Rotor drehen', style: TextStyle(fontSize: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () => _changeRingSetting(-1),
              ),
              Text(
                  '${ringSetting + 1} (${String.fromCharCode(65 + ringSetting)})',
                  style: TextStyle(fontSize: 16)),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _changeRingSetting(1),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text('Buchstaben drehen', style: TextStyle(fontSize: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () => _changePosition(-1),
              ),
              Text('${position + 1} (${String.fromCharCode(65 + position)})',
                  style: TextStyle(fontSize: 16)),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _changePosition(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
