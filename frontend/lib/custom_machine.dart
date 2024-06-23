import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main Page"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => SelectionPage()),
            );
          },
          child: Text("Go to Selection Page"),
        ),
      ),
    );
  }
}

class SelectionPage extends StatefulWidget {

  //SelectionPage({
    //this.itemsPlugboardToggle = ...,
    //this.itemsRotorenAuswahl = ...,
    //this.itemsUmkehrwalzen = ...,
  //})

  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  String? _selectedValuePlugboardToggle;
  String? _selectedValueRotorenAnzahl;
  String? _selectedValueRotorenAuswahl;
  String? _selectedValueUmkehrwalzen;

  late List<String> itemsRotorenAuswahl;
  late List<String> itemsUmkehrwalzen;

  bool get enableButton {
    return _selectedValuePlugboardToggle != null && 
           _selectedValueRotorenAnzahl != null &&
           _selectedValueRotorenAnzahl != 0 &&
           _selectedValueRotorenAuswahl != null &&
           _selectedValueUmkehrwalzen != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selection Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row with Drop-down menus
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text("Plugboard erlauben?"),
                    DropdownMenu(
                      selectedValue: _selectedValuePlugboardToggle,
                      onChanged: (value) {
                        setState(() {
                          _selectedValuePlugboardToggle = value;
                        });
                      },
                      items: ["Ja", "Nein"]
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text("Anzahl an Rotoren"),
                    DropdownMenu(
                      selectedValue: _selectedValueRotorenAnzahl,
                      onChanged: (value) {
                        setState(() {
                          _selectedValueRotorenAnzahl = value;
                        });
                      },
                      items: itemsRotorenAuswahl
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text("Auswählbare Rotoren"),
                    //DropdownMenu(
                    //  selectedValue: _selectedValueRotorenAuswahl,
                    //  onChanged: (value) {
                    //    setState(() {
                    //      _selectedValueRotorenAuswahl = value;
                    //    });
                    //  },
                    //),
                    TextField(
                      onChanged: (String value) {
                        setState(() {
                          _selectedValueRotorenAuswahl = value;
                        });
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    )
                  ],
                ),
                Column(
                  children: [
                    Text("Auswählbare Umkehrwalzen"),
                    DropdownMenu(
                      selectedValue: _selectedValueUmkehrwalzen,
                      onChanged: (value) {
                        setState(() {
                          _selectedValueUmkehrwalzen = value;
                        });
                      },
                      items: itemsUmkehrwalzen
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            // Buttons at the bottom right
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Perform some action
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DropdownMenu extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final List<String> items;

  DropdownMenu({
    required this.selectedValue,
    required this.onChanged,
    required this.items
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedValue,
      hint: Text("Select an option"),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
