import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exercise/main.dart';  // Import your main.dart file

void main() {
  testWidgets('Sports Inventory App renders correctly', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(MyApp());  // Ensure MyApp() is called here

    // Verify that the main screen contains the correct text.
    expect(find.text('Sports Equipment Management'), findsOneWidget);
    expect(find.text('View Sports Equipment Inventory'), findsOneWidget);

    // Tap on the button to view the sports inventory.
    await tester.tap(find.text('View Sports Equipment Inventory'));
    await tester.pumpAndSettle(); // Wait for the navigation to complete.

    // Verify that the sports inventory screen contains the equipment list (categories).
    expect(find.text('Football'), findsOneWidget);
    expect(find.text('Basketball'), findsOneWidget);
    expect(find.text('Volleyball'), findsOneWidget);
    expect(find.text('Badminton'), findsOneWidget);
    expect(find.text('Netball'), findsOneWidget);
    expect(find.text('Handball'), findsOneWidget);
  });
}
