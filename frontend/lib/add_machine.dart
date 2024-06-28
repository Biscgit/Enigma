import 'package:enigma/sidebar_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:enigma/utils.dart';

class AddMachinePopUp extends StatefulWidget {
  const AddMachinePopUp({super.key});

  @override
  AddMachinePopUpState createState() => AddMachinePopUpState();
}

class AddMachinePopUpState extends State<AddMachinePopUp> {
  String? _selectedMachineName;
  bool? _selectedValuePlugboardToggle;
  String? _selectedValueRotorenAnzahl;
  List<String> _selectedValueRotorenAuswahl = [];
  List<String> _selectedValueUmkehrwalzen = [];

  List<String> itemsRotorenAuswahl = [];
  List<String> itemsUmkehrwalzen = [];

  bool enableButton() {
    if (_selectedValueRotorenAnzahl == null) {
      return false;
    }
    return _selectedMachineName != null &&
        _selectedMachineName != "" &&
        _selectedValuePlugboardToggle != null &&
        int.tryParse(_selectedValueRotorenAnzahl!) != 0 &&
        int.tryParse(_selectedValueRotorenAnzahl!) !=
            null && //Extra check for empty string
        _selectedValueRotorenAuswahl.isNotEmpty &&
        _selectedValueUmkehrwalzen.isNotEmpty;
  }

  Widget customMachineOptions({List<Widget> children = const []}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: children.map((child) {
          return Expanded(child: child);
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([getRotorIDs(), getUmkehrwalzenIDs()]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AlertDialog(
            title: Center(child: Text("Neue Maschine")),
            content: SizedBox(
              height: 350,
              width: 800,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("Error: ${snapshot.error}"),
            actions: <Widget>[
              TextButton(
                child: const Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        } else {
          var itemsRotorenAuswahl = snapshot.data![0] as List<String>;
          var itemsUmkehrwalzen = snapshot.data![1] as List<String>;

          return AlertDialog(
            title: const Center(child: Text("Neue Maschine")),
            content: SizedBox(
              height: 400,
              width: 800,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    // Row with Drop-down menus
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        customMachineOptions(
                          children: [
                            const Text("Name eingeben"),
                            SizedBox(
                              width: 200.0,
                              height: 50.0,
                              child: TextField(
                                onChanged: (String value) {
                                  _selectedMachineName = value;
                                },
                              ),
                            ),
                          ],
                        ),
                        customMachineOptions(
                          children: [
                            const Text("Plugboard erlauben?"),
                            StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                return Switch(
                                  value: _selectedValuePlugboardToggle ??= false,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedValuePlugboardToggle = value;
                                    });
                                  },
                                  activeColor: Colors.blue,
                                );
                              }
                            ),
                          ],
                        ),
                        customMachineOptions(
                          children: [
                            const Text("Anzahl an Rotoren (1-7)"),
                            SizedBox(
                              width: 150.0,
                              height: 50.0,
                              child: TextField(
                                onChanged: (String value) {
                                  _selectedValueRotorenAnzahl = value;
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^[1-7]$')),
                                ],
                              ),
                            ),
                          ],
                        ),
                        customMachineOptions(
                          children: [
                            const Text("Rotor(en) auswählen"),
                            //const Text("Auswählbare Rotoren"),
                            StatefulCheckboxMenu(
                                selectedValues: _selectedValueRotorenAuswahl,
                                onChanged: (value) {
                                  _selectedValueRotorenAuswahl = value;
                                },
                                items: itemsRotorenAuswahl,
                                name: "hier auswählen"),
                          ],
                        ),
                        customMachineOptions(
                          children: [
                            const Text("Umkehrwalze(n) auswählen"),
                            StatefulCheckboxMenu(
                              selectedValues: _selectedValueUmkehrwalzen,
                              onChanged: (value) {
                                _selectedValueUmkehrwalzen = value;
                              },
                              items: itemsUmkehrwalzen,
                              name: "hier auswählen",
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Buttons at the bottom right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.black),
                          child: const Text("Abbrechen"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (enableButton()) {
                              var rotorIds = _selectedValueRotorenAuswahl
                                  .map((rotor) => int.parse(RegExp(r'\d+')
                                      .firstMatch(rotor)!
                                      .group(0)!))
                                  .toList();
                              APICaller.post("add-machine", body: {
                                "name": _selectedMachineName,
                                "plugboard": _selectedValuePlugboardToggle,
                                "number_rotors": _selectedValueRotorenAnzahl,
                                "rotors": rotorIds,
                                "reflectors": _selectedValueUmkehrwalzen,
                              }).then((_) {
                                //Can be used for debugging

                                _selectedMachineName = null;
                                _selectedValuePlugboardToggle = null;
                                _selectedValueRotorenAnzahl = null;
                                _selectedValueRotorenAuswahl = [];
                                _selectedValueUmkehrwalzen = [];
                                Navigator.of(context).pop();
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black),
                          child: const Text("Maschine erstellen"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class StatefulDropdownMenu extends StatefulWidget {
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final List<String> items;

  const StatefulDropdownMenu({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    required this.items,
  });

  @override
  StatefulDropdownMenuState createState() => StatefulDropdownMenuState();
}

class StatefulDropdownMenuState extends State<StatefulDropdownMenu> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedValue,
      hint: Text(_selectedValue ?? "Select an option"),
      items: widget.items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedValue = value;
        });
        widget.onChanged(value);
      },
    );
  }
}

class StatefulCheckboxMenu extends StatefulWidget {
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;
  final List<String> items;
  final String name;

  const StatefulCheckboxMenu({
    super.key,
    required this.selectedValues,
    required this.onChanged,
    required this.items,
    required this.name,
  });

  @override
  StatefulCheckboxMenuState createState() => StatefulCheckboxMenuState();
}

class StatefulCheckboxMenuState extends State<StatefulCheckboxMenu> {
  List<String> _selectedValues = [];
  late String name;

  @override
  void initState() {
    super.initState();
    _selectedValues = widget.selectedValues;
    name = widget.name;
  }

  void _onItemCheckedChange(String itemValue, bool isChecked) {
    setState(() {
      if (isChecked) {
        _selectedValues.add(itemValue);
      } else {
        _selectedValues.remove(itemValue);
      }
      widget.onChanged(_selectedValues);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      child: Row(
        children: [
          Text(name),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            enabled: false,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 400,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.items.map((String item) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        final isChecked = _selectedValues.contains(item);
                        return CheckboxListTile(
                          title: Text(item),
                          value: isChecked,
                          onChanged: (bool? checked) {
                            setState(() {
                              _onItemCheckedChange(item, checked!);
                            });
                          },
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ];
      },
      onSelected: (_) {},
    );
  }
}
