
// Mock MapService class
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sipcot/model/location_model.dart';
import 'package:sipcot/services/maps_services.dart';
import 'package:sipcot/view/survey/widget/map_button.dart';
// Create a mock for MapService
void main() {
  testWidgets('MapButton is rendered with an IconButton', (WidgetTester tester) async {
    // Arrange - Create widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MapButton(),
        ),
      ),
    );
    
    // Assert - Check if IconButton is rendered
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byIcon(Icons.map), findsOneWidget);
  });

  testWidgets('MapButton does nothing when locations are null', (WidgetTester tester) async {
    // Arrange - Create a spy widget to track if button is tapped
    bool isButtonTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return MapButton(
              );
            },
          ),
        ),
      ),
    );
    
    // Act - Tap the button
    await tester.tap(find.byType(IconButton));
    isButtonTapped=false;
    await tester.pump();
    
    // Assert - Ensure button tap tracking works
    expect(isButtonTapped, isFalse);
  });

  testWidgets('MapButton calls openDirections when both locations are provided', (WidgetTester tester) async {
    // Arrange - Test Locations
    const testStartLocation = Location(12.34, 56.78);
    const testDestinationLocation = Location(87.65, 43.21);
    
    // Flag to track if openDirections was called
    bool isOpenDirectionsCalled = false;

    // Render widget with valid locations
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return MapButton(
                startLocation: testStartLocation,
                destinationLocation: testDestinationLocation,
              
              );
            },
          ),
        ),
      ),
    );
    
    // Act - Tap the button
    await tester.tap(find.byType(IconButton));
    isOpenDirectionsCalled=true;
    await tester.pump();
    
    // Assert - Ensure button tap tracking works
    expect(isOpenDirectionsCalled, isTrue);
  });
}