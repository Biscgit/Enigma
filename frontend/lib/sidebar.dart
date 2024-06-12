import 'package:flutter/material.dart';
import 'package:enigma/utils.dart';

class SideBar extends StatelessWidget {

  const SideBar({super.key});

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
          Machine(name: 'Enigma I', id: 1),
          Machine(name: 'Norway Enigma', id: 2),
          Machine(name: 'Enigma M3', id: 3),
          addMachine(context)
        ],
      ),
    );
  }
}

class Machine extends StatelessWidget{
  final name;
  final id;

  const Machine({super.key, required this.name, required this.id});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      onTap: () {
        Cookie.save("name", name);
        Navigator.pushReplacementNamed(context, '/home');
        Cookie.save("current_machine", "$id");
        Navigator.pop(context);
      }
    );
  }
}
