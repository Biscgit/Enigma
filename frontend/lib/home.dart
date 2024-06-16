import 'package:flutter/material.dart';
import 'package:enigma/tastatur_and_lampenfeld.dart';
import 'package:enigma/sidebar.dart';
import 'package:enigma/utils.dart';
import 'package:enigma/steckerbrett_enigma1.dart' as enigma1_stk_brt;
import 'package:enigma/steckerbrett_enigmaM3.dart' as enigma3_stk_brt;
import 'package:enigma/keyhistory.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String _selectedItem = 'Enigma I';
  final GlobalKey<KeyHistoryState> _keyHistoryKey =
      GlobalKey<KeyHistoryState>();

  String get selectedItem => _selectedItem;

  void updateSelectedItem(String item) {
    setState(() {
      _selectedItem = item;
    });
  }

  Future<void> _logout(BuildContext context) async {
    var _ = await APICaller.delete("logout", query: {});
    await Cookie.delete('token');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final keyHistory = KeyHistoryList(
      key: _keyHistoryKey,
      keyHistoryKey: _keyHistoryKey,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedItem),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Logout',
            key: const ValueKey('logoutButton'),
            onPressed: () async {
              await _logout(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Logout Confirmation'),
                    content: const Text('Successfully logged out'),
                    key: const ValueKey('logoutDialog'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          // Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      drawer: SideBar(
        onItemSelected: updateSelectedItem,
        key: const Key('enigma_sidebar'),
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(
                child: MainScreen(
                  keyHistory: keyHistory,
                ),
              ),
              _selectedItem == 'Enigma M3'
                  ? const enigma3_stk_brt.CustomKeyboard()
                  : const enigma1_stk_brt.CustomKeyboard(),
            ],
          ),
          Positioned(
            top: 12,
            bottom: 12,
            right: 12,
            child: Container(
              width: 180,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: keyHistory,
            ),
          ),
        ],
      ),
    );
  }
}
