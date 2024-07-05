import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enigma/home.dart';

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

Future<void> clickAndTestWithTester(
    WidgetTester tester, String name) async {
  // Find the sidebar icon and tap it
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();

  // Find on sidebar
  final sideBarButton = find.descendant(
    of: find.byKey(const Key('enigma_sidebar')),
    matching: find.text(name),
  );
  expect(sideBarButton, findsOneWidget);

  await tester.tap(sideBarButton);
  await tester.pumpAndSettle();

  // Verify that the main content displays the selected item
  expect(find.text(name), findsOneWidget);
}

void main() {
  testWidgets('EnigmaPage widget test', (WidgetTester tester) async {
    clickAndTest(String name) async =>
        await clickAndTestWithTester(tester, name);
    // Build our app and trigger a frame.

    Widget home = const FakeTesterApp(child: HomePage());
    await tester.pumpWidget(home);

    // Verify that the default machine is 'Enigma I'
    expect(find.text('Enigma I'), findsOneWidget);
    expect(find.text('Norway Enigma'), findsNothing);
    expect(find.text('Enigma M3'), findsNothing);

    await clickAndTest("Enigma I");
    await clickAndTest("Norway Enigma");
    await clickAndTest("Enigma M3");
  });
}