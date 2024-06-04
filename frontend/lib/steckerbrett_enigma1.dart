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
          title: const Text('Enigma I: QWERTZU-Steckerbrett'
        ),
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
  List<Color> _availableColors = [
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
  Map<String, Color> _letterColorMap = {};

  void _onKeyPressed(String value) {
    if (_selectedCount < 20) {
      setState(() {
        _inputText += value;
        final charIndex = value.codeUnitAt(0) - 65;
        _isButtonSelected[charIndex] = true;
        _selectedCount++;

        if (_selectedCount % 2 == 0) {
        // Wähle eine zufällige Farbe für das Buchstabenpaar, die noch nicht verwendet wurde
        final availableColors = _availableColors.where((color) => !_letterColorMap.containsValue(color)).toList();
        if (availableColors.isNotEmpty) {
          final randomColor = availableColors[Random().nextInt(availableColors.length)];
          _letterColorMap[value] = randomColor;
          _letterColorMap[_inputText[_inputText.length - 2]] = randomColor;
        }
      }
      });
    }
  }

  void _onDeletePressed() {
    setState(() {
      if (_inputText.isNotEmpty) {
        final lastChar = _inputText.substring(_inputText.length - 1);
        final charIndex = lastChar.codeUnitAt(0) - 65;
        _inputText = _inputText.substring(0, _inputText.length - 1);
        _isButtonSelected[charIndex] = false;
        _selectedCount--;
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  Widget _buildKeyboardButton(String value) {
    final isSelected = _isButtonSelected[value.codeUnitAt(0) - 65];
    final letterColor = _letterColorMap[value] ?? const Color.fromARGB(255, 134, 182, 136); // Standardfarbe
    
    return ElevatedButton(
      onPressed: () {
        if (isSelected) {
          _onDeletePressed();
        } else {
          _onKeyPressed(value);
        }

        //Fehler-Meldungen
        if (_selectedCount == 20) {
          _showSnackbar('Maximale Anzahl an wählbaren Verbindungen erreicht!', Colors.red);
        } else if (_selectedCount == 1) {
          _showSnackbar('Wähle mindestens zwei Buchstaben!', Colors.red);
        }
      },
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(60, 60),
        shape: const CircleBorder(),
        backgroundColor: isSelected ? letterColor : const Color.fromARGB(255, 34, 34, 34).withOpacity(0.1),
      ),
      child: Text(
        value,
        style: TextStyle(color: Color.fromARGB(247, 255, 255, 255), fontSize: 18),
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
            IconButton(
              padding: EdgeInsets.all(0),
              icon: Icon(Icons.backspace),
              onPressed: _onDeletePressed,
            ),
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