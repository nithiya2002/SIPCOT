import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:sipcot/view/admin/admin_view.dart';

import 'package:sipcot/viewModel/auth_view_model.dart';
import 'package:sipcot/viewModel/map_vm.dart';

import 'admin_view_test.mocks.dart';

@GenerateMocks([GoogleMapController, MapViewModel, AuthViewModel])
void main() {
  late MockMapViewModel mockMapViewModel;
  late MockGoogleMapController mockGoogleMapController;
  late MockAuthViewModel mockAuthViewModel;

  setUp(() {
    mockMapViewModel = MockMapViewModel();
    mockGoogleMapController = MockGoogleMapController();
    mockAuthViewModel = MockAuthViewModel();

    when(mockMapViewModel.polygonsSite).thenReturn({});
    when(mockMapViewModel.polygons).thenReturn({});
    when(mockMapViewModel.newBoundaryPolygons).thenReturn({});
    when(mockMapViewModel.cascadeBoundaryPolygons).thenReturn({});
    when(mockMapViewModel.fmbBoundaryPolygon).thenReturn({});
    when(mockMapViewModel.markers).thenReturn({});
    when(mockMapViewModel.fieldPoints).thenReturn({});
    when(mockMapViewModel.cascadeMakers).thenReturn({});
    when(mockMapViewModel.fmb_marker).thenReturn({});
    when(mockMapViewModel.isLoadingSiteBoundary).thenReturn(false);
  });

  Widget createTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MapViewModel>.value(value: mockMapViewModel),
        ChangeNotifierProvider<AuthViewModel>.value(value: mockAuthViewModel),
      ],
      child: const GetMaterialApp(
        home: AdminView(),
      ),
    );
  }

  testWidgets('AdminView renders and initializes properly', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget());
    await tester.pump();

    expect(find.text('SIPCOT'), findsOneWidget);
    expect(find.byType(GoogleMap), findsOneWidget);
  });

  testWidgets('Tapping add button navigates to AddPointScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, contains('AddPointScreen'));
  });

  testWidgets('Tapping logout button calls logout function', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pump();

    verify(mockAuthViewModel.logout()).called(1);
  });

  testWidgets('Tapping refresh button triggers data fetch', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    verify(mockMapViewModel.fetchSiteBoundary()).called(1);
    verify(mockMapViewModel.fetchFieldPoints()).called(1);
    verify(mockMapViewModel.fetchCadastralData("SIPCOT")).called(1);
    verify(mockMapViewModel.fetchFMBData("SIPCOT")).called(1);
  });

  testWidgets('Toggle switches update map layers', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget());
    await tester.pump();

    await tester.tap(find.text('Show Points'));
    await tester.pump();
    verify(mockMapViewModel.toggleFieldPoints(any)).called(1);

    await tester.tap(find.text('Site Boundary'));
    await tester.pump();
    verify(mockMapViewModel.toggleSiteBoundary(any)).called(1);
  });
}
