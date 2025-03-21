import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FullScreenImageView extends StatelessWidget {
  final File image;
  final String lat;
  final String lng;
  final String? address;

  const FullScreenImageView({
    super.key,
    required this.image,
    required this.lat,
    required this.lng,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Image Preview", style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: Image.file(image),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Latitude: $lat", style: TextStyle(color: Colors.white, fontSize: 12)),
                  Text("Longitude: $lng", style: TextStyle(color: Colors.white, fontSize: 12)),
                  Text("Time: $formattedTime", style: TextStyle(color: Colors.white, fontSize: 12)),
                  if (address != null)
                    Text("Address: $address", style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
