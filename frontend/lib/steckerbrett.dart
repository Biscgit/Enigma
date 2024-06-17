import 'dart:collection';
import 'dart:convert';
import 'package:enigma/utils.dart';
import 'package:flutter/material.dart';
import 'dart:math';

mixin SteckbrettMethods<T extends StatefulWidget> on State<T> {
  String _inputText = '';
  bool _isEnabled = true;

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

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      final result = await APICaller.get("plugboard/load", {
        "machine": "1",
      });
      assert(result.statusCode == 200);
      final plugs = jsonDecode(result.body)["plugboard"];

      _selectedCount = plugs.length;
      setState(() {
        for (var plug in plugs) {
          final availableColors = _availableColors
              .where((color) => !_letterColorMap.containsValue(color))
              .toList();
          final randomColor =
              availableColors[Random().nextInt(availableColors.length)];

          // make plugs uppercase for frontend
          plug[0] = plug[0].toString().toUpperCase();
          plug[1] = plug[1].toString().toUpperCase();

          final charIndex1 = plug[0].codeUnitAt(0) - 65;
          _letterColorMap[plug[0]] = randomColor;
          _isButtonSelected[charIndex1] = true;
          _inputText += plug[0];

          final charIndex2 = plug[1].codeUnitAt(0) - 65;
          _letterColorMap[plug[1]] = randomColor;
          _isButtonSelected[charIndex2] = true;
          _inputText += plug[1];
        }
      });
    });
  }

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
            APICaller.post(
              "plugboard/save",
              query: {
                "machine": "1",
                "plug_a": value.toLowerCase(),
                "plug_b": _inputText[_inputText.length - 2].toLowerCase(),
              },
            );
          } else {
            _showSnackbar("A selection error has occurred!", Colors.red);
          }
        }
      });
    } else {
      _showSnackbar(
          'Maximum number of selectable connections reached!', Colors.red);
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

        // api call to delete in backend
        if (keys.length % 2 == 0) {
          APICaller.delete("plugboard/remove", query: {
            "machine": "1",
            "plug_a": keys[0].toLowerCase(),
            "plug_b": keys[1].toLowerCase(),
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

  Future<void> _resetKeyboard() async {
    List<String> allKeys = [];

    // remove all from DB
    final clonedColors = HashMap.from(_letterColorMap);
    while (clonedColors.isNotEmpty) {
      final color = clonedColors[clonedColors.keys.first];
      List keys =
          clonedColors.keys.where((key) => clonedColors[key] == color).toList();

      // need to do sequentially for backend
      final response = await APICaller.delete("plugboard/remove", query: {
        "machine": "1",
        "plug_a": keys[0],
        "plug_b": keys[1],
      });
      assert(response.statusCode == 200);

      for (String key in keys) {
        allKeys.add(key);
        clonedColors.remove(key);
      }
    }

    setState(() {
      // delete all keys
      for (var key in allKeys) {
        _letterColorMap.remove(key);
      }

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
        fixedSize: const Size(50, 50),
        shape: const CircleBorder(),
        backgroundColor: isSelected
            ? letterColor
            : const Color.fromARGB(255, 34, 34, 34).withOpacity(0.1),
      ),
      child: Text(
        value,
        style: const TextStyle(
            color: Color.fromARGB(247, 255, 255, 255), fontSize: 18),
      ),
    );
  }

  Widget toggleSwitch() {
    return Switch(
      value: _isEnabled,
      onChanged: (value) async {
        final response = await APICaller.post("plugboard/enable", query: {
          "machine": "1",
          "enabled": "$value",
        });
        assert(response.statusCode == 200);

        setState(() {
          _isEnabled = value;
        });
      },
      activeColor: Colors.blue,
    );
  }
}

class SteckbrettEnigma1 extends StatefulWidget {
  const SteckbrettEnigma1({super.key});

  @override
  SteckbrettEnigma1State createState() => SteckbrettEnigma1State();
}

class SteckbrettEnigma1State extends State<SteckbrettEnigma1>
    with SteckbrettMethods {
  // Tastatur mit QWERTZ-Layout
  @override
  Widget build(BuildContext context) {
    final switchW = toggleSwitch();
    return _isEnabled
        ? Container(
            decoration: BoxDecoration(
              color: Colors.white10,
              border: Border.all(
                color: Colors.blue.withAlpha(25), // Specify border color
                width: 4, // Specify border width
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
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
                Wrap(
                  alignment: WrapAlignment.center,
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
                Wrap(
                  alignment: WrapAlignment.center,
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
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: _resetKeyboard,
                  child: const Text('Reset'),
                ),
                const SizedBox(height: 3),
                switchW,
              ],
            ),
          )
        : switchW;
  }
}

class SteckbrettEnigma3 extends StatefulWidget {
  const SteckbrettEnigma3({super.key});

  @override
  SteckbrettEnigma3State createState() => SteckbrettEnigma3State();
}

class SteckbrettEnigma3State extends State<SteckbrettEnigma3>
    with SteckbrettMethods {
  @override
  Widget build(BuildContext context) {
    final switchW = Switch(
      value: _isEnabled,
      onChanged: (value) async {
        final response = await APICaller.post("plugboard/enable", query: {
          "machine": "1",
          "enabled": "$value",
        });
        assert(response.statusCode == 200);

        setState(() {
          _isEnabled = value;
        });
      },
      activeColor: Colors.blue,
    );
    return _isEnabled
        ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 10; i++)
                    _buildKeyboardButton(String.fromCharCode(65 + i)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 10; i < 18; i++)
                    _buildKeyboardButton(String.fromCharCode(65 + i)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 18; i < 26; i++)
                    _buildKeyboardButton(String.fromCharCode(65 + i)),
                ],
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: _resetKeyboard,
                child: const Text('Reset'),
              ),
              const SizedBox(height: 3),
              switchW,
            ],
          )
        : switchW;
  }
}
