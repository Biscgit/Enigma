import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  final Function(String) onItemSelected;

  SideBar({super.key, required this.onItemSelected});

  ListTile genMachinewithcon(String name, String backendID, context) {
    return ListTile(
        title: Text('$name'),
        onTap: () {
          onItemSelected('$name');
          // Backendcall with backendID
          Navigator.pop(context);
        });
  }

  final DrawerHeader header = DrawerHeader(
    child: Text('Wähle deine Enigma'),
    decoration: BoxDecoration(
      color: Colors.blue,
    ),
  );

  ListTile addMachine(BuildContext context) => ListTile(
      title: Text('Neue Enigma'),
      onTap: () {
        // Backendcall
        Navigator.pop(context);
      });

  @override
  Widget build(BuildContext context) {
    ListTile genMachine(String name, String backendID) =>
        genMachinewithcon(name, backendID, context);
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
