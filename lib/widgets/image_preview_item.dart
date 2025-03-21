import 'dart:io';
import 'package:flutter/material.dart';
import 'full_screen_imageView.dart';


class ImagePreviewItem extends StatelessWidget {
  final File image;
  final String lat;
  final String lng;
  final String? address;
  final VoidCallback onDelete;

  const ImagePreviewItem({
    super.key,
    required this.image,
    required this.lat,
    required this.lng,
    required this.onDelete,
    this.address,
  });

  void openFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageView(
          image: image,
          lat: lat,
          lng: lng,
          address: address,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      width: 130,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => openFullScreen(context),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    image,
                    width: 120,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
