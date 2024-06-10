import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  static Future<bool> isUserLoggedIn() {
    return Cookie.read('token').then((token) => token != "");
  }
}

class APICaller {
  static final _api = 'http://${dotenv.env['IP_FASTAPI']}:8001/';
  static Future<Map<String, String>> getHeader() async {
    var token = await Cookie.read("token");
    return {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${token}',
    };
  }
  static Future<http.Response> post(String site, [Map<String, dynamic> body = const {}]) async {
    try {
      return await http.post(
        Uri.parse("${_api}${site}"),
        headers: await APICaller.getHeader(),
        body: jsonEncode(body)
      );
    } catch (e) {
      // Handle error
      print('Error in POST request: $e');
      rethrow;
    }
  }

  static Future<http.Response> get(String site, [Map<String, dynamic> body = const {}]) async {
    List<String> queryStringParts = [];

    body.forEach((key, value) {
      queryStringParts.add('$key=$value');
    });

    var query = '?' + queryStringParts.join('&');

    try {
      return await http.get(
        Uri.parse("${_api}${site}${query}"),
        headers: await APICaller.getHeader()
      );
    } catch (e) {
      // Handle error
      print('Error in GET request: $e');
      rethrow;
    }
  }

  static Future<http.Response> delete(String site, [Map<String, dynamic> body = const {}]) async {
    try {
      return await http.delete(
        Uri.parse("${_api}${site}"),
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
