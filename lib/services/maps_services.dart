import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/location_model.dart';

class MapService {
  static Future<void> openDirections({
    required BuildContext context,
    required Location start,
    required Location destination,
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${start.latitude},${start.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&travelmode=driving',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not launch maps')));
    }
  }
}
