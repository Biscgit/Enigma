import 'package:flutter/material.dart';

class RotorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 150, 
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              RotorWidget(rotorNumber: 1),
              RotorWidget(rotorNumber: 2),
              RotorWidget(rotorNumber: 3),
              RotorWidget(rotorNumber: 4),
              RotorWidget(rotorNumber: 5),
            ],
          ),
        ),
      ),
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
  int? selectedRotor;
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
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Rotor ${widget.rotorNumber}', style: TextStyle(fontSize: 14)),
          DropdownButton<int?>(
            value: selectedRotor,
            items: [
              DropdownMenuItem<int?>(
                child: Text('Deaktiviert'),
                value: null,
              ),
              ...List.generate(5, (index) => DropdownMenuItem<int?>(
                child: Text('Rotor ${index + 1}'),
                value: index + 1,
              )),
            ],
            onChanged: (value) {
              setState(() {
                selectedRotor = value;
              });
            },
          ),
          SizedBox(height: 10),
          Text('Rotor drehen', style: TextStyle(fontSize: 10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () => _changeRingSetting(-1),
              ),
              Text('${ringSetting + 1} (${String.fromCharCode(65 + ringSetting)})',
                  style: TextStyle(fontSize: 14)),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _changeRingSetting(1),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text('Buchstabe drehen', style: TextStyle(fontSize: 10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () => _changePosition(-1),
              ),
              Text('${position + 1} (${String.fromCharCode(65 + position)})',
                  style: TextStyle(fontSize: 14)),
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
