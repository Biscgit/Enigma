import 'package:flutter/material.dart';
import 'package:enigma/rotors.dart';
import 'package:enigma/tastatur_and_lampenfeld.dart';
import 'package:enigma/sidebar.dart';
import 'package:enigma/utils.dart';
import 'package:enigma/steckerbrett.dart';
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

  void _initialize() async {
    _selectedItem = await Cookie.read("name");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _logout(BuildContext context) async {
    await APICaller.delete("logout");
    await Cookie.delete('token');

    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final keyHistory = KeyHistoryList(
      key: _keyHistoryKey,
      keyHistoryKey: _keyHistoryKey,
    );
    const rotorWidget = RotorPage(numberRotors: 3);

    ScaffoldMessenger.of(context).clearSnackBars();

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedItem),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Logout',
            key: const ValueKey('logoutButton'),
            onPressed: () async {
              await _logout(context);
              if (!context.mounted) return;

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
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      drawer: const SideBar(
        key: Key('enigma_sidebar'),
      ),
      body: Row(
        children: [
          rotorWidget,
          Expanded(
              child: Stack(
            children: [
              Column(
                children: <Widget>[
                  Expanded(
                    child: MainScreen(
                      keyHistory: keyHistory,
                    ),
                  ),
                  (selectedItem == 'Enigma M3'
                      ? const SteckbrettEnigma3()
                      : const SteckbrettEnigma1()),
                ],
              ),
            ],
          )),
          Container(
            width: 180,
            margin: const EdgeInsets.only(
              right: 12,
              top: 12,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: keyHistory,
          ),
        ],
      ),
    );
  }
}
