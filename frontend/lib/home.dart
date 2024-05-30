import 'package:flutter/material.dart';
import 'package:enigma/tastatur_and_lampenfeld.dart';
import 'package:enigma/sidebar.dart';
import 'package:enigma/utils.dart';

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
    Navigator.pushReplacementNamed(context, '/login');
    await Cookie.delete('token');
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
      body: MainScreen(),
    );
  }
}
