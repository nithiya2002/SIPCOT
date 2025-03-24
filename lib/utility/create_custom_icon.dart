import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sipcot/utility/custom_logger.dart';

class MapUtils {
  final log = createLogger(MapUtils);
  static Future<BitmapDescriptor> createCustomIcon(String label) async {
    try {
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);

      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontSize: 24.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, 0));

      final ui.Image image = await pictureRecorder.endRecording().toImage(
        textPainter.width.toInt(),
        textPainter.height.toInt(),
      );
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List imageData = byteData!.buffer.asUint8List();

      return BitmapDescriptor.fromBytes(imageData);
    } catch (e) {
      print("Error creating custom icon: $e");
      return BitmapDescriptor.defaultMarker; // Fallback to default marker
    }
  }

  static Future<BitmapDescriptor> getTriangleMarker(Color color) async {
    try {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Paint paint = Paint()..color = color;

      final double size = 100; // Adjust size if needed

      final Path path =
          Path()
            ..moveTo(size / 2, 0) // Top center
            ..lineTo(size, size) // Bottom right
            ..lineTo(0, size) // Bottom left
            ..close();

      canvas.drawPath(path, paint);

      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List uint8list = byteData!.buffer.asUint8List();

      return BitmapDescriptor.fromBytes(uint8list);
    } catch (e) {
      print("Error creating custom icon: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }
}
