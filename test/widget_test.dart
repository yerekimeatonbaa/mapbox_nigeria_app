// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:google_maps_nigeria_app/main.dart';

void main() {
  setUpAll(() async {
    // Initialize dotenv for tests
    await dotenv.load(fileName: ".env");
  });

  testWidgets('App builds without error', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that the app bar title is present
    expect(find.text('Google Maps - Nigeria'), findsOneWidget);

    // The app should build without errors - we don't check for loading text
    // since the map might load quickly in test environment
  });
}
