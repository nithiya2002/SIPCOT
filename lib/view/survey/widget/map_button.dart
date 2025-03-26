import 'package:flutter/material.dart';
import '../../../model/location_model.dart';
import '../../../services/maps_services.dart';

class MapButton extends StatelessWidget {
  final Location? startLocation;
  final Location? destinationLocation;

  const MapButton({super.key, this.startLocation, this.destinationLocation});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.map),
      onPressed: () {
        if (startLocation != null && destinationLocation != null) {
          MapService.openDirections(
            context: context,
            start: startLocation!,
            destination: destinationLocation!,
          );
        }
      },
    );
  }
}
