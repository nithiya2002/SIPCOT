import 'package:flutter/material.dart';

class ImageLocationOverlay extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String address;
  final String timestamp;

  const ImageLocationOverlay({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Lat: ${latitude.toStringAsFixed(5)}, Lon: ${longitude.toStringAsFixed(5)}",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              "Address: $address",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              "Date: $timestamp",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}