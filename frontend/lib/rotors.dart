import 'package:flutter/material.dart';
import 'package:enigma/utils.dart';
import 'dart:convert';

class RotorPage extends StatelessWidget {
  final int number_rotors;

  RotorPage({required this.number_rotors});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(this.number_rotors, (index) => RotorWidget(rotorNumber: index + 1)),
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
  int number_rotors = 5;
  List<Map<String, int>> rotor_ids = [{"": 0}];

  void _changeRotorSetting(int? value) {
    setState(() async {
      this.rotor_ids = json.decode((await APICaller.get("get-rotor-ids", {"machine_id": await Cookie.read("current_machine")})).body);
      this.selectedRotor = value!;
      var rotor = json.decode((await APICaller.get("get-rotor", {"rotor": this.get_id()})).body);
      this.ringSetting = rotor["rotor_position"].codeUnitAt(0) - 97;
      this.position = rotor["letter_shift"].codeUnitAt(0) - 97;
    });
  }

  int? get_id() {
        return this.rotor_ids[this.selectedRotor]["id"];
    }

  void _changeRingSetting(int change) async {
    setState(() {
      ringSetting = (ringSetting + change + 26) % 26;
    });
    var rotor = json.decode((await APICaller.get("get-rotor", {"rotor": this.get_id()})).body);
    rotor["rotor_position"] = String.fromCharCode(97 + this.ringSetting);
    rotor["id"] = this.get_id();
    APICaller.post("update-rotor", rotor);
  }

  void _changePosition(int change) async {
    setState(() {
      position = (position + change + 26) % 26;
    });
    var rotor = json.decode((await APICaller.get("get-rotor", {"rotor": this.get_id()})).body);
    rotor["letter_shift"] = String.fromCharCode(97 + position);
    rotor["id"] = this.get_id();
    APICaller.post("update-rotor", rotor);
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
            items: List.generate(this.number_rotors, (index) => DropdownMenuItem(
              child: Text('Rotor ${index + 1}'),
              value: index + 1,
            )),
            onChanged: _changeRotorSetting,
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
              Text('${String.fromCharCode(65 + ringSetting)}',
                  style: TextStyle(fontSize: 16)),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _changeRingSetting(1),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text('Notch drehen', style: TextStyle(fontSize: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () => _changePosition(-1),
              ),
              Text('${String.fromCharCode(65 + position)}',
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
