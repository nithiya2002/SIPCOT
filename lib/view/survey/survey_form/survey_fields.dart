import 'package:flutter/material.dart';

class SurveyFields extends StatelessWidget {
  final Function(Map<String, String>) onSaved;

  final _surveyController = TextEditingController(text: '158');
  final _areaController = TextEditingController();
  final _landTypeController = TextEditingController();
  final _remarksController = TextEditingController();
  final _statusController = TextEditingController();

  // Corrected constructor
  SurveyFields({super.key, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _surveyController,
          decoration: InputDecoration(
            labelText: 'Survey Number',
            border: OutlineInputBorder(),
          ),
          readOnly: true,
          onSaved: (value) {
            onSaved({
              'surveyNumber': _surveyController.text,
              'area': _areaController.text,
              'landType': _landTypeController.text,
              'remarks': _remarksController.text,
              'status': _statusController.text,
            });
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _areaController,
          decoration: InputDecoration(
            labelText: 'Area',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter area';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _landTypeController,
          decoration: InputDecoration(
            labelText: 'Land Type',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter land type';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _remarksController,
          decoration: InputDecoration(
            labelText: 'Remarks',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _statusController,
          decoration: InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
