import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:enigma/home.dart';
import 'package:enigma/tastatur.dart';

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

void main() {
  testWidgets('Tastatur E2E Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    Widget home = const FakeTesterApp(child: HomePage());
    await tester.pumpWidget(home);

    //await tester.tap(find.byType(TextField)); //Might be useful at some point
    //await tester.pump();

    //Find 26 keys in total

    expect(find.byType(SquareButton), findsExactly(26));

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
  });
}
