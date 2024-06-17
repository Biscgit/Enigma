import 'package:flutter/material.dart';
import 'utils.dart';
import 'dart:convert';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  void _login(BuildContext context) {
    String username = _usernameController.text;
    String password = _passwordController.text;


    APICaller.post("login", body: { "username": username, "password": password })
    .then((response) {
      return Cookie.save("current_machine", "1")
      .then((_) => Cookie.save("name", "Enigma I"))
      .then((_) {
        if (response.statusCode == 200) {
          final token = json.decode(response.body)["token"];
          return Cookie.save('token', token)
              .then((_) => Navigator.of(context).pushNamed('/home'));
        }
        else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                key: const ValueKey('failedLogin'),
                title: const Text('Login failed'),
                content: const Text('Invalid username or password'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double loginWidth = screenHeight * 0.6;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enigma Login'),
        leading: Container(),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: BoxConstraints(maxWidth: screenWidth),
            width: loginWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  key: const ValueKey('username'),
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const ValueKey('password'),
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  onSubmitted: (value) => _login(context),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  key: const ValueKey('Login'),
                  onPressed: () => _login(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
