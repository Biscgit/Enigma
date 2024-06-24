import 'package:enigma/custom_machine.dart';
import 'package:flutter/material.dart';
import 'package:enigma/utils.dart';
import 'custom_machine.dart';

class SideBar extends StatelessWidget {
  final String username;

  const SideBar({super.key, required this.username});

  Widget getHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
      child: Column(
        children: [
          Text(
            "Hallo $username!",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Text('Wähle deine Enigma')
        ],
      ),
    );
  }

  ListTile addMachine(BuildContext context) => ListTile(
    title: const Text('Neue Enigma'),
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => SelectionPage()),
      );
    }
  );

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          getHeader(),
          const Machine(name: 'Enigma I', id: 1),
          const Machine(name: 'Norway Enigma', id: 2),
          const Machine(name: 'Enigma M3', id: 3),
          addMachine(context)
        ],
      ),
    );
  }
}

class Machine extends StatelessWidget {
  final String name;
  final int id;

  const Machine({super.key, required this.name, required this.id});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      onTap: () {
        Cookie.save("name", name)
          .then((_) => Cookie.save("current_machine", "$id"))
          .then((_) => Cookie.clearReactors("update"))
          .then((_) => Cookie.clearReactors("set_focus_keyboard"))
          .then((_) => Cookie.clearReactors("update_history"))
          .then((_) => Cookie.clearReactors("update_lampenfield"))
          .then((_) => Cookie.clearReactors("update_keyboard"))
          .then((_) => Navigator.pop(context))
          .then((_) => Navigator.pushReplacementNamed(context, '/home')
        );
      }
    );
  }
}
