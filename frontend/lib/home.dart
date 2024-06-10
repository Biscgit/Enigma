import 'package:flutter/material.dart';
import 'package:enigma/lampenfeld.dart';
import 'package:enigma/sidebar.dart';
import 'package:enigma/utils.dart';
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
    var _ = await APICaller.delete("logout", {});
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
          Lampfield(
            keyHistory: keyHistory,
          ),
          Positioned(
            top: 0,
            bottom: 10,
            right: 20,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.black12,
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
