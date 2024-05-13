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

Future<void> click_and_test_with_tester(
    WidgetTester tester, String name) async {
  // Find the sidebar icon and tap it
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();

  // Find and tap on 'Item 1'
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
    click_and_test(String name) async =>
        await click_and_test_with_tester(tester, name);
    // Build our app and trigger a frame.

    Widget home = FakeTesterApp(child: HomePage());
    await tester.pumpWidget(home);

    // Verify that the default machine is 'Enigma I'
    ////expect(find.text('Enigma I'), findsOneWidget);
    expect(find.text('Norway Enigma'), findsNothing);
    expect(find.text('Enigma M3'), findsNothing);

    await click_and_test("Enigma I");
    await click_and_test("Norway Enigma");
    await click_and_test("Enigma M3");
  });
}
