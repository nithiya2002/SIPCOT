import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaPreviewScreen extends StatefulWidget {
  final List<String> mediaUrls;
  final String Park_name;
  final int point_id;

  const MediaPreviewScreen({super.key, required this.Park_name, required this.point_id, required this.mediaUrls});

  @override
  _MediaPreviewScreenState createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  String? selectedMedia;
  VideoPlayerController? _videoController;
  bool _isScreenReady = false;
  bool _isLoading = true;
  final Map<String, VideoPlayerController> _videoControllers = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedMedia = widget.mediaUrls.isNotEmpty ? widget.mediaUrls.first : null;
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

    for (String url in widget.mediaUrls) {
      if (url.endsWith(".mp4")) {
        VideoPlayerController controller = VideoPlayerController.network(url);
        _videoControllers[url] = controller;
        preloadFutures.add(controller.initialize());
      }
    }

    await Future.wait(preloadFutures);
    
    if (mounted) {
      setState(() {
        if (selectedMedia!.endsWith(".mp4")) {
          _videoController = _videoControllers[selectedMedia!];
        }
        _isScreenReady = true;
        _isLoading = false;
      });
    }
  }

  void _selectMedia(String url) {
    setState(() {
      _isLoading = true;
      _videoController?.pause();
      selectedMedia = url;
      if (url.endsWith(".mp4")) {
        _videoController = _videoControllers[url];
        _videoController?.play();
      }
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.Park_name} - ID: ${widget.point_id}")),
      body: Column(
        children: [
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
                            color: selectedMedia == url ? Colors.blue : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: isVideo ? _buildVideoThumbnail(url) : _buildImageThumbnail(url),
                            ),
                            if (isVideo) const Icon(Icons.play_circle_fill, color: Colors.white54, size: 30),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : selectedMedia!.endsWith(".mp4")
                    ? _buildVideoPlayer()
                    : _buildImagePreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoThumbnail(String url) {
    final controller = _videoControllers[url];
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
    return Container(width: 120, height: 84, color: Colors.grey.shade200);
  }

  Widget _buildImageThumbnail(String url) {
    return Image.network(url, width: 120, height: 84, fit: BoxFit.cover, loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return Container(
        width: 120,
        height: 84,
        color: Colors.grey.shade300,
        child: const Center(child: CircularProgressIndicator()),
      );
    });
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
    return Image.network(selectedMedia!, fit: BoxFit.contain, loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return const Center(child: CircularProgressIndicator());
    });
  }
}
