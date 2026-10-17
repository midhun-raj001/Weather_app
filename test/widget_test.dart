import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/main.dart';

void main() {
  testWidgets('Weather app loads basic UI', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());

    // Verify app shows search field
    expect(find.byType(TextField), findsOneWidget);

    // Verify city text appears (default city)
    expect(find.textContaining('Chennai'), findsOneWidget);

    // Verify search icon exists
    expect(find.byIcon(Icons.search), findsOneWidget);

    // Verify location icon exists
    expect(find.byIcon(Icons.my_location), findsOneWidget);
  });
}
