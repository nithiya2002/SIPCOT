import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> getTriangleMarker(Color color) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  final Paint paint = Paint()..color = color;

  final double size = 100; // Adjust size if needed

  final Path path = Path()
    ..moveTo(size / 2, 0) // Top center
    ..lineTo(size, size) // Bottom right
    ..lineTo(0, size) // Bottom left
    ..close();

  canvas.drawPath(path, paint);

  final ui.Picture picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List uint8list = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(uint8list);
}
