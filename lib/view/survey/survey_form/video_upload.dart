import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class VideoUpload extends StatefulWidget {
  const VideoUpload({
    super.key,
    required this.onVideoSelected,
    this.size = 150,
  });

  final Function(File?) onVideoSelected;
  final double size;

  @override
  State<VideoUpload> createState() => _VideoUploadState();
}

class _VideoUploadState extends State<VideoUpload> {
  File? _video;
  final ImagePicker _picker = ImagePicker();

  Future<void> _recordVideo() async {
    final pickedFile = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 30), // Optional duration limit
    );

    if (pickedFile != null) {
      setState(() {
        _video = File(pickedFile.path);
      });
      widget.onVideoSelected(_video);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _recordVideo,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            _video != null
                ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Icon(Icons.videocam, size: 50),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _video = null;
                            widget.onVideoSelected(null);
                          });
                        },
                      ),
                    ),
                  ],
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam, size: 40),
                    SizedBox(height: 8),
                    Text('Tap to Record', style: TextStyle(fontSize: 12)),
                  ],
                ),
      ),
    );
  }
}
