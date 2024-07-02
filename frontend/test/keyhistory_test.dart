import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enigma/home.dart';
import 'package:enigma/keyhistory.dart';

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

Future<void> addKeysAndTestWithTester(
    WidgetTester tester, List<String> clearTexts, List<String> encryptedTexts) async {

  final inputFieldFinder = find.byKey(const ValueKey('keyInput'));
  final addButtonFinder = find.byKey(const ValueKey('addButton'));

  for (int i = 0; i < clearTexts.length; i++) {
    await tester.enterText(inputFieldFinder, clearTexts[i]);
    await tester.tap(addButtonFinder);
    await tester.pumpAndSettle();
  }

  // Verify the history
  for (int i = 0; i < clearTexts.length; i++) {
    expect(find.text('${clearTexts[i]} -> ${encryptedTexts[i]}'), findsOneWidget);
  }
}

void main() {
  testWidgets('KeyHistory e2e test', (WidgetTester tester) async {
    Widget home = const FakeTesterApp(child: HomePage());
    await tester.pumpWidget(home);

    // history is initially empty
    expect(find.byType(KeyHistoryList), findsOneWidget);

    // Add keys to the history
    await addKeysAndTestWithTester(tester, ['A', 'B', 'C'], ['EncryptedA', 'EncryptedB', 'EncryptedC']);

    // verifying it's below 140 characters

    // more tests

  });
}
