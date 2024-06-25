import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'test_lib.dart' as t_lib;

/*
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
*/

void login(FlutterDriver? driver) async {
  // Find the button by its label.
  final usernameField = find.byValueKey('username');
  final passwordField = find.byValueKey('password');
  final button = find.text('Login');

  await driver?.tap(usernameField);
  await driver?.enterText("user1");

  await driver?.tap(passwordField);
  await driver?.enterText("pass1");

  await driver?.tap(button);

  // check if message appears
  await driver?.waitForAbsent(
    find.byValueKey('failedLogin'),
    timeout: const Duration(seconds: 5),
  );
}

Future<void> checkForKeyInput(FlutterDriver? driver, String keyInput, String expectedResult) async {
  // print("Check for input: $keyInput, expecting result: $expectedResult.");

  Health? health = await driver?.checkHealth();
  assert(health?.status == HealthStatus.ok);
      //Template for how keyboard ValueKeys work:
      //    Tastatur-Button-$label
      //Template for how lamppanel ValueKeys work:
      //    Lamppanel-Key-$text-$highlighted

  dynamic key = find.byValueKey("Tastatur-Button-${keyInput.toUpperCase()}"); //.toUpperCase() just to be safe
  await driver?.tap(key);
  //await driver?.waitFor(find.byValueKey("ResultKey"), timeout: const Duration(seconds: 3)); //In Testing State

  int expectedResultDecoded = expectedResult.codeUnitAt(0) - 65;

  for(int i = 0; i < 26; i++) {
    String letter = String.fromCharCode(i + 65);
    if(i != expectedResultDecoded) { //Exclude case for letter "I"
      await driver?.waitFor(find.byValueKey("Lamppanel-Key-$letter-0"), timeout: const Duration(seconds: 3));
    }
    else {
      await driver?.waitFor(find.byValueKey("Lamppanel-Key-$expectedResult-1"), timeout: const Duration(seconds: 3));
    }
  }
}

void main() {
  FlutterDriver? driver;
  //ft.WidgetTester tester;

    // Connect to the Flutter app before running the tests.
    setUp(() async => {
      driver = await FlutterDriver.connect()
    });

    // Close the connection to the Flutter app after tests are done.
    tearDown(() async {
      if (driver != null) {
        driver?.close();
      }
    });

    test('Check Flutter-driver health', () async {
     Health? health = await driver?.checkHealth();
      assert(health?.status == HealthStatus.ok);
    });

    test('Tastatur + Lamppanel + Backend test', () async { //This test passing means that all components work correctly!
      await t_lib.login(driver);
      await t_lib.resetSelectedMachine(driver);

      // https://www.101computing.net/enigma-machine-emulator/
      // Encryption results should be what this returns (in AAA configuration, no plugboard, etc.)
      // Change the expectedResults once backend runs correctly!

      await checkForKeyInput(driver, "H", "R"); //This is correct
      await checkForKeyInput(driver, "E", "Q"); //Change result to: L
      await checkForKeyInput(driver, "L", "B"); //Change result to: B
      await checkForKeyInput(driver, "L", "D"); //Change result to: D
      await checkForKeyInput(driver, "O", "R"); //Change result to: A

      await checkForKeyInput(driver, "W", "Z"); //Change result to: A
      await checkForKeyInput(driver, "O", "J"); //Change result to: M
      await checkForKeyInput(driver, "R", "G"); //Change result to: T
      await checkForKeyInput(driver, "L", "X"); //Change result to: A
      await checkForKeyInput(driver, "D", "A"); //Change result to: Z
      // print("Done!");
    });
}
