import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermission extends StatefulWidget {
  final Function(Position?) onLocationChanged;
  final Function(String) onPermissionChanged;

  const LocationPermission({
    super.key,
    required this.onLocationChanged,
    required this.onPermissionChanged,
  });

  @override
  State<LocationPermission> createState() => _LocationPermissionState();
}

class _LocationPermissionState extends State<LocationPermission> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
