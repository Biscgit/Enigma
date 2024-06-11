import 'package:flutter/material.dart';
import 'package:enigma/utils.dart';

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
          Machine(name: 'Enigma I', id: 1, onItemSelected: onItemSelected),
          Machine(name: 'Norway Enigma', id: 2, onItemSelected: onItemSelected),
          Machine(name: 'Enigma M3', id: 3, onItemSelected: onItemSelected),
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
        onItemSelected(name);
        Cookie.save("current_machine", "$id");
        Navigator.pop(context);
      }
    );
  }
}
