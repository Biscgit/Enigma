import 'dart:io';
import 'package:test/test.dart';
import 'tastatur_test.dart' as tastatur_test;
import 'keyhistory_test.dart' as keyhistory_test;
import 'plugboard_test.dart' as plugboard_test;
import 'authentication_test.dart' as authentication_test;
import 'rotor_test.dart' as rotor_test;
import 'add_machine_test.dart' as add_machine_test;

void main() {
  Directory('screenshots').create();

  group('Authentication:', () {
    authentication_test.main();
  });

  group("Tastatur:", () {
    tastatur_test.main();
  });

  group('KeyHistory:', () {
    keyhistory_test.main();
  });

  group('Rotors:', () {
    rotor_test.main();
  });

  group('Adding machines:', () {
    add_machine_test.main();
  });

  group('Plugboard:', () {
    plugboard_test.main();
  });
}
