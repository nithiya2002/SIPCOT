import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sipcot/widgets/ImageLocationOverlay.dart';


class CapturedImageView extends StatelessWidget {
  final File image;
  final double latitude;
  final double longitude;
  final String address;
  final String timestamp;

  const CapturedImageView({
    Key? key,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.file(
            image,
            fit: BoxFit.cover,
          ),
        ),
        ImageLocationOverlay(
          latitude: latitude,
          longitude: longitude,
          address: address,
          timestamp: timestamp,
        ),
      ],
    );
  }
}