import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:enigma/lampenfeld.dart';
import 'dart:convert';

class Cookie {
  static const _storage = FlutterSecureStorage();
  static Map<String, List<Function(String)>> reactors = {};

  static Future<String> read(String key) async {
    String value = await _storage.read(key: key) ?? "";
    return value;
  }
  
  static Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
    reactors[key]?.forEach((reactor) async => await reactor(value));
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  static Future<bool> isUserLoggedIn() {
    return Cookie.read('token').then((token) => token != "");
  }

  static void setReactor(String trigger, Function(String) reactor) {
    (reactors[trigger] ??= []).add(reactor);
  }
}

const String apiUrl = "http://localhost:8001/key_press"; // Linux

/*Future<String> sendPressedKeyToRotors(String pressedKey) async {
  // Used by Tastatur (virtual keyboard) and textfield below lamppanel to send key inputs to backend;
  // This can also be implemented in tastatur.dart and lampenfeld.dart separately


  // replace API call in future by new implementation

  //var machineID = await Cookie.read('machine_id'); //Implement machine_id in cookies? Or how else can the global variable be accessed?
  var token = await Cookie.read('token');
  var header = await APICaller.getHeader();
  var uri = Uri.parse(apiUrl).replace(queryParameters: {
    'token': token,
    'key': pressedKey,
    //'machine': machineID
    'machine': "0"
  });

  var response = await http.post(
    uri,
    headers: header,
  );

  if(response.statusCode != 200) {
    return '?';
  }

  var jsonReponse = jsonDecode(response.body);
  print(jsonReponse);
  String encKey = jsonReponse['key'];

  Lampfield.lampFieldKey.currentState?.lightUpLetter(encKey.toUpperCase());
  return jsonReponse['key'];
}*/

Future<String> sendPressedKeyToRotors(String s) async { //Doesnt work?
  String machineID = await Cookie.read('current_machine');
  Map<String, dynamic> body = {
    'key': s,
    'machine': machineID
  };
  http.Response response = await APICaller.get("key_press", body);

  if(response.statusCode != 200) {
    return "?";
  }

  Map<String, dynamic> respBody = jsonDecode(response.body);
  String encKey = respBody['key'];

  Lampfield.lampFieldKey.currentState?.lightUpLetter(encKey.toUpperCase());

  return encKey;
}

class APICaller {
  static final _api = 'http://${dotenv.env['IP_FASTAPI']}:8001/';
  static Future<Map<String, String>> getHeader() async {
    var token = await Cookie.read("token");
    return {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
    };
  }

  static Future<http.Response> post(String site, {Map<String, dynamic> query = const {}, Map<String, dynamic> body = const {}}) async {
    try {
      return await http.post(
        Uri.parse("$_api$site").replace(queryParameters: query),
        headers: await APICaller.getHeader(),
        body: jsonEncode(body)
      );
    } catch (e) {
      // Handle error
      print('Error in POST request: $e');
      rethrow;
    }
  }

  static Future<http.Response> get(String site, [Map<String, dynamic> query = const {}]) async {
    try {
      return await http.get(
        Uri.parse("$_api$site").replace(queryParameters: query),
        headers: await APICaller.getHeader()
      );
    } catch (e) {
      // Handle error
      print('Error in GET request: $e');
      rethrow;
    }
  }

  static Future<http.Response> delete(String site, {Map<String, dynamic> query = const {}, Map<String, dynamic> body = const {}}) async {
    try {
      return await http.delete(
        Uri.parse("$_api$site").replace(queryParameters: query),
        headers: await APICaller.getHeader(),
        body: jsonEncode(body)
      );
    } catch (e) {
      // Handle error
      print('Error in DELETE request: $e');
      rethrow;
    }
  }
}
