import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Cookie {
  static const _storage = FlutterSecureStorage();
  static Map<String, List<Function([Map<dynamic, dynamic>])>> reactors = {};

  static Future<String> read(String key) async {
    String value = await _storage.read(key: key) ?? "";
    return value;
  }

  static Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<bool> isUserLoggedIn() {
    return Cookie.read('token').then((token) => token != "");
  }

  // 100% environmental friendly energy
  static void setReactor(
      String trigger, Function([Map<dynamic, dynamic>]) reactor) {
    (reactors[trigger] ??= []).add(reactor);
  }

  static void trigger(String trigger,
      [Map<dynamic, dynamic> params = const {}]) {
    reactors[trigger]?.forEach((reactor) async => await reactor(params));
  }

  static void clearReactors(String trigger) {
    reactors[trigger]?.clear();
  }

  // 100% environmental friendly energy
  static void nukeReactors() {
    reactors.clear();
  }
}

Future<String> sendPressedKeyToRotors(String s) async {
  //Doesnt work?
  String machineID = await Cookie.read('current_machine');
  Map<String, String> query = {'key': s, 'machine': machineID};
  http.Response response = await APICaller.get("key_press", query);

  if (response.statusCode != 200) {
    return "?";
  }

  Map<String, dynamic> respBody = jsonDecode(response.body);
  String encKey = respBody['key'];

  Cookie.trigger("update_keyboard", {"encKey": s});
  Cookie.trigger("update_lampenfield", {"encKey": encKey.toUpperCase()});

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

  static Future<http.Response> post(String site,
      {Map<String, String> query = const {},
      Map<String, dynamic> body = const {}}) async {
    try {
      return await http.post(
          Uri.parse("$_api$site").replace(queryParameters: query),
          headers: await APICaller.getHeader(),
          body: jsonEncode(body));
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> put(String site,
      {Map<String, String> query = const {},
      Map<String, dynamic> body = const {}}) async {
    try {
      return await http.put(
          Uri.parse("$_api$site").replace(queryParameters: query),
          headers: await APICaller.getHeader(),
          body: jsonEncode(body));
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> get(String site,
      [Map<String, String> query = const {}]) async {
    try {
      return await http.get(
          Uri.parse("$_api$site").replace(queryParameters: query),
          headers: await APICaller.getHeader());
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> delete(String site,
      {Map<String, String> query = const {},
      Map<String, dynamic> body = const {}}) async {
    try {
      return await http.delete(
          Uri.parse("$_api$site").replace(queryParameters: query),
          headers: await APICaller.getHeader(),
          body: jsonEncode(body));
    } catch (e) {
      rethrow;
    }
  }
}
