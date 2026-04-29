import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class ViewOnceScreen extends StatefulWidget {
  final String? imagePath;
  final String? videoPath;
  final String? audioPath;
  final VoidCallback? onOpened;

  const ViewOnceScreen({
    super.key,
    this.imagePath,
    this.videoPath,
    this.audioPath,
    this.onOpened,
  });

  @override
  State<ViewOnceScreen> createState() => _ViewOnceScreenState();
}

class _ViewOnceScreenState extends State<ViewOnceScreen> {
  VideoPlayerController? _videoController;
  bool _hasOpened = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoPath != null) {
      _videoController = VideoPlayerController.file(File(widget.videoPath!))
        ..initialize().then((_) {
          if (mounted) setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _markAsOpened() {
    if (!_hasOpened) {
      setState(() => _hasOpened = true);
      widget.onOpened?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'View Once',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (_hasOpened)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Opened',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Center(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.imagePath != null) {
      return GestureDetector(
        onTap: _markAsOpened,
        child: Image.file(
          File(widget.imagePath!),
          fit: BoxFit.contain,
        ),
      );
    } else if (widget.videoPath != null && _videoController != null) {
      return GestureDetector(
        onTap: () {
          _markAsOpened();
          setState(() {
            if (_isPlaying) {
              _videoController!.pause();
            } else {
              _videoController!.play();
            }
            _isPlaying = !_isPlaying;
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            _videoController!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  )
                : const CircularProgressIndicator(color: Colors.white),
            if (!_isPlaying)
              const Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 80,
              ),
          ],
        ),
      );
    } else if (widget.audioPath != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.audiotrack,
            color: Colors.white,
            size: 100,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _markAsOpened();
              // Play audio
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
          ),
        ],
      );
    }
    return const Center(
      child: Text(
        'Media not available',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
