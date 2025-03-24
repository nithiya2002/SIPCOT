import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaPreviewScreen extends StatefulWidget {
  final List<String> mediaUrls;

  const MediaPreviewScreen({super.key, required this.mediaUrls});

  @override
  _MediaPreviewScreenState createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  String? selectedMedia;
  VideoPlayerController? _videoController;
  bool _isScreenReady = false;
  final Map<String, VideoPlayerController> _videoControllers = {};
  final ScrollController _scrollController =
      ScrollController(); // Add this line

  @override
  void initState() {
    super.initState();
    _preloadMedia();
  }

  Future<void> _preloadMedia() async {
    if (widget.mediaUrls.isEmpty) {
      setState(() {
        _isScreenReady = true;
      });
      return;
    }

    List<Future> preloadFutures = [];

    // Initialize controllers for all videos
    for (String url in widget.mediaUrls) {
      if (url.endsWith(".mp4")) {
        VideoPlayerController controller = VideoPlayerController.network(url);
        _videoControllers[url] = controller;

        // Create future for each video initialization
        preloadFutures.add(
          controller.initialize().then((_) {
            // Create a thumbnail by seeking to 1 second
            if (controller.value.duration.inSeconds > 2) {
              controller.seekTo(const Duration(seconds: 1));
            }
          }),
        );
      }
    }

    // Start initializing all videos
    await Future.wait(preloadFutures);

    if (mounted) {
      setState(() {
        selectedMedia = widget.mediaUrls.first;
        if (selectedMedia!.endsWith(".mp4")) {
          _videoController = _videoControllers[selectedMedia!];
        }
        _isScreenReady = true;
      });
    }
  }

  void _selectMedia(String url) {
    setState(() {
      // Pause current video if any
      _videoController?.pause();

      selectedMedia = url;
      if (url.endsWith(".mp4")) {
        _videoController = _videoControllers[url];
        _videoController?.play();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the controller
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Media Preview")),
      body: Column(
        children: [
          // Horizontal scrollable media row with scrollbar
          SizedBox(
            height: 150,

            child: Scrollbar(
              thickness: 8,
              thumbVisibility: widget.mediaUrls.length > 2,
              controller: _scrollController,
              child: Padding(
                padding: EdgeInsets.only(top: 16),
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.mediaUrls.length,
                  itemBuilder: (context, index) {
                    String url = widget.mediaUrls[index];
                    bool isVideo = url.endsWith(".mp4");
                    return GestureDetector(
                      onTap: () => _selectMedia(url),
                      child: Container(
                        margin: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                selectedMedia == url
                                    ? Colors.blue
                                    : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child:
                                  isVideo
                                      ? _buildVideoThumbnail(url)
                                      : Image(
                                        image: NetworkImage(url),
                                        width: 120,
                                        height: 84,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return _buildErrorPlaceholder(
                                            isImage: true,
                                          );
                                        },
                                      ),
                            ),
                            if (isVideo)
                              const Icon(
                                Icons.play_circle_fill,
                                color: Colors.white54,
                                size: 30,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Large preview area - taking all remaining space
          Expanded(
            child:
                selectedMedia != null
                    ? selectedMedia!.endsWith(".mp4")
                        ? _buildVideoPlayer()
                        : _buildImagePreview()
                    : const Text("Select a media item to preview"),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoThumbnail(String url) {
    final controller = _videoControllers[url];

    // Show actual video frame as thumbnail when ready
    if (controller != null && controller.value.isInitialized) {
      return SizedBox(
        width: 120,
        height: 84,
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      );
    }

    // Static thumbnail while loading (no loader)
    return Container(
      width: 120,
      height: 84,
      color: Colors.grey.shade200,
      child: const Icon(Icons.videocam, color: Colors.grey, size: 30),
    );
  }

  Widget _buildErrorPlaceholder({bool isImage = false}) {
    return Container(
      width: 120,
      height: 84,
      color: Colors.grey.shade300,
      child: Icon(
        isImage ? Icons.image_not_supported : Icons.videocam_off,
        color: Colors.grey.shade700,
        size: 30,
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      return Center(
        child: Container(
          margin: EdgeInsets.all(8.0),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
              VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _videoController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    onPressed: () {
                      setState(() {
                        _videoController!.value.isPlaying
                            ? _videoController!.pause()
                            : _videoController!.play();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 150,
              color: Colors.grey.shade100,
              child: const Center(child: Text("Failed to load video")),
            ),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              onPressed: () {
                if (selectedMedia != null && selectedMedia!.endsWith(".mp4")) {
                  _videoControllers[selectedMedia!]?.initialize().then((_) {
                    setState(() {});
                    _videoController = _videoControllers[selectedMedia!];
                    _videoController?.play();
                  });
                }
              },
            ),
          ],
        ),
      );
    }
  }

  Widget _buildImagePreview() {
    return Center(
      child: Image(
        image: NetworkImage(selectedMedia!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 200,
                height: 150,
                color: Colors.grey.shade100,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Failed to load image"),
            ],
          );
        },
      ),
    );
  }
}
