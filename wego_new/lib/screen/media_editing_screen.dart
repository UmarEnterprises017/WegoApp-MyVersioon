import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MediaEditingScreen extends StatefulWidget {
  final String? imagePath;
  final String? videoPath;

  const MediaEditingScreen({
    super.key,
    this.imagePath,
    this.videoPath,
  });

  @override
  State<MediaEditingScreen> createState() => _MediaEditingScreenState();
}

class _MediaEditingScreenState extends State<MediaEditingScreen> {
  bool _isHD = false;
  String _caption = '';
  bool _showStickers = false;
  List<String> _selectedMedia = [];
  int _currentFilterIndex = 0;

  final List<Map<String, dynamic>> _filters = [
    {'name': 'Normal', 'icon': Icons.filter_none},
    {'name': 'Beauty', 'icon': Icons.face},
    {'name': 'Hide Face', 'icon': Icons.visibility_off},
    {'name': 'Background', 'icon': Icons.landscape},
    {'name': 'Spiderman', 'icon': Icons.stars},
    {'name': 'Vintage', 'icon': Icons.auto_awesome},
    {'name': 'B&W', 'icon': Icons.brightness_6},
    {'name': 'Warm', 'icon': Icons.wb_sunny},
  ];

  final List<String> _stickers = [
    '😀', '😍', '😂', '🔥', '❤️', '👍', '🙏', '🎉',
    '🌟', '✨', '💯', '🎵', '🎶', '💕', '💖', '💗',
    '🦋', '🌸', '🌺', '🌹', '🌻', '🌼', '🌷', '💐',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media Preview
          Positioned.fill(
            child: widget.imagePath != null
                ? Image.file(File(widget.imagePath!), fit: BoxFit.cover)
                : widget.videoPath != null
                    ? Container(
                        color: Colors.black,
                        child: const Center(
                          child: Icon(Icons.videocam, size: 100, color: Colors.white),
                        ),
                      )
                    : Container(),
          ),
          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.crop, color: Colors.white),
                          onPressed: _showCropOptions,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: _showTextEditor,
                        ),
                        IconButton(
                          icon: const Icon(Icons.save, color: Colors.white),
                          onPressed: _saveMedia,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Filter Bar
          Positioned(
            right: 0,
            top: 100,
            bottom: 200,
            child: Container(
              width: 70,
              child: ListView.builder(
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _currentFilterIndex = index);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: _currentFilterIndex == index
                            ? Colors.white.withOpacity(0.3)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        filter['icon'],
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Filter Search Icon
          Positioned(
            right: 20,
            top: 80,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: _showFilterSearch,
              ),
            ),
          ),
          // Caption and Stickers
          if (_showStickers)
            Positioned(
              bottom: 150,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
                color: Colors.black87,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search stickers...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                        ),
                        itemCount: _stickers.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Add sticker to media
                            },
                            child: Text(
                              _stickers[index],
                              style: const TextStyle(fontSize: 32),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black87,
                child: Column(
                  children: [
                    // Caption Input
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.photo_library, color: Colors.white),
                          onPressed: _openGallery,
                        ),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Add caption...',
                              hintStyle: const TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onChanged: (value) => _caption = value,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.emoji_emotions, color: Colors.white),
                          onPressed: () {
                            setState(() => _showStickers = !_showStickers);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Quality Selection
                    Row(
                      children: [
                        const Text('Quality: ', style: TextStyle(color: Colors.white)),
                        GestureDetector(
                          onTap: () => setState(() => _isHD = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: !_isHD ? kPurple : Colors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Standard', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => setState(() => _isHD = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isHD ? kPurple : Colors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('HD', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const Spacer(),
                        // Send Button
                        ElevatedButton(
                          onPressed: _sendMedia,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Send', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCropOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Crop Options', style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CropOption(icon: Icons.crop_square, label: 'Square', onTap: () {}),
                _CropOption(icon: Icons.crop_landscape, label: 'Landscape', onTap: () {}),
                _CropOption(icon: Icons.crop_portrait, label: 'Portrait', onTap: () {}),
                _CropOption(icon: Icons.crop_free, label: 'Free', onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTextEditor() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Text', style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 20),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter text...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPurple,
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _saveMedia() {
    // Save to gallery with HD or Standard quality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved in ${_isHD ? 'HD' : 'Standard'} quality')),
    );
  }

  void _showFilterSearch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text('Search Filters', style: TextStyle(color: Colors.white)),
        content: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search filters...',
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openGallery() async {
    final picker = ImagePicker();
    final List<XFile> media = await picker.pickMultipleMedia();
    if (media.isNotEmpty && mounted) {
      setState(() => _selectedMedia = media.map((e) => e.path).toList());
    }
  }

  void _sendMedia() {
    // Send media with caption and quality
    Navigator.pop(context);
  }
}

class _CropOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CropOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

const Color kPurple = Color(0xFF6B4EFF);
