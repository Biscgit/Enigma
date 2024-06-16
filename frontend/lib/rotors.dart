import 'package:flutter/material.dart';
import 'package:enigma/utils.dart';
import 'dart:convert';

class Data {
  final String machineId;
  final List<dynamic> rotorIds;
  const Data({required this.machineId, required this.rotorIds});
}

class RotorPage extends StatelessWidget {
  final int numberRotors;
  const RotorPage({super.key, required this.numberRotors});

  Future<Data> _initialize() async {
    var machineId = await Cookie.read("current_machine");
    var rotorIds = json.decode((await APICaller.get("get-rotor-ids", {"machine_id": machineId})).body);
    return Data(
      machineId: machineId,
      rotorIds: rotorIds
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Data>(
      future: _initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator()],
          );
        } else {
          final data = snapshot.data!;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
            numberRotors, (index) => RotorWidget(rotorNumber: index + 1, machineId: data.machineId, rotorIds: data.rotorIds)),
          );
        }
      }
    );
  }
}

class RotorWidget extends StatefulWidget {
  final int rotorNumber;
  final String machineId;
  final List<dynamic> rotorIds;

  const RotorWidget({super.key, required this.rotorNumber, required this.machineId, required this.rotorIds});

  @override
  RotorWidgetState createState() => RotorWidgetState();
}

class RotorWidgetState extends State<RotorWidget> {
  int selectedRotor = 1;
  int rotorPosition = 0;
  int notch = 0;
  int numberRotors = 5;
  int id = 1;

  @override
  void initState() {
    super.initState();
    _getRotorNumber()
      .then((_) => apiCall())
      .then((_) => _initialize());
    Cookie.setReactor("update", _initialize);
  }

  Future<void> apiCall() async {
    await APICaller.post("switch-rotor", body: {
      "template_id": getId(),
      "id": getId(),
      "machine_id": widget.machineId,
      "place": widget.rotorNumber,
      "number": selectedRotor,
    });

  }

  Future<void> _getRotorNumber() async {
    var rotorNumber = json.decode((await APICaller.get("get-rotor-number", {"machine_id": widget.machineId, "place": "${widget.rotorNumber}"})).body);
    setState(() {
      selectedRotor = rotorNumber["number"];
    });
  }

  Future<void> _initialize() async {
    numberRotors = widget.rotorIds.length;

    var rotor = json.decode((await APICaller.get("get-rotor-by-place", {"machine_id": widget.machineId, "place": "${widget.rotorNumber}"})).body);
    id = rotor["id"];

    setState(() {
      rotorPosition = rotor["rotor_position"].codeUnitAt(0) - 97;
      notch = rotor["letter_shift"].codeUnitAt(0) - 97;
    });
  }

  void _changeRotorSetting(int? value) async {
    setState(() {
      selectedRotor = value!;
    });
    Map<String, dynamic> rotor = {};
    rotor["template_id"] = getId();
    rotor["id"] = id;
    rotor["place"] = widget.rotorNumber;
    rotor["machine_id"] = widget.machineId;
    rotor["number"] = value;

      final response = await APICaller.post("switch-rotor", body: rotor);
      assert(response.statusCode == 200);
      var getRotor = jsonDecode(response.body);

    setState(() {
      notch = (getRotor["letter_shift"] as String? ?? "a").codeUnitAt(0) - 97;
      rotorPosition = (getRotor["rotor_position"] as String? ?? "a").codeUnitAt(0) - 97;
    });
  }

  int? getId() {
    return widget.rotorIds[selectedRotor - 1]["id"];
  }

  void _changeRotorPosition(int change) async {
    setState(() {
      rotorPosition = (rotorPosition + change + 26) % 26;
    });
    var rotor =
        json.decode((await APICaller.get("get-rotor", {"rotor": "$id"})).body);
    rotor["rotor_position"] = String.fromCharCode(97 + rotorPosition);
    rotor["letter_shift"] = String.fromCharCode(97 + notch);
    rotor["id"] = id;
    rotor["number"] = selectedRotor;
    APICaller.post("update-rotor", body: rotor);
  }

  void _changeNotch(int change) async {
    setState(() {
      notch = (notch + change + 26) % 26;
    });
    var rotor =
        json.decode((await APICaller.get("get-rotor", {"rotor": "$id"})).body);
    rotor["letter_shift"] = String.fromCharCode(97 + notch);
    rotor["rotor_position"] = String.fromCharCode(97 + rotorPosition);
    rotor["id"] = id;
    rotor["number"] = selectedRotor;
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
                numberRotors,
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
                onPressed: () => _changeRotorPosition(-1),
              ),
              Text(String.fromCharCode(65 + rotorPosition),
                  style: const TextStyle(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _changeRotorPosition(1),
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
