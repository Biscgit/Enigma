import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'dart:isolate';

class Cookie {
  static const _storage = FlutterSecureStorage();

  static void executeInIsolate(List<dynamic> args) async {
    print('Spawned isolate: Starting async task...');

    SendPort sendPort = args[0];
    Future<String?> func = args[1];

    final String value = await func ?? "";
    sendPort.send(value);

    print('Spawned isolate: Async task completed.');
  }

  static String executeSyncer(Future<String?> func) {
    Completer<void> completer = Completer();
    ReceivePort receivePort = ReceivePort();
    String value = "";

    Isolate.spawn(executeInIsolate, [receivePort.sendPort, func])
        .then((isolate) {
      receivePort.listen((message) {
        value = message;
        completer.complete();
      });
    });

    return value;
  }

  static String read(String key) {
    String value = executeSyncer(_storage.read(key: key));
    print('Data read: $value');
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

  static bool isUserLoggedIn() {
    return Cookie.read('token') != "";
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
