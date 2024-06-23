import 'package:flutter/material.dart';
import 'package:enigma/utils.dart';


class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => SettingsPageState();

  const SettingsPage({super.key});
}

class SettingsPageState extends State<SettingsPage> {
  void resetSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Reset"),
          content: const Text("Are you sure you want to reset settings to default?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Confirm"),
              onPressed: () {
                // Logic to reset settings to default
                Cookie.read("current_machine")
                .then((machineId) => APICaller.post("revert-machine", query: {"machine_id": machineId}))
                .then((_) => Cookie.nukeReactors())
                .then((_) => Navigator.of(context).pop())
                .then((_) => Navigator.pushReplacementNamed(context, '/home'));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
              onPressed: resetSettings,
              child: const Text("Reset to Default"),
            );
  }
}
