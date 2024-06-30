import 'package:flutter/material.dart';
import 'package:enigma/rotors.dart';
import 'package:enigma/tastatur_and_lampenfeld.dart';
import 'package:enigma/sidebar.dart';
import 'package:enigma/utils.dart';
import 'package:enigma/steckerbrett.dart';
import 'package:enigma/keyhistory.dart';
import 'package:enigma/button.dart';
import 'package:enigma/add_machine.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? _selectedItem = "Enigma 1";
  String _username = '';
  late String numberRotors = '3';

  String? get selectedItem => _selectedItem;

  void _initialize() {
    Cookie.read("name").then((value) {
      setState(() {
        _selectedItem = value == "" ? selectedItem : value;
      });
      return Cookie.read("username");
    }).then((value) {
      setState(() {
        _username = value;
      });
      return Cookie.read("numberRotors");
    }).then((value) {
      setState(() {
        numberRotors = value == "" ? numberRotors : value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initialize();
    Cookie.nukeReactors();
    Cookie.setReactor("400", fetchData);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    await APICaller.delete("logout");
    await Cookie.clearAll();
    Cookie.nukeReactors();

    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget getPlugboard() {
    switch (_selectedItem) {
      case null:
        return Container();
      case 'Enigma M3':
        return const SteckbrettEnigma3();
      default:
        return const SteckbrettEnigma1();
    }
  }

  Future<void> _deleteMachine(BuildContext context) async {
    String currentID = await Cookie.read("current_machine");
    await APICaller.delete("delete-machine", query: {'machine_id': currentID});
    await Cookie.save("current_machine", "1");
    await Cookie.save("name", "Enigma I");
    await Cookie.save("numberRotors", "3");
  }

  void fetchData([Map<dynamic, dynamic> params = const {}]) {
    var message = params["message"];
    // Show snackbar if status code is 400
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.deepOrange,
        showCloseIcon: true,
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const keyHistory = KeyHistoryList();
    const reflector = Reflector();
    var I = int.parse(numberRotors);
    var rotorWidget = RotorPage(numberRotors: I);

    ScaffoldMessenger.of(context).clearSnackBars();

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedItem ?? "Create new machine"),
        actions: [
          const SettingsPage(key: Key('revertButton')),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AddMachinePopUp();
                },
              );
            },
            icon: const Icon(Icons.add),
            tooltip: "Adding machine",
            key: const ValueKey("addButton"),
          ),
          IconButton(
              icon: const Icon(Icons.delete),
              tooltip: "Delete",
              key: const ValueKey("deleteButton"),
              onPressed: () async {
                //_deleteMachine(context);
                //if (!context.mounted) return;

                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Text('Löschen bestätigen'),
                      content: const Text(
                          'Möchten Sie wirklich diese Maschine löschen?'),
                      key: const ValueKey('deletionDialog'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            // Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            'Nein',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                            onPressed: () async {
                              _deleteMachine(context);
                              if (!context.mounted) return;

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Löschen Bestätigung'),
                                    content: const Text(
                                        'Maschine erfolgreich gelöscht.'),
                                    key: const ValueKey('deletionConfirmed'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop();
                                          Navigator.pushReplacementNamed(
                                              context, '/home');
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
                            child: const Text('Ja',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                )))
                      ],
                    );
                  },
                );
              }),
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
      drawer: SideBar(
        key: const Key('enigma_sidebar'),
        username: _username,
      ),
      body: Row(
        children: [
          Flexible(
              fit: FlexFit.loose,
              child: Column(
                children: [
                  reflector,
                  rotorWidget,
                ],
              )),
          Expanded(
              child: Stack(
            children: [
              Column(
                children: <Widget>[
                  const Expanded(
                    child: MainScreen(),
                  ),
                  getPlugboard(),
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
