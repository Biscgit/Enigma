import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Enigma/main.dart';

void main() {
  testWidgets('EnigmaPage widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that EnigmaPage widget is rendered
    expect(find.byType(EnigmaPage), findsOneWidget);

    // Verify that the default machine is 'Enigma I'
    expect(find.text('Enigma I'), findsOneWidget);
    expect(find.text('Norway Enigma'), findsNothing);
    expect(find.text('Enigma M3'), findsNothing);

    // Tap on Norway Enigma button and verify the machine change
    await tester.tap(find.text('Norway Enigma'));
    await tester.pumpAndSettle();
    expect(find.text('Norway Enigma'), findsOneWidget);
    expect(find.text('Enigma I'), findsNothing);
    expect(find.text('Enigma M3'), findsNothing);

    // Tap on Enigma M3 button and verify the machine change
    await tester.tap(find.text('Enigma M3'));
    await tester.pumpAndSettle();
    expect(find.text('Enigma M3'), findsOneWidget);
    expect(find.text('Enigma I'), findsNothing);
    expect(find.text('Norway Enigma'), findsNothing);

    // Tap on Enigma I button again and verify the machine change
    await tester.tap(find.text('Enigma I'));
    await tester.pumpAndSettle();
    expect(find.text('Enigma I'), findsOneWidget);
    expect(find.text('Norway Enigma'), findsNothing);
    expect(find.text('Enigma M3'), findsNothing);
  });
}
