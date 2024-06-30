import 'dart:convert';

import 'package:enigma/utils.dart';
import 'package:http/http.dart';

Future<List<String>> getRotorIDs() async {
  //Structure of response: [{"id": 1}, {"id": 2}, ...]
  List<String> finalList = [];
  Response resp;
  List<dynamic> respJsonList;

  for (var i = 1; i < 4; i++) {
    resp = await APICaller.get("get-rotor-ids", {"machine_id": "$i"});
    respJsonList = jsonDecode(resp.body);
    int offset = respJsonList[0]["id"] ~/ 18;
    print(offset);
    await Cookie.save("offset", "$offset");
    for (var respJson in respJsonList) {
      Map<String, dynamic> jsonMap = respJson as Map<String, dynamic>;
      finalList.add("Rotor ${((jsonMap["id"] - 1) % 18 + 1).toString()}");
    }
  }

  return finalList;
}

Future<List<String>> getUmkehrwalzenIDs() async {
  Response resp = await APICaller.get("get-reflector-ids", {"machine_id": "1"});
  Response respNorway =
      await APICaller.get("get-reflector-ids", {"machine_id": "2"});
  List<String> finalList = [];
  List<dynamic> walzenListe = jsonDecode(resp.body);
  String walzeNorway = jsonDecode(respNorway.body)[0];

  for (String walze in walzenListe) {
    finalList.add(walze);
  }
  finalList.add(walzeNorway);
  return finalList;
}

bool burnerFunc() {
  return false;
}
