import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class KeyHistoryList extends StatefulWidget {
  const KeyHistoryList({super.key});

  @override
  State<KeyHistoryList> createState() => _KeyHistoryState();
}

class _KeyHistoryState extends State<KeyHistoryList> {
  static const String apiUrl = 'http://172.20.0.101:8001/login';
  static const maxKeys = 140;

  final List<MapEntry<String, String>> _keyHistory = <MapEntry<String, String>>[];

  void loadKeyHistory(String machineId, String token) async {
    /// Loads pressed keys from server
    var response = await http.get(
      Uri.parse(
        '$apiUrl/keyhistory/load?token=$token&machine=$machineId',
      ),
    );

    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> keyHistory = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      setState(() {
        _keyHistory.clear();
        _keyHistory.addAll(keyHistory.map((item) => MapEntry(item['clear'] as String, item['encrypted'] as String)));
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
    return ListView.builder(
      key: const ValueKey('keyHistoryList'),
      itemCount: _keyHistory.length,
      itemBuilder: (context, index) {
        final keyPair = _keyHistory[index];
        return ListTile(
          title: Text(
            '${keyPair.key} -> ${keyPair.value}',
            key: ValueKey('keyPair_$index'),
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}
