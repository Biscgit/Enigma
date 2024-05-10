import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enigma/main.dart' as app;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Logout', () {
    testWidgets('Successful logout test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigato to homepage
      await tester.tap(find.byIcon(Icons.exit_to_app));
      await tester.pumpAndSettle();

      // Confirm logout widget
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Successfully logged out'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // check if the user is navigated back to login paage
      expect(find.text('Login Page'), findsOneWidget);
    });
  });
}
