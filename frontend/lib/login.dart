import 'package:flutter/material.dart';
import 'utils.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginPage extends StatelessWidget {
  // replace 172.20.0.101 with localhost on Windows
  static String apiUrl = 'http://${dotenv.env['IP_FASTAPI']}:8001/login';

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  void _login(BuildContext context) async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    
    var response = await APICaller.post("login", body: {"username": username, "password": password, });
    await Cookie.save("current_machine", "0");

    if (response.statusCode == 200) {
      Navigator.pushReplacementNamed(context, '/home');

      final token = jsonDecode(response.body)["token"];
      await Cookie.save('token', token);
    } else {
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
