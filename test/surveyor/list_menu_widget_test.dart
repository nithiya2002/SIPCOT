import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipcot/model/location_model.dart';
import 'package:sipcot/utility/convert_text_icon.dart';
import 'package:sipcot/view/survey/widget/list_menu_widget.dart';
import 'package:sipcot/view/survey/widget/map_button.dart';

void main() {
  testWidgets('ListMenuWidget functionality test', (WidgetTester tester) async {
    // Arrange
    const testTitle = 'Test Title';
    const testSubTitle = 'Test Subtitle';
    const testNumber = '1';
    bool onTapCalled = false;

    // Create a test location
    final testStartLocation = Location( 12.9716,  77.5946);
    final testDestinationLocation = Location( 13.0358,  77.5970);

    // Act - Render the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListMenuWidget(
            title: testTitle,
            subTitle: testSubTitle,
            numberString: testNumber,
            onTap: () {
              onTapCalled = true;
            },
            startLocation: testStartLocation,
            destinationLocation: testDestinationLocation,
          ),
        ),
      ),
    );

    // Assert - Verify if widgets are displayed correctly
    expect(find.text(testTitle), findsOneWidget);
    expect(find.text(testSubTitle), findsOneWidget);
    expect(find.byType(CircularTextIcon), findsOneWidget);
    expect(find.byType(MapButton), findsOneWidget);

    // Simulate onTap action and check if it gets triggered
    await tester.tap(find.byType(ListTile));
    await tester.pump();

    expect(onTapCalled, true);
  });
}