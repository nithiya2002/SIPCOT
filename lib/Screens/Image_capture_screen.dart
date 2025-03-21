import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../widgets/captured_image_view.dart';
import '../widgets/camera_capture_button.dart';

class ImageCaptureScreen extends StatefulWidget {
  const ImageCaptureScreen({Key? key}) : super(key: key);

  @override
  State<ImageCaptureScreen> createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  File? _imageFile;
  double? _latitude;
  double? _longitude;
  String? _address;
  String? _timestamp;

  final ImagePicker _picker = ImagePicker();

  Future<void> _captureImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.camera);

    if (file != null) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.country}";
      String time = DateTime.now().toString();

      setState(() {
        _imageFile = File(file.path);
        _latitude = position.latitude;
        _longitude = position.longitude;
        _address = address;
        _timestamp = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _imageFile == null
          ? const Center(child: Text("Tap + to capture image"))
          : CapturedImageView(
        image: _imageFile!,
        latitude: _latitude!,
        longitude: _longitude!,
        address: _address!,
        timestamp: _timestamp!,
      ),
      floatingActionButton: CameraCaptureButton(onPressed: _captureImage),
    );
  }
}