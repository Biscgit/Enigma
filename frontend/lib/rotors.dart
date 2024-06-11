import 'package:flutter/material.dart';
import 'package:enigma/utils.dart';
import 'dart:convert';

class RotorPage extends StatelessWidget {
  final int number_rotors;

  const RotorPage({super.key, required this.number_rotors});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          number_rotors, (index) => RotorWidget(rotorNumber: index + 1)),
    );
  }
}

class RotorWidget extends StatefulWidget {
  final int rotorNumber;

  const RotorWidget({super.key, required this.rotorNumber});

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
    Cookie.setReactor("machine_id", _initialize);
  }

  Future<void> _initialize([String _ = ""]) async {
    machine_id = (await Cookie.read("current_machine")).codeUnitAt(0) - 47;

    rotor_ids = json.decode(
        (await APICaller.get("get-rotor-ids", {"machine_id": "$machine_id"}))
            .body);
    var rotor = json.decode((await APICaller.post("switch-rotor", body: {
      "template_id": get_id()
      "id": getId(),
      "machine_id": machine_id,
      "place": widget.rotorNumber
    }))
        .body);
    id = rotor["id"];

    setState(() {
      ringSetting = rotor["rotor_position"].codeUnitAt(0) - 97;
      notch = rotor["letter_shift"].codeUnitAt(0) - 97;
    });
  }

  void _changeRotorSetting(int? value) async {
    setState(() {
      selectedRotor = value!;
    });
    Map<String, dynamic> rotor = {};
    rotor["template_id"] = get_id();
    rotor["id"] = id;
    rotor["place"] = widget.rotorNumber;
    rotor["machine_id"] = machine_id;

    print(rotor);

    final response = await APICaller.post("switch-rotor", body: rotor);
    assert(response.statusCode == 200);
    rotor = jsonDecode(response.body);

    setState(() {
      notch = (rotor["letter_shift"] as String? ?? "a").codeUnitAt(0) - 97;
      ringSetting = (rotor["rotor_notch"] as String? ?? "a").codeUnitAt(0) - 97;
    });
  }

  int? getId() {
    return rotor_ids[selectedRotor - 1]["id"];
  }

  void _changeRingSetting(int change) async {
    setState(() {
      ringSetting = (ringSetting + change + 26) % 26;
    });
    var rotor =
        json.decode((await APICaller.get("get-rotor", {"rotor": "$id"})).body);
    rotor["rotor_notch"] = String.fromCharCode(97 + ringSetting);
    rotor["id"] = getId();
    APICaller.post("update-rotor", body: rotor);
  }

  void _changeNotch(int change) async {
    setState(() {
      notch = (notch + change + 26) % 26;
    });
    var rotor =
        json.decode((await APICaller.get("get-rotor", {"rotor": "$id"})).body);
    rotor["letter_shift"] = String.fromCharCode(97 + notch);
    rotor["id"] = getId();
    APICaller.post("update-rotor", body: rotor);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Rotor ${widget.rotorNumber}',
              style: const TextStyle(fontSize: 16)),
          DropdownButton<int>(
            value: selectedRotor,
            items: List.generate(
                number_rotors,
                (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('Rotor ${index + 1}'),
                    )),
            onChanged: _changeRotorSetting,
          ),
          const SizedBox(height: 10),
          const Text('Rotor drehen', style: TextStyle(fontSize: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => _changeRingSetting(-1),
              ),
              Text(String.fromCharCode(65 + ringSetting),
                  style: const TextStyle(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _changeRingSetting(1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Notch drehen', style: TextStyle(fontSize: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => _changeNotch(-1),
              ),
              Text(String.fromCharCode(65 + notch),
                  style: const TextStyle(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _changeNotch(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
