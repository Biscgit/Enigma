import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  final Function(String) onItemSelected;

  const SideBar({super.key, required this.onItemSelected});

  ListTile genMachineWithCon(String name, String backendID, context) {
    return ListTile(
        title: Text(name),
        onTap: () {
          onItemSelected(name);
          // Backendcall with backendID
          Navigator.pop(context);
        });
  }

  final DrawerHeader header = const DrawerHeader(
    decoration: BoxDecoration(
      color: Colors.blue,
    ),
    child: Text('Wähle deine Enigma'),
  );

  ListTile addMachine(BuildContext context) => ListTile(
      title: const Text('Neue Enigma'),
      onTap: () {
        // Backendcall
        Navigator.pop(context);
      });

  @override
  Widget build(BuildContext context) {
    ListTile genMachine(String name, String backendID) =>
        genMachineWithCon(name, backendID, context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          header,
          genMachine('Enigma I', ""),
          genMachine('Norway Enigma', ""),
          genMachine('Enigma M3', ""),
          addMachine(context)
        ],
      ),
    );
  }
}
