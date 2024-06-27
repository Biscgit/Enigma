import 'dart:convert';

import 'package:enigma/utils.dart';
import 'package:http/http.dart';


Future<List<String>> getRotorIDs() async {
  //Structure of response: [{"id": 1}, {"id": 2}, ...]
  Response resp = await APICaller.get("get-rotor-ids", {"machine_id": "1"}); 
  List<String> finalList = [];
  List<Map<String, int>> respJsonList = jsonDecode(resp.body);
  //print("Hello! $respJson");
  for(Map<String, int> respJson in respJsonList) {
    finalList.add("Rotor ${respJson["id"].toString()}");
  }
  resp = await APICaller.get("get-rotor-ids", {"machine_id": "2"});
  respJsonList = jsonDecode(resp.body);
  for(Map<String, int> respJson in respJsonList) {
    finalList.add("Rotor ${respJson["id"].toString()}");
  }
  resp = await APICaller.get("get-rotor-ids", {"machine_id": "3"});
  respJsonList = jsonDecode(resp.body);
  for(Map<String, int> respJson in respJsonList) {
    finalList.add("Rotor ${respJson["id"].toString()}");
  }
  return finalList;
}

Future<List<String>> getUmkehrwalzenIDs() async {
  Response resp = await APICaller.get("get-reflector-ids", {"machine_id": "1"});
  List<String> finalList = [];
  List<String> walzenListe = jsonDecode(resp.body);
  for(String walze in walzenListe) {
    finalList.add(walze);
  }
  return finalList;
}

bool burnerFunc() {
  return false;
}