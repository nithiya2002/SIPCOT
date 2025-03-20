import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomImageUploadField extends StatefulWidget {
  final String? initialImagePath; // Path of the initial image
  final String? text;
  final IconData? icon;
  final Function(File)? onImageSelected;
  final double? height;
  final double? width;

  const CustomImageUploadField({
    super.key,
    this.initialImagePath,
    this.text,
    this.icon,
    this.onImageSelected,
    this.height = 200,
    this.width = double.infinity,
  });

  @override
  State<CustomImageUploadField> createState() => _CustomImageUploadFieldState();
}

class _CustomImageUploadFieldState extends State<CustomImageUploadField> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _showImageSourceSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        if (widget.onImageSelected != null) {
          widget.onImageSelected!(_selectedImage!);
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  String? convertImageToBase64() {
    if (_selectedImage == null) return null;
    try {
      List<int> imageBytes = _selectedImage!.readAsBytesSync();
      return base64Encode(imageBytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceSheet(context),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(
            // color: Colors.grey[300]!,
            // width: 1,
          // ),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.contain,
                ),
              )
            : (widget.initialImagePath != null &&
                    widget.initialImagePath!.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.initialImagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon ?? Icons.cloud_upload,
                        size: 40,
                        color: Colors.grey[600],
                      ),
                      if (widget.text != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.text!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }
}
