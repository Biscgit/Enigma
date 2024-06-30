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

Future<String> findSquareButtonKey(
    FlutterDriver? driver, String baseKey) async {
  final notHighlightedKey = 'Tastatur-Key-$baseKey-0';
  final highlightedKey = 'Tastatur-Key-$baseKey-1';

  try {
    await driver?.waitFor(find.byValueKey(notHighlightedKey),
        timeout: const Duration(milliseconds: 500));
    return notHighlightedKey;
  } catch (e) {
    // Do nothing, just try the next key
  }

  try {
    await driver?.waitFor(find.byValueKey(highlightedKey),
        timeout: const Duration(milliseconds: 500));
    return highlightedKey;
  } catch (e) {
    // If both fail, rethrow the last exception
    throw Exception('Widget with key $baseKey not found');
  }
}

Future<void> checkForKeyInput(
    FlutterDriver? driver, String keyInput, String expectedResult) async {
  //debugPrint("Check for input: $keyInput, expecting result: $expectedResult.");

  keyInput = keyInput.toUpperCase();
  expectedResult = expectedResult.toUpperCase();

  Health? health = await driver?.checkHealth();
  assert(health?.status == HealthStatus.ok);
  //Template for how keyboard ValueKeys work:
  //    Tastatur-Key-$label
  //Template for how lamppanel ValueKeys work:
  //    Lamppanel-Key-$text-$highlighted^
  String keyName = await findSquareButtonKey(driver, keyInput);
  dynamic key = find.byValueKey(keyName);
  await driver?.tap(key);
  //await driver?.waitFor(find.byValueKey("ResultKey"), timeout: const Duration(seconds: 3)); //In Testing State

  int expectedResultDecoded = expectedResult.codeUnitAt(0) - 65;
  int keyInputDecoded = keyInput.codeUnitAt(0) - 65;

  for (int i = 0; i < 26; i++) {
    String letter = String.fromCharCode(i + 65);
    if (i != expectedResultDecoded) {
      //Exclude case for expected letter
      await driver?.waitFor(find.byValueKey("Lamppanel-Key-$letter-0"),
          timeout: const Duration(seconds: 3));
    } else {
      await driver?.waitFor(find.byValueKey("Lamppanel-Key-$expectedResult-1"),
          timeout: const Duration(seconds: 3));
    }
  }
  for (int i = 0; i < 26; i++) {
    String letter = String.fromCharCode(i + 65);
    if (i != keyInputDecoded) {
      //Exclude case for pressed letter
      await driver?.waitFor(find.byValueKey("Tastatur-Key-$letter-0"),
          timeout: const Duration(seconds: 3));
    } else {
      await driver?.waitFor(find.byValueKey("Tastatur-Key-$keyInput-1"),
          timeout: const Duration(seconds: 3));
    }
  }
}

void main() {
  FlutterDriver? driver;
  //ft.WidgetTester tester;

  // Connect to the Flutter app before running the tests.
  setUp(() async => {
        driver =
            await FlutterDriver.connect(timeout: const Duration(minutes: 3))
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

  test('Tastatur + Lamppanel + Backend test', () async {
    //This test passing means that all components work correctly!
    await t_lib.login(driver);
    await t_lib.resetSelectedMachine(driver);

    // https://www.101computing.net/enigma-machine-emulator/
    // Encryption results should be what this returns (in AAA configuration, no plugboard, etc.)
    // Change the expectedResults once backend runs correctly!

    await checkForKeyInput(driver, "H", "R");
    await checkForKeyInput(driver, "E", "Q");
    await checkForKeyInput(driver, "L", "B");
    await checkForKeyInput(driver, "L", "D");
    await checkForKeyInput(driver, "O", "R");

    await checkForKeyInput(driver, "W", "Z");
    await checkForKeyInput(driver, "O", "J");
    await checkForKeyInput(driver, "R", "G");
    await checkForKeyInput(driver, "L", "X");
    await checkForKeyInput(driver, "D", "A");
    // print("Done!");
  }, timeout: const Timeout(Duration(minutes: 3)));

  test("Keyboard Spamming", timeout: const Timeout(Duration(minutes: 3)),
      () async {
    await t_lib.login(driver, username: "user2", password: "pass2");
    await t_lib.resetSelectedMachine(driver);

    List<Future> handlers = [];
    for (int i = 0; i < 100; i++) {
      final handler = t_lib.writeChar("A", driver);
      handlers.add(handler);
    }

    // check correct order
    await driver?.waitFor(find.text("A → V"));
    await driver?.waitFor(find.text("A → D"));
    await driver?.waitFor(find.text("A → D"));
    await driver?.waitFor(find.text("A → N"));
    await driver?.waitFor(find.text("A → Q"));

    await t_lib.logout(driver);
  });
}
