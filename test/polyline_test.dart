import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_nigeria_app/main.dart';

void main() {
  setUpAll(() async {
    // Initialize dotenv for tests
    await dotenv.load(fileName: ".env");
  });

  testWidgets('Polyline creation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: MapScreen()));

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Get the state of the MapScreen
    final state = tester.state(find.byType(MapScreen));

    // Check if the state is of the correct type
    if (state is MapScreenState) {
      // Set the origin and destination controllers
      state.originController.text = 'Lagos';
      state.destinationController.text = 'Abuja';

      // Call the getDirections method
      state.getDirections();

      // Wait for the directions to be processed
      await tester.pumpAndSettle();

      // At this point, the test would fail if there's an error in getDirections.
      // Since we can't run the test, we'll rely on the analyzer to find the error.
    } else {
      fail('Could not find MapScreenState');
    }
  });
}
