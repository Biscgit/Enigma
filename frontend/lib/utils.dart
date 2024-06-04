import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Cookie {
  static const _storage = FlutterSecureStorage();

  static Future<String> read(String key) async {
    String value = await _storage.read(key: key) ?? "";
    return value;
  }
  
  static Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
    print('Data saved: $value');
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
    print('Data deleted for key: $key');
  }

  static Future<bool> isUserLoggedIn() {
    return Cookie.read('token').then((token) => token != "");
  }
}

final String apiUrl = "http://localhost:8001/key_press"; // Windows
//final String apiUrl = "http://172.20.0.101:8001/key_press"; // Linux

Future<String> sendPressedKeyToRotors(String pressedKey) async {
  // Used by Tastatur (virtual keyboard) and textfield below lamppanel to send key inputs to backend;
  // This can also be implemented in tastatur.dart and lampenfeld.dart separately


  // replace API call in future by new implementation

  var token = await Cookie.read('token');
  var machineID = await Cookie.read('machine_id'); //Implement machine_id in cookies? Or how else can the global variable be accessed?
  var uri = Uri.parse(apiUrl).replace(queryParameters: {
    'token': token,
    'key': pressedKey,
    //'machine': machineID
    'machine': "0"
  });

  var response = await http.post(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
  );

  if(response.statusCode != 200) {
    return '?';
  }

  var jsonReponse = jsonDecode(response.body);
  print(jsonReponse);

  return jsonReponse['key'];
}

/*Future<String> post(String key) async {
  var response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );
}*/
