import 'package:flutter/material.dart';
import 'package:enigma/utils.dart';

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => SettingsPageState();

  const SettingsPage({super.key});
}

class SettingsPageState extends State<SettingsPage> {
  void resetSettings(ButtonStyle buttonStyle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Reset"),
          content:
              const Text("Are you sure you want to reset settings to default?"),
          actions: [
            TextButton(
              key: const ValueKey("Cancel_revert"),
              style: buttonStyle,
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              key: const ValueKey("Confirm_revert"),
              style: buttonStyle,
              child: const Text("Confirm"),
              onPressed: () {
                // Logic to reset settings to default
                Cookie.read("current_machine")
                    .then((machineId) => APICaller.post("revert-machine",
                        query: {"machine_id": machineId}))
                    .then((_) => Cookie.nukeReactors())
                    .then((_) => Navigator.of(context).pop())
                    .then((_) =>
                        Navigator.pushReplacementNamed(context, '/home'));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
    return ElevatedButton(
      style: buttonStyle,
      key: const ValueKey("Reset_button"),
      onPressed: () => resetSettings(buttonStyle),
      child: const Text("Reset to Default"),
    );
  }
}
