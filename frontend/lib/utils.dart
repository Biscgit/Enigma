import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Cookie {
  static final _storage = FlutterSecureStorage();

  static Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
    print('Data saved: $value');
  }

  static Future<String> read(String key) async {
    String value = await _storage.read(key: key) ?? "";
    return value;
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
    print('Data deleted for key: $key');
  }

  static Future<bool> isUserLoggedIn() {
    return Cookie.read('token').then((token) => token != "");
  }
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
