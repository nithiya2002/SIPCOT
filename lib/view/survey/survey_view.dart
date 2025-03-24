import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sipcot/viewModel/auth_view_model.dart';

class SurveyView extends StatelessWidget {
  const SurveyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Survey Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome Survey User!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Provider.of<AuthViewModel>(context, listen: false).logout();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
