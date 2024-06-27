import 'package:enigma/sidebar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:enigma/utils.dart';
import 'dart:convert';

class SideBar extends StatelessWidget {
  final String username;

  const SideBar({super.key, required this.username});


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

  Future<List<Widget>> getMachines() async {
    var machines = json.decode((await APICaller.get("get-machines")).body);
    var widgets = [getHeader()];
    for (var machine in machines) {
      widgets.add(Machine(
          name: machine["name"],
          id: machine["id"],
          numberRotors: machine["number_rotors"],
          key: ValueKey("sidebar.${machine["name"]}")));
    }
    return widgets;
  }

  ListTile addMachine(BuildContext context) {
    return ListTile(
      title: const Text('Neue Enigma'),
      onTap: () {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddMachinePopUp();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: getMachines(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator()],
          );
        } else {
          var data = snapshot.data!;
          data.add(addMachine(context));
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: data,
            ),
          );
        }
      },
    );
  }
}

class AddMachinePopUp extends StatefulWidget{

  @override
  AddMachinePopUpState createState() => AddMachinePopUpState();
}

class AddMachinePopUpState extends State<AddMachinePopUp>{

  String? _selectedValuePlugboardToggle;
  String? _selectedValueRotorenAnzahl;
  List<String> _selectedValueRotorenAuswahl = [];
  List<String> _selectedValueUmkehrwalzen = [];

  List<String> itemsRotorenAuswahl = [];
  List<String> itemsUmkehrwalzen = [];

  bool enableButton() {
    if (_selectedValueRotorenAnzahl == null) {
      return false;
    }
    return _selectedValuePlugboardToggle != null &&
        int.tryParse(_selectedValueRotorenAnzahl!) != 0 &&
        int.tryParse(_selectedValueRotorenAnzahl!) !=
            null && //Extra check for empty string
        _selectedValueRotorenAuswahl.isNotEmpty &&
        _selectedValueUmkehrwalzen.isNotEmpty;
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([getRotorIDs(), getUmkehrwalzenIDs()]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
            title: const Text("Neue Maschine"),
            content: SizedBox(
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
                              selectedValue: _selectedValuePlugboardToggle,
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
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            //const Text("Auswählbare Rotoren"),
                            StatefulCheckboxMenu(
                              selectedValues: _selectedValueRotorenAuswahl,
                              onChanged: (value) {
                                _selectedValueRotorenAuswahl = value;
                              },
                              items: itemsRotorenAuswahl,
                              name: "Rotor(en) auswählen"
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            StatefulCheckboxMenu(
                              selectedValues: _selectedValueUmkehrwalzen,
                              onChanged: (value) {
                                _selectedValueUmkehrwalzen = value;
                              },
                              items: itemsUmkehrwalzen,
                              name: "Umkehrwalze(n) auswählen",
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
                            if(enableButton()) {
                              //print("To print: $_selectedValuePlugboardToggle, $_selectedValueRotorenAnzahl, $_selectedValueRotorenAuswahl, $_selectedValueUmkehrwalzen");
                              //Can be used for debugging
                              _selectedValuePlugboardToggle = null;
                              _selectedValueRotorenAnzahl = null;
                              _selectedValueRotorenAuswahl = [];
                              _selectedValueUmkehrwalzen = [];
                              Navigator.of(context).pop();
                              // Add backend call here!
                              // Add new machine to sidebar as well!
                            }
                          },
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

class Machine extends StatelessWidget {
  final String name;
  final int id;
  final int numberRotors;

  const Machine(
      {super.key,
      required this.name,
      required this.id,
      required this.numberRotors});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(name),
        onTap: () {
          Cookie.save("name", name)
              .then((_) => Cookie.save("current_machine", "$id"))
              .then((_) => Cookie.save("numberRotors", "$numberRotors"))
              .then((_) => Cookie.nukeReactors())
              .then((_) => Navigator.pop(context))
              .then((_) => Navigator.pushReplacementNamed(context, '/home'));
        });
  }
}
