import 'dart:math';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'test_lib.dart';

void main() {
  FlutterDriver? driver;

  setUp(() async {
    driver = await FlutterDriver.connect();
    driver?.checkHealth();
  });

  tearDown(() async {
    if (driver != null) {
      driver?.close();
    }
  });

  test("Persistent toggle", timeout: const Timeout(Duration(seconds: 60)),
      () async {
    // reset machines
    await login(driver);
    await resetSelectedMachine(driver);
    await logout(driver);

    await login(driver, username: "user2", password: "pass2");
    await resetSelectedMachine(driver);
    await logout(driver);

    // check closed plugboard
    await login(driver);
    await driver?.waitForAbsent(
      find.byValueKey("plugboard_container"),
      timeout: const Duration(seconds: 3),
    );

    final toggle = find.byValueKey("plugboard_switch");
    await driver?.tap(toggle);

    // check open plugboard
    await driver?.waitFor(find.byValueKey("plugboard_container"));

    // check different user
    await logout(driver);
    await login(driver, username: "user2", password: "pass2");

    await driver?.waitForAbsent(
      find.byValueKey("plugboard_container"),
      timeout: const Duration(seconds: 3),
    );
    await logout(driver);

    // check if persistent after logging in again
    await login(driver);
    await driver?.waitFor(find.byValueKey("plugboard_container"));
    await logout(driver);
  });

  test("Loading", timeout: const Timeout(Duration(minutes: 2)), () async {
    await login(driver);
    await resetSelectedMachine(driver);

    await driver?.tap(find.byValueKey("plugboard_switch"));

    for (final char in "avlhki".split("")) {
      await driver?.tap(
        find.byValueKey("plugboard_letter_${char.toLowerCase()}_false"),
      );
    }
    await logout(driver);

    await login(driver);
    await driver?.waitFor(find.byValueKey("plugboard_container"));

    // all if all plugs are displayed correctly
    for (final char in "qwertzuiopasdfghjklyxcvbnm".split("")) {
      if ("avlhki".contains(char)) {
        await driver?.waitFor(
          find.byValueKey("plugboard_letter_${char}_true"),
        );
      } else {
        await driver?.waitFor(
          find.byValueKey("plugboard_letter_${char}_false"),
        );
      }
    }

    await logout(driver);

    // check normal loading if enabled
    await login(driver);
    for (final char in "qwertzuiopasdfghjklyxcvbnm".split("")) {
      if ("avlhki".contains(char)) {
        await driver?.waitFor(find.byValueKey("plugboard_letter_${char}_true"));
      } else {
        await driver
            ?.waitFor(find.byValueKey("plugboard_letter_${char}_false"));
      }
    }

    // disable for now
    await driver?.tap(find.byValueKey("plugboard_switch"));
    await logout(driver);

    // check if only affects one user
    await login(driver, username: "user2", password: "pass2");
    await resetSelectedMachine(driver);
    await driver?.tap(find.byValueKey("plugboard_switch"));
    for (final char in "qwertzuiopasdfghjklyxcvbnm".split("")) {
      await driver?.waitFor(
        find.byValueKey("plugboard_letter_${char}_false"),
      );
    }
    await logout(driver);

    // check if it is still disabled and load old configuration
    await login(driver);
    await driver?.tap(find.byValueKey("plugboard_switch"));

    await driver?.waitFor(find.byValueKey("plugboard_container"));
    for (final char in "qwertzuiopasdfghjklyxcvbnm".split("")) {
      if ("avlhki".contains(char)) {
        await driver?.waitFor(
          find.byValueKey("plugboard_letter_${char}_true"),
        );
      } else {
        await driver?.waitFor(
          find.byValueKey("plugboard_letter_${char}_false"),
        );
      }
    }
    await logout(driver);
  });

  test("Reset", timeout: const Timeout(Duration(minutes: 2)), () async {
    await login(driver);
    await resetSelectedMachine(driver);

    // fill with values
    await driver?.tap(find.byValueKey("plugboard_switch"));
    takeScreenshot(driver!, "plugboard.png");
    for (final char in "qwertzuiopasdfghjklyxcvbnm".split("")) {
      if ("avlhki".contains(char)) {
        await driver?.tap(
          find.byValueKey("plugboard_letter_${char.toLowerCase()}_false"),
        );
        await driver?.waitFor(
          find.byValueKey("plugboard_letter_${char}_true"),
        );
      } else {
        await driver?.waitFor(
          find.byValueKey("plugboard_letter_${char}_false"),
        );
      }
    }

    // reset and check
    await driver?.tap(find.byValueKey("reset_plugboard"));
    for (final char in "qwertzuiopasdfghjklyxcvbnm".split("")) {
      await driver?.waitFor(
        find.byValueKey("plugboard_letter_${char}_false"),
      );
    }
  });

  test("Plug limit of 20", timeout: const Timeout(Duration(minutes: 2)),
      () async {
    await login(driver);
    await resetSelectedMachine(driver);
    await driver?.tap(find.byValueKey("plugboard_switch"));

    for (int i = 0; i < 20; i++) {
      final char = String.fromCharCode(65 + i);
      await driver?.tap(
        find.byValueKey("plugboard_letter_${char.toLowerCase()}_false"),
      );
      await driver?.waitFor(
          find.byValueKey("plugboard_letter_${char.toLowerCase()}_true"));
    }

    // enable 21th plug
    final char = String.fromCharCode(65 + 20);
    await driver?.tap(
      find.byValueKey("plugboard_letter_${char.toLowerCase()}_false"),
    );
    await driver?.waitFor(
      find.text('Maximum number of selectable connections reached!'),
    );
    await driver?.waitForAbsent(
      find.byValueKey("plugboard_letter_${char.toLowerCase()}_true"),
      timeout: const Duration(seconds: 3),
    );
  });

  test("Correct affecting of encryption",
      timeout: const Timeout(Duration(minutes: 2)), () async {
    await login(driver);
    await resetSelectedMachine(driver);

    // first 9 letters default, rest enable plugboard while running
    final letters = "waylandisthebetterxorg".split("");
    final encrypted = "xmkddfitainjgfgopzbgyo".split("");

    for (int i = 0; i < 9; i++) {
      await writeChar(letters[i], driver);
    }
    // enable plugboard in correct order
    await driver?.tap(find.byValueKey("plugboard_switch"));
    for (final char in "arwdecytfivkznblhj".split("")) {
      await driver?.tap(
        find.byValueKey("plugboard_letter_${char.toLowerCase()}_false"),
      );
    }
    for (int i = 9; i < letters.length; i++) {
      await writeChar(letters[i], driver);
      await driver?.waitFor(
        find.text(
          '${letters[i].toUpperCase()} → ${encrypted[i].toUpperCase()}',
        ),
        timeout: const Duration(seconds: 3),
      );
    }

    // disable a few plugs
    for (final char in "whz".split("")) {
      await driver?.tap(
        find.byValueKey("plugboard_letter_${char.toLowerCase()}_true"),
      );
    }

    final letters2 = "sometimes".split("");
    final encrypted2 = "akwocwill".split("");
    for (int i = 0; i < letters2.length; i++) {
      await writeChar(letters2[i], driver);
      await driver?.waitFor(
        find.text(
          '${letters2[i].toUpperCase()} → ${encrypted2[i].toUpperCase()}',
        ),
        timeout: const Duration(seconds: 3),
      );
    }

    // finally disable and continue typing
    await driver?.tap(find.byValueKey("plugboard_switch"));
    final letters3 = "moreorless".split("");
    final encrypted3 = "uqktcxfibu".split("");
    for (int i = 0; i < letters3.length; i++) {
      await writeChar(letters3[i], driver);
      await driver?.waitFor(
        find.text(
          '${letters3[i].toUpperCase()} → ${encrypted3[i].toUpperCase()}',
        ),
        timeout: const Duration(seconds: 3),
      );
    }
  });
}
