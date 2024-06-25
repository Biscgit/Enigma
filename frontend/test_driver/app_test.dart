import 'package:test/test.dart';
import 'tastatur_test.dart' as tastatur_test;
import 'keyhistory_test.dart' as keyhistory_test;
import 'plugboard_test.dart' as plugboard_test;
import 'authentication_test.dart' as authentication_test;

void main() {
  group('Authentication:', () {
    authentication_test.main();
  });

  group("Tastatur:", () {
    tastatur_test.main();
  });

  group('KeyHistory:', () {
    keyhistory_test.main();
  });

  group('Plugboard:', () {
    plugboard_test.main();
  });
}
