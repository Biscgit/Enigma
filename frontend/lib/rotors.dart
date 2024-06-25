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
    var rotorIds = json.decode(
        (await APICaller.get("get-rotor-ids", {"machine_id": machineId})).body);
    return Data(machineId: machineId, rotorIds: rotorIds);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Data>(
        future: _initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator()],
            );
          } else {
            final data = snapshot.data!;
            return Wrap(
              spacing: 8.0, // Horizontal spacing between children
              runSpacing: 8.0,
              children: List.generate(
                  numberRotors,
                  (index) => RotorWidget(
                      rotorNumber: index + 1,
                      machineId: data.machineId,
                      rotorIds: data.rotorIds)),
            );
          }
        });
  }
}

class RotorWidget extends StatefulWidget {
  final int rotorNumber;
  final String machineId;
  final List<dynamic> rotorIds;

  const RotorWidget(
      {super.key,
      required this.rotorNumber,
      required this.machineId,
      required this.rotorIds});

  @override
  RotorWidgetState createState() => RotorWidgetState();
}

class RotorWidgetState extends State<RotorWidget> {
  int selectedRotor = 1;
  int rotorPosition = 0;
  String notch = "a";
  int numberRotors = 5;
  int id = 1;

  @override
  void initState() {
    super.initState();
    _getRotorNumber().then((_) => apiCall()).then((_) => _initialize());
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
    var rotorNumber = json.decode((await APICaller.get("get-rotor-number",
            {"machine_id": widget.machineId, "place": "${widget.rotorNumber}"}))
        .body);
    setState(() {
      selectedRotor = rotorNumber["number"];
    });
  }

  Future<void> _initialize([Map<dynamic, dynamic> params = const {}]) async {
    numberRotors = widget.rotorIds.length;

    var rotor = json.decode((await APICaller.get("get-rotor-by-place",
            {"machine_id": widget.machineId, "place": "${widget.rotorNumber}"}))
        .body);
    id = rotor["id"];

    setState(() {
      rotorPosition = rotor["rotor_position"].codeUnitAt(0) - 97;
      notch = rotor["letter_shift"];
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
      rotorPosition =
          (getRotor["rotor_position"] as String? ?? "a").codeUnitAt(0) - 97;
      notch = getRotor["letter_shift"] as String? ?? "a";
    });

    Cookie.trigger("set_focus_keyboard");
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
    rotor["letter_shift"] = notch;
    rotor["id"] = id;
    rotor["number"] = selectedRotor;
    APICaller.post("update-rotor", body: rotor);
  }

  void _changeLetterPosition(int change) async {
    setState(() {
      rotorPosition = (rotorPosition + change + 26) % 26;
      notch = String.fromCharCodes(notch
          .toLowerCase()
          .split('')
          .map((pos) => 97 + ((pos.codeUnitAt(0) - 97) + change + 26) % 26));
    });
    var rotor =
        json.decode((await APICaller.get("get-rotor", {"rotor": "$id"})).body);
    rotor["rotor_position"] = String.fromCharCode(97 + rotorPosition);
    rotor["letter_shift"] = notch;
    rotor["id"] = id;
    rotor["number"] = selectedRotor;
    APICaller.post("update-rotor", body: rotor);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Rotor ${widget.rotorNumber}',
            style: const TextStyle(fontSize: 16),
          ),
          DropdownButton<int>(
            value: selectedRotor,
            items: List.generate(
                numberRotors,
                (index) => DropdownMenuItem(
                      value: index + 1,
                      key: ValueKey("DropDown.${widget.rotorNumber}"),
                      child: Text(
                        'Rotor ${index + 1}',
                        key: ValueKey(
                            "Item.${widget.rotorNumber}.$selectedRotor"),
                      ),
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
                  key: ValueKey("ChangeRotor.${widget.rotorNumber}.minus")),
              Container(
                alignment: Alignment.center,
                width: 16,
                child: Text(
                  String.fromCharCode(65 + rotorPosition),
                  style: const TextStyle(fontSize: 16),
                  key: ValueKey("RotorPosition.${widget.rotorNumber}"),
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _changeRotorPosition(1),
                  key: ValueKey("ChangeRotor.${widget.rotorNumber}.plus")),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Buchstaben drehen', style: TextStyle(fontSize: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _changeLetterPosition(-1),
                  key: ValueKey("ChangeLetter.${widget.rotorNumber}.minus")),
              IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _changeLetterPosition(1),
                  key: ValueKey("ChangeLetter.${widget.rotorNumber}.plus")),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Notch', style: TextStyle(fontSize: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(notch.toUpperCase(),
                  style: const TextStyle(fontSize: 16),
                  key: ValueKey("Notch.${widget.rotorNumber}")),
            ],
          ),
        ],
      ),
    );
  }
}
