import 'package:flutter_test/flutter_test.dart';
import 'package:enigma/main.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  testWidgets('PageVariants widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the PageVariants widget is rendered
    expect(find.byType(PageVariants), findsOneWidget);

    // Verify that Enigma buttons are rendered
    expect(find.text('Enigma I'), findsOneWidget);
    expect(find.text('Norway Enigma'), findsOneWidget);
    expect(find.text('Enigma M3'), findsOneWidget);

    // Tap on Enigma I button and verify the URL launching
    await tester.tap(find.text('Enigma I'));
    await tester.pump(); // Wait for the animation to complete
    expect(await canLaunchUrl(Uri.parse('https://enigmaI.com')), isTrue);

    // Tap on Norway Enigma button and verify the URL launching
    await tester.tap(find.text('Norway Enigma'));
    await tester.pump(); // Wait for the animation to complete
    expect(await canLaunchUrl(Uri.parse('https://google.com')), isTrue);

    // Tap on Enigma M3 button and verify the URL launching
    await tester.tap(find.text('Enigma M3'));
    await tester.pump(); // Wait for the animation to complete
    expect(await canLaunchUrl(Uri.parse('https://enigmam3.com')), isTrue);
  });
}
