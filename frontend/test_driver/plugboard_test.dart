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

  // Old test, rewritten at the bottom
  // test("Persistent enabled state",
  //     timeout: const Timeout(Duration(seconds: 60)), () async {
  //   // reset machines
  //   await login(driver);
  //   await resetSelectedMachine(driver);
  //   await logout(driver);
  //
  //   await login(driver, username: "user2", password: "pass2");
  //   await resetSelectedMachine(driver);
  //   await logout(driver);
  //
  //   // check closed plugboard
  //   await login(driver);
  //   await driver?.waitForAbsent(
  //     find.byValueKey("plugboard_container"),
  //     timeout: const Duration(seconds: 3),
  //   );
  //
  //   final toggle = find.byValueKey("plugboard_switch");
  //   await driver?.tap(toggle);
  //
  //   // check open plugboard
  //   await driver?.waitFor(find.byValueKey("plugboard_container"));
  //
  //   // check different user
  //   await logout(driver);
  //   await login(driver, username: "user2", password: "pass2");
  //
  //   await driver?.waitForAbsent(
  //     find.byValueKey("plugboard_container"),
  //     timeout: const Duration(seconds: 3),
  //   );
  //   await logout(driver);
  //
  //   // check if persistent after logging in again
  //   await login(driver);
  //   await driver?.waitFor(find.byValueKey("plugboard_container"));
  //   await logout(driver);
  // });

  test("Loading on select", timeout: const Timeout(Duration(minutes: 2)),
      () async {
    await login(driver);
    await resetSelectedMachine(driver);

    // await driver?.tap(find.byValueKey("plugboard_switch"));

    for (final char in "avlhki".split("")) {
      await driver?.tap(
        find.byValueKey("plugboard_letter_${char.toLowerCase()}_false"),
      );
    }
    await logout(driver);

    await login(driver);
    await driver?.waitFor(find.byValueKey("plugboard_container"));

    // check if all plugs are loaded correctly
    for (final char in "qwertzuiopasdfghjklyxcvbnm".split("")) {
      if ("avlhki".contains(char)) {
        await driver?.waitFor(find.byValueKey("plugboard_letter_${char}_true"));
      } else {
        await driver
            ?.waitFor(find.byValueKey("plugboard_letter_${char}_false"));
      }
    }
    await logout(driver);

    // ToDo: create new machine instead with disabled plug
    // disable for now
    // await driver?.tap(find.byValueKey("plugboard_switch"));
    // await logout(driver);

    // check if only affects one user
    await login(driver, username: "user2", password: "pass2");
    await resetSelectedMachine(driver);
    // await driver?.tap(find.byValueKey("plugboard_switch"));
    for (final char in "qwertzuiopasdfghjklyxcvbnm".split("")) {
      await driver?.waitFor(
        find.byValueKey("plugboard_letter_${char}_false"),
      );
    }
    await logout(driver);

    // check if it is still disabled and load old configuration
    await login(driver);

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

  test("Reset all plugs", timeout: const Timeout(Duration(minutes: 2)),
      () async {
    await login(driver);
    await resetSelectedMachine(driver);

    // fill with values
    // await driver?.tap(find.byValueKey("plugboard_switch"));
    // takeScreenshot(driver!, "plugboard.png");
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
    // await driver?.tap(find.byValueKey("plugboard_switch"));

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

    // enable plugboard in correct order and continue typing
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

    // finally reset and continue typing
    await driver?.tap(find.byValueKey("reset_plugboard"));

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

  test("Persistent activation state (toggle)",
      timeout: const Timeout(Duration(minutes: 3)), () async {
    await login(driver);
    await resetSelectedMachine(driver);
    await driver?.waitFor(find.byValueKey("plugboard_container"));

    // create new machine with disabled plugboard
    const machineName = "NoPlugboardMachine";
    await createSimpleMachine(driver, machineName, false);
    await selectMachineByName(driver, machineName);
    await driver?.waitForAbsent(
      find.byValueKey("plugboard_container"),
      timeout: const Duration(seconds: 3),
    );

    // create new machine with disabled plugboard
    const machineName2 = "PlugboardMachine";
    await createSimpleMachine(driver, machineName2, true);
    await selectMachineByName(driver, machineName2);
    await driver?.waitFor(
      find.byValueKey("plugboard_container"),
      timeout: const Duration(seconds: 3),
    );

    await logout(driver);

    // create machine with same name but without plugboard
    await login(driver, username: "user2", password: "pass2");
    const machineName3 = "NoPlugboardMachineNext";
    await createSimpleMachine(driver, machineName3, false, offset: 19);
    await selectMachineByName(driver, machineName3);
    await driver?.waitForAbsent(
      find.byValueKey("plugboard_container"),
      timeout: const Duration(seconds: 3),
    );

    await logout(driver);

    // check if both are persistent after logging in again
    await login(driver);
    await selectMachineByName(driver, machineName);
    await driver?.waitForAbsent(
      find.byValueKey("plugboard_container"),
      timeout: const Duration(seconds: 3),
    );

    await selectMachineByName(driver, machineName2);
    await driver?.waitFor(
      find.byValueKey("plugboard_container"),
      timeout: const Duration(seconds: 3),
    );

    await logout(driver);

    // cleanup
    await login(driver);
    await deleteMachine(driver, machineName);
    await deleteMachine(driver, machineName2);
    await logout(driver);

    await login(driver, username: "user2", password: "pass2");
    await deleteMachine(driver, machineName3);
    await logout(driver);
  });
}
