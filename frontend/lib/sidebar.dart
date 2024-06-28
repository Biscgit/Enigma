import 'package:enigma/add_machine.dart';
import 'package:flutter/material.dart';
import 'package:enigma/utils.dart';
import 'dart:convert';

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

  Future<List<Widget>> getMachines() async {
    var machines = json.decode((await APICaller.get("get-machines")).body);
    var widgets = [getHeader()];
    for (var machine in machines) {
      widgets.add(Machine(
          name: machine["name"],
          id: machine["id"],
          numberRotors: machine["number_rotors"],
          key: ValueKey("sidebar.${machine["name"]}")));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: getMachines(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator()],
          );
        } else {
          var data = snapshot.data!;
          data.add(ListTile(
            title: const Text("Neue Maschine"),
            onTap: () {
              Navigator.of(context).pop();
              showDialog(
                context: context, 
                builder: (BuildContext context) {
                  return const AddMachinePopUp();
              });
            }
          ));
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: data,
            ),
          );
        }
      },
    );
  }
}

class Machine extends StatelessWidget {
  final String name;
  final int id;
  final int numberRotors;

  const Machine(
      {super.key,
      required this.name,
      required this.id,
      required this.numberRotors});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(name),
        onTap: () {
          Cookie.save("name", name)
              .then((_) => Cookie.save("current_machine", "$id"))
              .then((_) => Cookie.save("numberRotors", "$numberRotors"))
              .then((_) => Cookie.nukeReactors())
              .then((_) => Navigator.pop(context))
              .then((_) => Navigator.pushReplacementNamed(context, '/home'));
        });
  }
}
