import 'package:flutter/material.dart';
import 'package:sipcot/utility/custom_logger.dart';

import 'image_upload.dart';
import 'survey_fields.dart';
import 'video_upload.dart';

class SurveyForm extends StatefulWidget {
  const SurveyForm({super.key});

  @override
  State<SurveyForm> createState() => _SurveyFormState();
}

class _SurveyFormState extends State<SurveyForm> {
  final log = createLogger(SurveyForm);
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'surveyNumber': '',
    'area': '',
    'landType': '',
    'remarks': '',
    'status': '',
    'images': [],
    'video': null,
  };

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Process form data
      log.i(_formData);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Survey Submitted Successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Survey Form - 158')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SurveyFields(
                onSaved: (values) {
                  _formData['surveyNumber'] = values['surveyNumber'];
                  _formData['area'] = values['area'];
                  _formData['landType'] = values['landType'];
                  _formData['remarks'] = values['remarks'];
                  _formData['status'] = values['status'];
                },
              ),
              SizedBox(height: 20),

              ImageUpload(
                onImagesSelected: (images) {
                  _formData['images'] = images;
                },
              ),

              Text(
                'Video Upload',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              VideoUpload(
                onVideoSelected: (video) {
                  if (video != null) {
                    log.i('Video recorded: ${video.path}');
                  }
                  _formData['video'] = video;
                },
                size: 180,
              ),
              SizedBox(height: 30),
              FilledButton(
                onPressed: _submitForm,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
