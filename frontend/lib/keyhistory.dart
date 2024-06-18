import 'package:enigma/utils.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class KeyHistoryList extends StatefulWidget {
  const KeyHistoryList({super.key});

  @override
  State<KeyHistoryList> createState() => KeyHistoryState();

}

class KeyHistoryState extends State<KeyHistoryList> {
  static const maxKeys = 140;
  final List<MapEntry<String, String>> _keyHistory = [];

  @override
  void initState() {
    super.initState();
    // ToDo: Set machineId to the correct value
    loadKeyHistory();
    Cookie.setReactor("update_history", addKey);
  }

  void loadKeyHistory() async {
    var machineId = await Cookie.read("current_machine");
    /// Loads pressed keys from server
    final response = await APICaller.get("load_key_history", {
      "machine": machineId,
    });

    if (response.statusCode == 200) {
      final keyHistory = jsonDecode(response.body);

      setState(() {
        _keyHistory.clear();
        keyHistory.forEach((item) {
          _keyHistory.add(MapEntry(
            item[0].toString().toUpperCase(),
            item[1].toString().toUpperCase(),
          ));
        });
      });
    }
  }

  /*void addKey(String clear, String encrypted) {
    /// Add the key to the key history
    setState(() {
      _keyHistory.insert(0, MapEntry(clear, encrypted));
      if (_keyHistory.length > maxKeys) {
        _keyHistory.removeLast();
      }
    });
  }*/

  void addKey([Map<dynamic, dynamic> params = const {"clear": "O", "encrypted": "O"}]) {
    var clear = params["clear"].toString().toUpperCase();
    var encrypted = params["encrypted"].toString().toUpperCase();
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
