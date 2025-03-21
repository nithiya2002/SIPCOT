import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'image_preview_item.dart';

class ImageCaptureSection extends StatefulWidget {
  final String latitude;
  final String longitude;

  const ImageCaptureSection({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<ImageCaptureSection> createState() => _ImageCaptureSectionState();
}

class _ImageCaptureSectionState extends State<ImageCaptureSection> {
  final ImagePicker _picker = ImagePicker();
  List<File> capturedImages = [];

  Future<void> captureImage() async {
    if (capturedImages.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Maximum 4 images can be captured.")),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        capturedImages.add(File(image.path));
      });
    }
  }

  void deleteImage(int index) {
    setState(() {
      capturedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: captureImage,
          icon: Icon(Icons.camera_alt),
          label: Text("Capture Image"),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        SizedBox(height: 10),
        if (capturedImages.isNotEmpty)
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: capturedImages.length,
              itemBuilder: (context, index) {
                return ImagePreviewItem(
                  image: capturedImages[index],
                  lat: widget.latitude,
                  lng: widget.longitude,
                  onDelete: () => deleteImage(index),
                );
              },
            ),
          ),
      ],
    );
  }
}
