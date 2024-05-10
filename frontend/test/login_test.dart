import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enigma/main.dart' as app;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

    // Successful login
    testWidgets('Successful login test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Show login page
      expect(find.text('Login Page'), findsOneWidget);

      // Valid usernaem and password
      await tester.enterText(find.byType(TextField).at(0), 'valid_username');
      await tester.enterText(find.byType(TextField).at(1), 'valid_password');
      await tester.pumpAndSettle();

      // Can you press the login button?
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Login confirmation?
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Successfully logged out'), findsNothing);

      // Dismiss alert dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Check if navigation to the home page
      expect(find.text('Home Page'), findsOneWidget);
      expect(find.text('Choose the enigma machine:'), findsOneWidget);
    });

    //----------------------------------------------------------------

    // Failed login
    testWidgets('Failed login test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // wrong username and password?
      await tester.enterText(find.byType(TextField).at(0), 'wrong_username');
      await tester.enterText(find.byType(TextField).at(1), 'wrong_password');
      await tester.pumpAndSettle();

      // Can you press the login button again?
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Error message show up?
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Login failed'), findsOneWidget);
      expect(find.text('Invalid username or password'), findsOneWidget);

      // Can you remove the failed login window?
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Are we still on the login page?
      expect(find.text('Login Page'), findsOneWidget);
    });
}
