import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sipcot/view/admin/admin_view.dart';
import 'package:provider/provider.dart';
import 'package:sipcot/view/login/login_view.dart';
import 'package:sipcot/view/survey/survey_view.dart';
import 'package:sipcot/viewModel/auth_view_model.dart';
import 'package:sipcot/viewModel/map_vm.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        return AuthViewModel();
      },
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIPCOT Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          // Show loading screen while checking auth state
          if (authViewModel.isLoading && authViewModel.currentUser == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Get the appropriate route based on user email
          final route = authViewModel.getRouteForUser();
          // Navigate to the appropriate screen
          switch (route) {
            case '/admin':
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider(create: (context) => MapViewModel()),
                ],
                child: GetMaterialApp(home: AdminView()),
              );
            case '/survey':
              return const SurveyView();
            default:
              return const LoginView();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginView(),
        '/admin': (context) => const AdminView(),
        '/survey': (context) => const SurveyView(),
      },
    );
  }
}
