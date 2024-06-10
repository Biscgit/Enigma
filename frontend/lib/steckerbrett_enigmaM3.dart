import 'package:flutter/material.dart';
import 'dart:math';

//Steckerbrett für die Enigma M3-ABC-Layout

//Beinhaltet:
// ABC-Layout für die Enigma M3
// 2 Buchstaben haben jeweils eine Farbe 
// Begrenzung auf 20 Paare + inklusive Fehler-Meldung
// Fehler-Meldung, dass eine Verknüfung gewählt werden muss
// Aufhebung der gewählten Buchstaben durch Backspace-Taste (noch optional)
// Reset-Button für Werkseinstellungen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enigma M3 Steckerbrett',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Enigma M3: ABC-Steckerbrett'),
        ),
        body: Center(
          child: CustomKeyboard(),
        ),
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
  final Map<String, Color> _letterColors = {};

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
              .where((color) => !_letterColors.containsValue(color))
              .toList();

          if (availableColors.isNotEmpty) {
            final randomColor =
                availableColors[Random().nextInt(availableColors.length)];
            _letterColors[value] = randomColor;
            _letterColors[_inputText[_inputText.length - 2]] = randomColor;
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
        if (!_letterColors.containsKey(value)) {
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
        List<String> keys = _letterColors.keys
            .where((key) => _letterColors[key] == _letterColors[value])
            .toList();

        for (String key in keys) {
          final charIndex = key.codeUnitAt(0) - 65;

          _inputText = _inputText.replaceAll(key, '');
          _letterColors.remove(key);

          _isButtonSelected[charIndex] = false;
          _selectedCount--;
        }
      }
    });
  }

  //void _onKeyPressed(String value, int index) {
    //if (_selectedCount < 20) {
      //setState(() {
        //_inputText += value;
        //_isButtonSelected[index] = !_isButtonSelected[index];
        //_selectedCount++;

        //if (!_letterColors.containsKey(value)) {
          // Zufällige Farbe auswählen und Buchstabe speichern
          //final randomColor = _availableColors[_selectedCount ~/ 2 % _availableColors.length];
          //_letterColors[value] = randomColor;

          // Farbe für den vorherigen Buchstaben festlegen
          //if (_inputText.length > 1) {
            //final prevChar = _inputText[_inputText.length - 2];
            //_letterColors[prevChar] = randomColor;
          //}
        //}
      //});
    //}
  //}

  //void _onDeletePressed() {
    //setState(() {
      //if (_inputText.isNotEmpty) {
        //final lastChar = _inputText.substring(_inputText.length - 1);
        //final charIndex = lastChar.codeUnitAt(0) - 65;
        //_inputText = _inputText.substring(0, _inputText.length - 1);
        //_isButtonSelected[charIndex] = false;
        //_selectedCount--;
      //}
    //});
  //}

  void _resetKeyboard() {
    setState(() {
      // Lösche die aktuellen Farben
      _letterColors.clear();
      
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

  Widget _buildKeyboardButton(String value, int index) {
    final isSelected = _isButtonSelected[value.codeUnitAt(0) - 65];
        final letterColor = _letterColors[value] ??
        const Color.fromARGB(255, 134, 182, 136); // Standardfarbe
        
    return ElevatedButton(
      onPressed: () {
        if (isSelected) {
          _onDeletePressed(value);
        } else {
          _onKeyPressed(value);
        }
      },

        // Fehler-Meldungen
        //if (_selectedCount == 20) {
          //_showSnackbar('Maximale Anzahl an wählbaren Verbindungen erreicht!', Colors.red);
        //} else if (_selectedCount == 1) {
          //_showSnackbar('Wähle mindestens zwei Buchstaben!', Colors.red);
        //}
      //},
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(60, 60),
        shape: const CircleBorder(),
        //backgroundColor: buttonColor,
        backgroundColor: isSelected
            ? letterColor
            : const Color.fromARGB(255, 34, 34, 34).withOpacity(0.1),
      ),
      child: Text(
        value,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  // Tastatur im ABC-Layout
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
            for (int i = 0; i < 10; i++) _buildKeyboardButton(String.fromCharCode(65 + i), i),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 10; i < 18; i++) _buildKeyboardButton(String.fromCharCode(65 + i), i),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 18; i < 26; i++) _buildKeyboardButton(String.fromCharCode(65 + i), i),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //IconButton(
            //  padding: EdgeInsets.all(0),
            //  icon: Icon(Icons.backspace),
            //  onPressed: _onDeletePressed,
            //),
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