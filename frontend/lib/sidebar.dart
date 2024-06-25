import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:enigma/utils.dart';

class SideBar extends StatelessWidget {
  final String username;

  SideBar({super.key, required this.username});

  String? _selectedValuePlugboardToggle;
  String? _selectedValueRotorenAnzahl;
  String? _selectedValueRotorenAuswahl;
  String? _selectedValueUmkehrwalzen;

  List<String> itemsRotorenAuswahl = ["1", "2", "3", "4", "5"];
  List<String> itemsUmkehrwalzen = ["A", "B", "C", "D", "E"];

  bool enableButton() {
    if (_selectedValueRotorenAnzahl == null) {
      return false;
    }
    return _selectedValuePlugboardToggle != null &&
        int.tryParse(_selectedValueRotorenAnzahl!) != 0 &&
        int.tryParse(_selectedValueRotorenAnzahl!) !=
            null && //Extra check for empty string
        _selectedValueRotorenAuswahl != null &&
        _selectedValueUmkehrwalzen != null;
  }

  Widget getHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
      child: Column(
        children: [
          Text(
            "Hallo $username!",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Text('Wähle deine Enigma')
        ],
      ),
    );
  }

  ListTile addMachine(BuildContext context) => ListTile(
      title: const Text('Neue Enigma'),
      onTap: () {
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: const Text("Neue Maschine"),
                  content: Container(
                    height: 200,
                    width: 800,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // Row with Drop-down menus
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  const Text("Plugboard erlauben?"),
                                  StatefulDropdownMenu(
                                    selectedValue:
                                        _selectedValuePlugboardToggle,
                                    onChanged: (value) {
                                      _selectedValuePlugboardToggle = value;
                                    },
                                    items: const ["Ja", "Nein"],
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text("Anzahl an Rotoren"),
                                  SizedBox(
                                      width: 150.0,
                                      height: 50.0,
                                      child: TextField(
                                        onChanged: (String value) {
                                          _selectedValueRotorenAnzahl = value;
                                        },
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]')),
                                        ],
                                      ))
                                ],
                              ),
                              Column(
                                children: [
                                  const Text("Auswählbare Rotoren"),
                                  StatefulDropdownMenu(
                                    selectedValue: _selectedValueRotorenAuswahl,
                                    onChanged: (value) {
                                      _selectedValueRotorenAuswahl = value;
                                    },
                                    items: itemsRotorenAuswahl,
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  const Text("Auswählbare Umkehrwalzen"),
                                  StatefulDropdownMenu(
                                    selectedValue: _selectedValueUmkehrwalzen,
                                    onChanged: (value) {
                                      _selectedValueUmkehrwalzen = value;
                                    },
                                    items: itemsUmkehrwalzen,
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
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Abbrechen"),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  enableButton()
                                      ? {
                                          // Perform some action
                                          _selectedValuePlugboardToggle = null,
                                          _selectedValueRotorenAnzahl = null,
                                          _selectedValueRotorenAuswahl = null,
                                          _selectedValueUmkehrwalzen = null,
                                          Navigator.of(context).pop()
                                        }
                                      : null;
                                },
                                child: const Text("Maschine erstellen"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ));
            });
      });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          getHeader(),
          const Machine(name: 'Enigma I', id: 1),
          const Machine(name: 'Norway Enigma', id: 2),
          const Machine(name: 'Enigma M3', id: 3),
          addMachine(context)
        ],
      ),
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

class Machine extends StatelessWidget {
  final String name;
  final int id;

  const Machine({super.key, required this.name, required this.id});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(name),
        onTap: () {
          Cookie.save("name", name)
              .then((_) => Cookie.save("current_machine", "$id"))
              .then((_) => Cookie.nukeReactors())
              .then((_) => Navigator.pop(context))
              .then((_) => Navigator.pushReplacementNamed(context, '/home'));
        });
  }
}
