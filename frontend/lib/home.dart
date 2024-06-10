import 'package:flutter/material.dart';
import 'package:enigma/lampenfeld.dart';
import 'package:enigma/sidebar.dart';
import 'package:enigma/utils.dart';
import 'package:enigma/steckerbrett_enigma1.dart' as enigma1_stk_brt;
import 'package:enigma/steckerbrett_enigmaM3.dart' as enigma3_stk_brt;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String _selectedItem = 'Enigma I';

  String get selectedItem => _selectedItem;

  void updateSelectedItem(String item) {
    setState(() {
      _selectedItem = item;
    });
  }

  void _logout(BuildContext context) async {
    var _ = await APICaller.delete("logout", {});
    await Cookie.delete('token');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedItem),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Logout',
            key: const ValueKey('logoutButton'),
            onPressed: () {
              _logout(context);
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
                          Navigator.pushReplacementNamed(context, '/login');
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
      body: Column(
        children: <Widget>[
          const Expanded(
            child: Lampfield(),
          ),
          _selectedItem == 'Enigma M3'
              ? enigma3_stk_brt.CustomKeyboard()
              : enigma1_stk_brt.CustomKeyboard(),
        ],
      ),
    );
  }
}
