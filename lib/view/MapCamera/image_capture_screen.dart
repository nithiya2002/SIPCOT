import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class ImageCaptureScreen extends StatefulWidget {
  const ImageCaptureScreen({Key? key}) : super(key: key);

  @override
  State<ImageCaptureScreen> createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  File? _capturedImage;

  Future<void> _captureAndOverlayImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    File originalImage = File(pickedFile.path);
    Uint8List overlaidImage = await _addWatermark(originalImage);

    final tempFile = File('${(await getTemporaryDirectory()).path}/watermarked.jpg');
    await tempFile.writeAsBytes(overlaidImage);

    await ImageGallerySaver.saveFile(tempFile.path);

    setState(() {
      _capturedImage = tempFile;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Image saved with watermark!")),
    );
  }

  Future<Uint8List> _addWatermark(File imageFile) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);

    ui.Image originalImage = await _loadUiImage(imageFile);
    Paint paint = Paint();

    canvas.drawImage(originalImage, Offset.zero, paint);

    // Draw watermark text
    final textPainter = TextPainter(
      text: TextSpan(
        text: "Lat: 12.9716, Lng: 77.5946\nTime: ${DateTime.now()}",
        style: const TextStyle(color: Colors.white, fontSize: 30),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, const Offset(20, 20));

    ui.Image finalImage = await recorder.endRecording().toImage(
      originalImage.width,
      originalImage.height,
    );

    ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<ui.Image> _loadUiImage(File imageFile) async {
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imageBytes, (ui.Image img) => completer.complete(img));
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Capture Image with Watermark")),
      body: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _captureAndOverlayImage,
            icon: const Icon(Icons.camera),
            label: const Text("Capture Image"),
          ),
          const SizedBox(height: 20),
          if (_capturedImage != null)
            Expanded(child: Image.file(_capturedImage!))
          else
            const Text("No image captured yet."),
        ],
      ),
    );
  }
}
