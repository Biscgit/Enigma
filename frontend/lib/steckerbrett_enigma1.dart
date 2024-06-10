import 'package:enigma/utils.dart';
import 'package:flutter/material.dart';
import 'dart:math';

// Steckerbrett für Enigma I und Naval-Enigma im QWERTZU-Layout

//Beinhaltet:
//QUWERTZU-Layout für die Enigma1 und Naval Enigma
// 2 Buchstaben haben jeweils eine Farbe
// Begrenzung auf 20 Paare + inklusive Fehler-Meldung
// Fehler-Meldung, dass eine Verknüfung gewählt werden muss
// Aufhebung der gewählten Buchstaben durch Backspace-Taste
// Reset-Button für Werkseinstellungen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enigma I Steckerbrett',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Enigma I: QWERTZU-Steckerbrett'),
          centerTitle: true, // Titel zentrieren
        ),
        body: CustomKeyboard(),
      ),
    );
  }
}

class CustomKeyboard extends StatefulWidget {
  @override
  _CustomKeyboardState createState() => _CustomKeyboardState();
}

class _CustomKeyboardState extends State<CustomKeyboard> {
  String _inputText = '';
  List<bool> _isButtonSelected = List.generate(26, (_) => false);
  int _selectedCount = 0;
  final List<Color> _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
  ];

  // Dictionary, um Buchstabenpaare und ihre Farben zu speichern
  final Map<String, Color> _letterColorMap = {};

  void _onKeyPressed(String value) {
    if (_selectedCount < 20) {
      setState(() {
        _inputText += value;
        final charIndex = value.codeUnitAt(0) - 65;
        _isButtonSelected[charIndex] = true;
        _selectedCount++;

        if (_selectedCount % 2 == 0) {
          // Wähle eine zufällige Farbe für das Buchstabenpaar, die noch nicht verwendet wurde
          final availableColors = _availableColors
              .where((color) => !_letterColorMap.containsValue(color))
              .toList();

          if (availableColors.isNotEmpty) {
            final randomColor =
                availableColors[Random().nextInt(availableColors.length)];
            _letterColorMap[value] = randomColor;
            _letterColorMap[_inputText[_inputText.length - 2]] = randomColor;

            // api call to save in backend
            APICaller.post("plugboard/save", {
              "machine": 1,
              "plug_a": value,
              "plug_b": _inputText[_inputText.length - 2],
            });
          } else {
            _showSnackbar("A selection error has occurred!", Colors.red);
          }
        }
      });
    } else {
      _showSnackbar(
          'Maximale Anzahl an wählbaren Verbindungen erreicht!', Colors.red);
    }
  }

  void _onDeletePressed(String value) {
    setState(() {
      // check for selected button -> easy fix
      final charIndex = value.codeUnitAt(0) - 65;
      if (_isButtonSelected[charIndex] && _selectedCount % 2 == 1) {
        // if is self, then unselect
        if (!_letterColorMap.containsKey(value)) {
          _isButtonSelected[charIndex] = false;
          _selectedCount--;
          _inputText = _inputText.replaceAll(value, '');
        } else {
          _showSnackbar("This plug is already in use, select another one!",
              Colors.redAccent);
        }
        return;
      }

      if (_selectedCount > 0) {
        // get both keys with the same color
        List<String> keys = _letterColorMap.keys
            .where((key) => _letterColorMap[key] == _letterColorMap[value])
            .toList();

        // api call to save in backend
        if (keys.length % 2 == 0) {
          APICaller.delete("plugboard/remove", {
            "machine": 1,
            "plug_a": keys[0],
            "plug_b": keys[1],
          });
        }

        for (String key in keys) {
          final charIndex = key.codeUnitAt(0) - 65;

          _inputText = _inputText.replaceAll(key, '');
          _letterColorMap.remove(key);

          _isButtonSelected[charIndex] = false;
          _selectedCount--;
        }
      }
    });
  }

  void _resetKeyboard() {
    setState(() {
      // Lösche die aktuellen Farben
      _letterColorMap.clear();

      _inputText = '';
      _isButtonSelected = List.generate(26, (_) => false);
      _selectedCount = 0;
    });
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3)),
    );
  }

  Widget _buildKeyboardButton(String value) {
    final isSelected = _isButtonSelected[value.codeUnitAt(0) - 65];
    final letterColor = _letterColorMap[value] ??
        const Color.fromARGB(255, 134, 182, 136); // Standardfarbe

    return ElevatedButton(
      onPressed: () {
        if (isSelected) {
          _onDeletePressed(value);
        } else {
          _onKeyPressed(value);
        }
      },
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(60, 60),
        shape: const CircleBorder(),
        backgroundColor: isSelected
            ? letterColor
            : const Color.fromARGB(255, 34, 34, 34).withOpacity(0.1),
      ),
      child: Text(
        value,
        style:
            TextStyle(color: Color.fromARGB(247, 255, 255, 255), fontSize: 18),
      ),
    );
  }

  // Tastatur mit QWERTZU-Layout
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          _inputText,
          style: TextStyle(fontSize: 20.0),
        ),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKeyboardButton('Q'),
            _buildKeyboardButton('W'),
            _buildKeyboardButton('E'),
            _buildKeyboardButton('R'),
            _buildKeyboardButton('T'),
            _buildKeyboardButton('Z'),
            _buildKeyboardButton('U'),
            _buildKeyboardButton('I'),
            _buildKeyboardButton('O'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKeyboardButton('A'),
            _buildKeyboardButton('S'),
            _buildKeyboardButton('D'),
            _buildKeyboardButton('F'),
            _buildKeyboardButton('G'),
            _buildKeyboardButton('H'),
            _buildKeyboardButton('J'),
            _buildKeyboardButton('K'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKeyboardButton('P'),
            _buildKeyboardButton('Y'),
            _buildKeyboardButton('X'),
            _buildKeyboardButton('C'),
            _buildKeyboardButton('V'),
            _buildKeyboardButton('B'),
            _buildKeyboardButton('N'),
            _buildKeyboardButton('M'),
            _buildKeyboardButton('L'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // IconButton(
            //   padding: EdgeInsets.all(0),
            //   icon: Icon(Icons.backspace),
            //   onPressed: _onDeletePressed,
            // ),
            ElevatedButton(
              onPressed: _resetKeyboard,
              child: Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}
