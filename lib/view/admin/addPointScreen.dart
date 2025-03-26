import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sipcot/viewModel/map_vm.dart';
import 'package:get/get.dart';

class AddPointScreen extends StatefulWidget {
  final LatLng selectedLocation;
  final List<dynamic> surveySuggestions;

  const AddPointScreen({
    Key? key,
    required this.selectedLocation,
    required this.surveySuggestions
  }) : super(key: key);

  @override
  _AddPointScreenState createState() => _AddPointScreenState();
}

class _AddPointScreenState extends State<AddPointScreen> {
  late TextEditingController _surveyController;
  String? _selectedSurveyNumber;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _surveyController = TextEditingController();
  }

  @override
  void dispose() {
    _surveyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Point'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Selected Location:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${widget.selectedLocation.latitude}, ${widget.selectedLocation.longitude}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 16),
              // Dropdown for survey numbers
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Survey Number',
                  border: OutlineInputBorder(),
                ),
                items: widget.surveySuggestions
                    .map((survey) => DropdownMenuItem(
                  value: survey.toString(),
                  child: Text(survey.toString()),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSurveyNumber = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a survey number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Additional details text field (optional)
              TextFormField(
                controller: _surveyController,
                decoration: InputDecoration(
                  labelText: 'Additional Details (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addNewPoint,
                child: Text('Add Point'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewPoint() {
    if (_formKey.currentState!.validate()) {
      // Get the MapViewModel
      final mapViewModel = Provider.of<MapViewModel>(context, listen: false);

      // Check if a point already exists for this survey number
      bool pointExists = mapViewModel.fieldPoints.any((marker) {
        // Assuming the marker's properties can be accessed to check survey number
        // You might need to adjust this based on how your field points are stored
        return marker.markerId.value.contains(_selectedSurveyNumber!);
      });

      if (pointExists) {
        // Show error if point already exists
        Get.snackbar(
          'Error',
          'A point already exists for this survey number',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Add the new point
      mapViewModel.addNewFieldPoint(
        location: widget.selectedLocation,
        surveyNumber: _selectedSurveyNumber!,
        additionalDetails: _surveyController.text,
      );

      // Navigate back to the map
      Get.back();
    }
  }
}