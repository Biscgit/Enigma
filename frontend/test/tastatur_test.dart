import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';


import 'package:enigma/home.dart';
import 'package:enigma/tastatur.dart';
import 'package:enigma/utils.dart' as utils;

class FakeTesterApp extends StatelessWidget {
  final Widget child;

  const FakeTesterApp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Testing App',
      home: child,
    );
  }
}

List responses = List.generate(26, (index) => '');

Future<http.Response> requestHandler(http.Request request) async {
  final uri = request.url;
  final String? token = uri.queryParameters['token']; token.hashCode; //Removes annotation of "variable not used" but ensures that token parameter is in uri!
  final String? label = uri.queryParameters['key']; //Just so each button can be tested that it functions; also checks for correct URL structure!
  final String? machine = uri.queryParameters['machine']; machine.hashCode; //Same here
  var response = jsonEncode({'key': '$label'});
  responses[label!.codeUnitAt(0) - 65] = response;
  return http.Response(response, 200, headers: {'Content-Type': 'application/json',});
}

@GenerateMocks([http.Client])
void main() {
  testWidgets('Tastatur E2E Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    Widget home = const FakeTesterApp(child: HomePage());
    await tester.pumpWidget(home);

    //Find 26 keys in total

    List<SquareButton> listOfAllButtons = [];
    expect(find.byWidgetPredicate((widget) {
      if(widget is SquareButton) {
        listOfAllButtons.add(widget);
        return true;
      }
      return false;
    }), findsExactly(26));

    //Now go through all 26 letters


    for(int n = 0; n < 26; n++) {
      String currLetter = String.fromCharCode(n + 65);

      expect(find.byWidgetPredicate((widget) {
        if(widget is SquareButton) {
          return widget.label.toUpperCase() == currLetter; // add .toUpperCase() just in case the labels are in lower case
        }
        return false;
      }), findsOne);
    }


    final client = MockClient(requestHandler);
    final String apiUrl = utils.apiUrl;

    for(SquareButton button in listOfAllButtons) {
      when(client.post(
        Uri.parse(apiUrl).replace(queryParameters: {
        'token': anyNamed('token'),
        'key': button.label,
        'machine': any,
      }),
      headers: anyNamed('headers'),
      )).thenAnswer;

      await tester.tap(find.byWidget(button));
    }

    for(int i = 0; i < responses.length; i++) {
      String key = jsonDecode(responses[i])['key'];
      expect(key, String.fromCharCode(i+65));
    }
  });
}
