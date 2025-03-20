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
    if (latitude == null && longitude == null && address == null && timestamp == null) {
      return const SizedBox();
    }

    return Positioned(
      bottom: 10,
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
            if (latitude != null && longitude != null)
              Text(
                "Lat: ${latitude!.toStringAsFixed(5)}, Lon: ${longitude!.toStringAsFixed(5)}",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            if (address != null)
              Text(
                "Address: $address",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            if (timestamp != null)
              Text(
                "Date: ${timestamp}",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
