import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Allow any animations or font loading to complete
    await tester.pumpAndSettle();

    // Basic verification that the app starts and shows the brand name 'AuditSense'.
    expect(find.text('AuditSense'), findsWidgets);
  });
}
