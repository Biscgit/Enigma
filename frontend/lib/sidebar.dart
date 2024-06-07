import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  final Function(String) onItemSelected;

  const SideBar({super.key, required this.onItemSelected});

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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          header,
          Machine(name: 'Enigma I', id: "", onItemSelected: this.onItemSelected),
          Machine(name: 'Norway Enigma', id: "", onItemSelected: this.onItemSelected),
          Machine(name: 'Enigma M3', id: "", onItemSelected: this.onItemSelected),
          addMachine(context)
        ],
      ),
    );
  }
}

class Machine extends StatelessWidget{
  final name;
  final id;
  final Function(String) onItemSelected;

  const Machine({super.key, required this.name, required this.id, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      onTap: () {
        this.onItemSelected(this.name);
        // Backendcall with backendID
        Navigator.pop(context);
      }
    );
  }
}
