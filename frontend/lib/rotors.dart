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
      children: List.generate(
          this.number_rotors, (index) => RotorWidget(rotorNumber: index + 1)),
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
  int notch = 0;
  int number_rotors = 5;
  int machine_id = 1;
  int id = 1;
  List<dynamic> rotor_ids = [
    {"": 0}
  ];

  @override
  void initState() {
    super.initState();
    _initialize();
    Cookie.setReactor("machine_id", this._initialize);
  }

  Future<void> _initialize([String _ = ""]) async {
    this.machine_id = (await Cookie.read("current_machine")).codeUnitAt(0) - 47;

    this.rotor_ids = json.decode((await APICaller.get(
            "get-rotor-ids", {"machine_id": "${this.machine_id}"}))
        .body);
    var rotor = json.decode((await APICaller.post("switch-rotor", body: {
      "id": this.get_id(),
      "machine_id": this.machine_id,
      "place": widget.rotorNumber,
      "template_id": this.get_id()
    }))
        .body);
    this.id = rotor["id"];

    setState(() {
      this.ringSetting = rotor["rotor_position"].codeUnitAt(0) - 97;
      this.notch = rotor["letter_shift"].codeUnitAt(0) - 97;
    });
  }

  void _changeRotorSetting(int? value) async {
    setState(() {
      this.selectedRotor = value!;
    });
    Map<String, dynamic> rotor = {};
    rotor["id"] = this.id;
    rotor["template_id"] = get_id();
    rotor["place"] = widget.rotorNumber;
    rotor["machine_id"] = this.machine_id;

    print(rotor);

    final response = await APICaller.post("switch-rotor", body: rotor);
    assert(response.statusCode == 200);
    rotor = jsonDecode(response.body);

    setState(() {
      this.notch = (rotor["letter_shift"] as String? ?? "a").codeUnitAt(0) - 97;
      this.ringSetting =
          (rotor["rotor_notch"] as String? ?? "a").codeUnitAt(0) - 97;
    });
  }

  int? get_id() {
    return this.rotor_ids[this.selectedRotor - 1]["id"];
  }

  void _changeRingSetting(int change) async {
    setState(() {
      ringSetting = (ringSetting + change + 26) % 26;
    });
    var rotor = json.decode(
        (await APICaller.get("get-rotor", {"rotor": "${this.id}"})).body);
    rotor["rotor_notch"] = String.fromCharCode(97 + this.ringSetting);
    rotor["id"] = this.get_id();
    APICaller.post("update-rotor", body: rotor);
  }

  void _changeNotch(int change) async {
    setState(() {
      notch = (notch + change + 26) % 26;
    });
    var rotor = json.decode(
        (await APICaller.get("get-rotor", {"rotor": "${this.id}"})).body);
    rotor["letter_shift"] = String.fromCharCode(97 + notch);
    rotor["id"] = this.get_id();
    APICaller.post("update-rotor", body: rotor);
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
                this.number_rotors,
                (index) => DropdownMenuItem(
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
              Text('${String.fromCharCode(65 + this.ringSetting)}',
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
                onPressed: () => _changeNotch(-1),
              ),
              Text('${String.fromCharCode(65 + this.notch)}',
                  style: TextStyle(fontSize: 16)),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _changeNotch(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
