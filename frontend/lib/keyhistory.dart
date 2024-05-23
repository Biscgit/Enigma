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
  static const MaxKeys = 140;

  final List<(String, String)> _keyHistory = <(String, String)>[];

  void loadKeyHistory(String machineId, String token) async {
    /// Loads pressed keys from server
    var response = await http.get(
      Uri.parse(
        '$apiUrl/keyhistory/load?token=$token&machine=$machineId',
      ),
    );

    if (response.statusCode == 200) {
      final List<(String, String)> keyHistory = jsonDecode(response.body);
      setState(() {
        _keyHistory.clear();
        _keyHistory.addAll(keyHistory);
      });
    }
  }

  void addKey(String clear, String encrypted) {
    /// Add the key to the key history
    _keyHistory.insert(0, (clear, encrypted));

    if (_keyHistory.length > MaxKeys) {
      _keyHistory.removeLast();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
