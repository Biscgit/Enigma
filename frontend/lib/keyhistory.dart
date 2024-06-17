import 'package:enigma/utils.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class KeyHistoryList extends StatefulWidget {
  final GlobalKey<KeyHistoryState> keyHistoryKey;

  const KeyHistoryList({super.key, required this.keyHistoryKey});

  @override
  State<KeyHistoryList> createState() => KeyHistoryState();

  void addKey(String clear, String encrypted) {
    keyHistoryKey.currentState!.addKey(
      clear.toUpperCase(),
      encrypted.toUpperCase(),
    );
  }
}

class KeyHistoryState extends State<KeyHistoryList> {
  static const maxKeys = 140;

  final List<MapEntry<String, String>> _keyHistory =
      <MapEntry<String, String>>[];

  void loadKeyHistory(String machineId, String token) async {
    /// Loads pressed keys from server
    final response = await APICaller.get("keyhistory/load", {"machine": machineId});

    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> keyHistory =
          List<Map<String, dynamic>>.from(jsonDecode(response.body));
      setState(() {
        _keyHistory.clear();
        _keyHistory.addAll(keyHistory.map((item) =>
            MapEntry(item['clear'] as String, item['encrypted'] as String)));
      });
    }
  }

  void addKey(String clear, String encrypted) {
    /// Add the key to the key history
    setState(() {
      _keyHistory.insert(0, MapEntry(clear, encrypted));
      if (_keyHistory.length > maxKeys) {
        _keyHistory.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const tStyle = TextStyle(
      color: Colors.blue,
      fontFamily: "monospace",
      fontSize: 22,
      fontWeight: FontWeight.bold,
    );
    return ListView.builder(
      key: const ValueKey('keyHistoryList'),
      // shrinkWrap: true,
      itemCount: _keyHistory.length,
      itemBuilder: (context, index) {
        final keyPair = _keyHistory[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    '${index + 1}.',
                    style: tStyle,
                  ),
                ),
                Text(
                  '${keyPair.key} → ${keyPair.value}',
                  style: tStyle,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
