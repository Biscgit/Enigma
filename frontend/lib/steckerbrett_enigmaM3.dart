import 'package:flutter/material.dart';

//Steckerbrett für die Enigma M3-ABC-Layout

// Steckerbrett für Enigma m3 im ABC-Layout

//Beinhaltet:
// ABC-Layout für die Enigma M3
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

  void _onKeyPressed(String value, int index) {
    if (_selectedCount < 20) {
      setState(() {
        _inputText += value;
        _isButtonSelected[index] = !_isButtonSelected[index];
        _selectedCount++;

        if (!_letterColors.containsKey(value)) {
          // Zufällige Farbe auswählen und Buchstabe speichern
          final randomColor = _availableColors[_selectedCount ~/ 2 % _availableColors.length];
          _letterColors[value] = randomColor;

          // Farbe für den vorherigen Buchstaben festlegen
          if (_inputText.length > 1) {
            final prevChar = _inputText[_inputText.length - 2];
            _letterColors[prevChar] = randomColor;
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
      _letterColors.clear();
      
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

  Widget _buildKeyboardButton(String value, int index) {
    final buttonColor = _isButtonSelected[index]
        ? _letterColors[value] ?? Colors.green
        : const Color.fromARGB(255, 34, 34, 34).withOpacity(0.1);
        
    return ElevatedButton(
      onPressed: () {
        if (_isButtonSelected[index]) {
          _onDeletePressed();
        } else {
          _onKeyPressed(value, index);
        }

        // Fehler-Meldungen
        if (_selectedCount == 20) {
          _showSnackbar('Maximale Anzahl an wählbaren Verbindungen erreicht!', Colors.red);
        } else if (_selectedCount == 1) {
          _showSnackbar('Wähle mindestens zwei Buchstaben!', Colors.red);
        }
      },
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(60, 60),
        shape: const CircleBorder(),
        backgroundColor: buttonColor,
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
