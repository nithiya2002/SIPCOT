import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageCaptureScreen extends StatefulWidget {
  const ImageCaptureScreen({super.key});

  @override
  State<ImageCaptureScreen> createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  File? _capturedImage;
  bool _isProcessing = false;
  Position? _currentPosition;
  String _permissionStatus = 'Checking permissions...';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    setState(() => _permissionStatus = 'Checking location permission...');

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _permissionStatus = 'Location services are disabled');
      if (Platform.isIOS) {
        await Geolocator.openLocationSettings();
      }
      return;
    }

    // Check permission status
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _permissionStatus = 'Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(
        () => _permissionStatus = 'Location permission permanently denied',
      );
      await openAppSettings();
      return;
    }

    // Location permission granted
    setState(() => _permissionStatus = 'Location permission granted');
    await _getCurrentLocation();
    _checkCameraPermission(); // Proceed to check camera permission
  }

  Future<void> _checkCameraPermission() async {
    setState(() => _permissionStatus = 'Checking camera permission...');

    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isPermanentlyDenied) {
        setState(
          () =>
              _permissionStatus =
                  'Camera permission permanently denied. Open app settings to enable.',
        );
        await openAppSettings();
        return;
      }
      if (!status.isGranted) {
        setState(() => _permissionStatus = 'Camera permission denied');
        return;
      }
    }
    // All permissions granted
    setState(() => _permissionStatus = 'All permissions granted');
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() => _currentPosition = position);
    } catch (e) {
      setState(
        () => _permissionStatus = 'Error getting location: ${e.toString()}',
      );
    }
  }

  Future<void> _captureAndOverlayImage() async {
    final cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      setState(() => _permissionStatus = 'Camera permission required');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required to take photos'),
        ),
      );
      return;
    }

    // if (_permissionStatus != 'All permissions granted') {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text(_permissionStatus)));
    //   return;
    // }

    setState(() => _isProcessing = true);

    try {
      // Refresh location before capture
      //   await _getCurrentLocation();

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 90,
      );

      if (pickedFile == null) {
        setState(() => _isProcessing = false);
        return;
      }

      final originalImage = File(pickedFile.path);
      final overlaidImage = await _addWatermark(originalImage);

      // Save to temporary directory for display
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/watermarked_$timestamp.jpg');
      await tempFile.writeAsBytes(overlaidImage);

      // Save to gallery
      await ImageGallerySaver.saveFile(tempFile.path);

      setState(() {
        _capturedImage = tempFile;
        _isProcessing = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image saved with watermark!")),
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<Uint8List> _addWatermark(File imageFile) async {
    final originalImage = await _loadUiImage(imageFile);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(
        0,
        0,
        originalImage.width.toDouble(),
        originalImage.height.toDouble(),
      ),
    );
    final paint = Paint();

    // Draw original image
    canvas.drawImage(originalImage, Offset.zero, paint);

    // Prepare watermark text
    final watermarkText = """
    Lat: ${_currentPosition?.latitude.toStringAsFixed(6) ?? 'N/A'}
    Lng: ${_currentPosition?.longitude.toStringAsFixed(6) ?? 'N/A'}
    ${DateTime.now().toString().substring(0, 19)}
    """;

    // Create text style
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: _calculateFontSize(originalImage),
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.8),
          blurRadius: 6,
          offset: const Offset(2, 2),
        ),
      ],
    );

    // Draw watermark text at bottom left
    final textSpan = TextSpan(text: watermarkText, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    textPainter.layout(maxWidth: originalImage.width.toDouble() * 0.8);

    // Position at bottom left with 5% margin
    final offset = Offset(
      originalImage.width.toDouble() * 0.05,
      originalImage.height.toDouble() -
          textPainter.height -
          (originalImage.height.toDouble() * 0.05),
    );

    textPainter.paint(canvas, offset);

    // Convert to image and then to byte data
    final watermarkedImage = await recorder.endRecording().toImage(
      originalImage.width,
      originalImage.height,
    );

    final byteData = await watermarkedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return byteData!.buffer.asUint8List();
  }

  double _calculateFontSize(ui.Image image) {
    final diagonal = math.sqrt(
      math.pow(image.width, 2) + math.pow(image.height, 2),
    );
    return diagonal * 0.02;
  }

  Future<ui.Image> _loadUiImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(imageBytes, completer.complete);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Geo-Tagged Camera"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkLocationPermission,
            tooltip: 'Refresh permissions',
          ),
        ],
      ),
      body: Column(
        children: [
          // Permission status
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              _permissionStatus,
              style: TextStyle(
                color:
                    _permissionStatus == 'All permissions granted'
                        ? Colors.green
                        : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Location info
          if (_currentPosition != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Current Location: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),

          // Capture button
          ElevatedButton.icon(
            onPressed: _captureAndOverlayImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text("Capture Image"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              backgroundColor:
                  _permissionStatus == 'All permissions granted'
                      ? Colors.blue
                      : Colors.grey,
            ),
          ),

          const SizedBox(height: 20),

          // Image display
          if (_isProcessing)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Processing image...'),
                  ],
                ),
              ),
            )
          else if (_capturedImage != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InteractiveViewer(
                  maxScale: 5.0,
                  child: Image.file(_capturedImage!),
                ),
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text(
                  "No image captured yet.\nGrant permissions and tap the button to take a photo.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
