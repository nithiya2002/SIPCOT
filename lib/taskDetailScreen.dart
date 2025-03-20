import 'package:flutter/material.dart';
import 'package:sipcot/surveyForm.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDetailScreen extends StatelessWidget {
  final Map<String, dynamic> task;

  TaskDetailScreen({required this.task});

  void _openGoogleMaps() async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${task['lat']},${task['lng']}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open Google Maps';
    }
  }

  void _navigateToForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SurveyFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(task['title'])),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Navigate to Location'),
            onTap: _openGoogleMaps,
          ),
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('Fill Survey Form'),
            onTap: () => _navigateToForm(context),
          ),
        ],
      ),
    );
  }
}
