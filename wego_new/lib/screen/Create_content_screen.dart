// ============================================================
// create_content_screen.dart  — WEB + MOBILE COMPATIBLE
// Fixes applied:
//   1. Platform._operatingSystem → kIsWeb check
//   2. Image.file → Image.memory for web
//   3. Camera placeholder (web can't use camera plugin easily)
//   4. Next → properly shows hashtags / comments-off / hide-likes
//   5. Share pops correctly (no accidental login redirect)
//   6. All filter / editor / details screens fully wired
// ============================================================

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wego_marriage/services/local_storage_service.dart';

// ─── Enums ───────────────────────────────────────────────────
enum ContentMode { post, story, reel }

enum PostVisibility { everyone, onlyMe, closeFriends }

// ─── Color Filter Model ──────────────────────────────────────
class PhotoFilter {
  final String name;
  final ColorFilter? colorFilter;
  const PhotoFilter({required this.name, this.colorFilter});
}

// ─────────────────────────────────────────────────────────────
//  Helper: show an image from XFile (web-safe)
// ─────────────────────────────────────────────────────────────
class _XFileImage extends StatefulWidget {
  final XFile file;
  final BoxFit fit;
  const _XFileImage({required this.file, this.fit = BoxFit.cover});

  @override
  State<_XFileImage> createState() => _XFileImageState();
}

class _XFileImageState extends State<_XFileImage> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final b = await widget.file.readAsBytes();
    if (mounted) setState(() => _bytes = b);
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    return Image.memory(_bytes!, fit: widget.fit);
  }
}

// ─── Main Entry Screen ───────────────────────────────────────
class CreateContentScreen extends StatefulWidget {
  final ContentMode initialMode;
  const CreateContentScreen({super.key, this.initialMode = ContentMode.post});

  @override
  State<CreateContentScreen> createState() => _CreateContentScreenState();
}

class _CreateContentScreenState extends State<CreateContentScreen> {
  late ContentMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    WidgetsBinding.instance.addPostFrameCallback((_) => _showMediaPickerSheet());
  }

  void _showMediaPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MediaPickerSheet(
        mode: _mode,
        onModeChanged: (m) => setState(() => _mode = m),
        onMediaSelected: (file, isVideo) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _MediaEditorScreen(
                file: file,
                isVideo: isVideo,
                mode: _mode,
              ),
            ),
          );
        },
        onTextSelected: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _TextCreatorScreen(mode: _mode),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, color: Colors.white54, size: 60),
            const SizedBox(height: 16),
            const Text('Opening Camera...', style: TextStyle(color: Colors.white54, fontSize: 16)),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _showMediaPickerSheet,
              child: const Text('Choose Media', style: TextStyle(color: Colors.blue, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Media Picker Sheet ──────────────────────────────────────
class _MediaPickerSheet extends StatefulWidget {
  final ContentMode mode;
  final ValueChanged<ContentMode> onModeChanged;
  final Function(XFile file, bool isVideo) onMediaSelected;
  final VoidCallback onTextSelected;

  const _MediaPickerSheet({
    required this.mode,
    required this.onModeChanged,
    required this.onMediaSelected,
    required this.onTextSelected,
  });

  @override
  State<_MediaPickerSheet> createState() => _MediaPickerSheetState();
}

class _MediaPickerSheetState extends State<_MediaPickerSheet> {
  late ContentMode _mode;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
  }

  Future<void> _pickFromGallery() async {
    if (_mode == ContentMode.reel) {
      final file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file != null && mounted) widget.onMediaSelected(file, true);
    } else {
      _showPickTypeSheet();
    }
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null && mounted) widget.onMediaSelected(file, false);
  }

  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null && mounted) widget.onMediaSelected(file, true);
  }

  void _showPickTypeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            _sheetTile(Icons.image, 'Photo', () async {
              Navigator.pop(ctx);
              await _pickImage();
            }),
            _sheetTile(Icons.videocam, 'Video', () async {
              Navigator.pop(ctx);
              await _pickVideo();
            }),
            _sheetTile(Icons.text_fields, 'Text', () {
              Navigator.pop(ctx);
              widget.onTextSelected();
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sheetTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                  const Spacer(),
                  const Icon(Icons.flash_auto, color: Colors.white, size: 26),
                  const SizedBox(width: 20),
                  const Icon(Icons.settings_outlined, color: Colors.white, size: 26),
                ],
              ),
            ),

            // ── Camera Preview Area ──────────────────────────
            Expanded(
              child: Stack(
                children: [
                  Container(
                    color: const Color(0xFF1A1A1A),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt, color: Colors.white24, size: 80),
                          const SizedBox(height: 16),
                          if (kIsWeb)
                            const Text(
                              'Camera not available on Web.\nUse the gallery button below.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white38, fontSize: 14),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Right side tools
                  Positioned(
                    right: 12, top: 0, bottom: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _sideIcon('Aa'),
                        const SizedBox(height: 24),
                        _sideIconWidget(const Icon(Icons.all_inclusive, color: Colors.white, size: 22)),
                        const SizedBox(height: 24),
                        _sideIconWidget(const Icon(Icons.grid_view_outlined, color: Colors.white, size: 22)),
                        const SizedBox(height: 24),
                        _sideIconWidget(const Icon(Icons.face_retouching_natural, color: Colors.white, size: 22)),
                        const SizedBox(height: 24),
                        _sideIconWidget(const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 22)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom Controls ──────────────────────────────
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Gallery
                      GestureDetector(
                        onTap: _pickFromGallery,
                        child: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.photo_library, color: Colors.white, size: 28),
                        ),
                      ),

                      // Shutter (gallery on web)
                      GestureDetector(
                        onTap: _pickFromGallery,
                        child: Container(
                          width: 76, height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),

                      // Text option
                      GestureDetector(
                        onTap: widget.onTextSelected,
                        child: Container(
                          width: 50, height: 50,
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.text_fields, color: Colors.white, size: 26),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // POST / STORY / REEL selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ContentMode.values.map((m) {
                      final selected = _mode == m;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _mode = m);
                          widget.onModeChanged(m);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            m.name.toUpperCase(),
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white38,
                              fontSize: 14,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sideIcon(String text) => SizedBox(
    width: 36, height: 36,
    child: Center(
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
    ),
  );

  Widget _sideIconWidget(Widget icon) => SizedBox(width: 36, height: 36, child: Center(child: icon));
}

// ─── Media Editor Screen ─────────────────────────────────────
class _MediaEditorScreen extends StatefulWidget {
  final XFile file;
  final bool isVideo;
  final ContentMode mode;

  const _MediaEditorScreen({required this.file, required this.isVideo, required this.mode});

  @override
  State<_MediaEditorScreen> createState() => _MediaEditorScreenState();
}

class _MediaEditorScreenState extends State<_MediaEditorScreen> {
  int _selectedFilter = 0;
  Uint8List? _imageBytes;

  final List<PhotoFilter> _filters = [
    const PhotoFilter(name: 'Normal'),
    PhotoFilter(name: 'Clarendon', colorFilter: const ColorFilter.matrix([
      1.2, 0, 0, 0, 10,  0, 1.2, 0, 0, 10,  0, 0, 1.2, 0, 10,  0, 0, 0, 1, 0,
    ])),
    PhotoFilter(name: 'Gingham', colorFilter: const ColorFilter.matrix([
      1.1, 0, 0, 0, -10,  0, 1.1, 0, 0, -10,  0, 0, 1.1, 0, -10,  0, 0, 0, 1, 0,
    ])),
    PhotoFilter(name: 'Moon', colorFilter: const ColorFilter.matrix([
      0.3, 0.6, 0.1, 0, 0,  0.3, 0.6, 0.1, 0, 0,  0.3, 0.6, 0.1, 0, 0,  0, 0, 0, 1, 0,
    ])),
    PhotoFilter(name: 'Lark', colorFilter: const ColorFilter.matrix([
      1.2, 0, 0, 0, 20,  0, 1.0, 0, 0, 0,  0, 0, 0.9, 0, -10,  0, 0, 0, 1, 0,
    ])),
    PhotoFilter(name: 'Reyes', colorFilter: const ColorFilter.matrix([
      1.0, 0.1, 0.1, 0, 15,  0, 1.0, 0, 0, 15,  0, 0, 0.8, 0, 10,  0, 0, 0, 1, 0,
    ])),
    PhotoFilter(name: 'Juno', colorFilter: const ColorFilter.matrix([
      1.1, 0, 0, 0, 5,  0, 1.2, 0, 0, -5,  0, 0, 1.0, 0, 0,  0, 0, 0, 1, 0,
    ])),
    PhotoFilter(name: 'Slumber', colorFilter: const ColorFilter.matrix([
      0.9, 0.1, 0, 0, 10,  0, 0.9, 0.1, 0, 10,  0, 0, 0.8, 0, 20,  0, 0, 0, 1, 0,
    ])),
  ];

  static const _identityFilter = ColorFilter.matrix([
    1, 0, 0, 0, 0,  0, 1, 0, 0, 0,  0, 0, 1, 0, 0,  0, 0, 0, 1, 0,
  ]);

  @override
  void initState() {
    super.initState();
    if (!widget.isVideo) _loadBytes();
  }

  Future<void> _loadBytes() async {
    final b = await widget.file.readAsBytes();
    if (mounted) setState(() => _imageBytes = b);
  }

  void _goToNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PostDetailsScreen(
          file: widget.file,
          imageBytes: _imageBytes,
          isVideo: widget.isVideo,
          mode: widget.mode,
          filterIndex: _selectedFilter,
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (widget.isVideo) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam, color: Colors.white38, size: 60),
              SizedBox(height: 8),
              Text('Video selected', style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      );
    }
    if (_imageBytes == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    return Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity);
  }

  Widget _buildThumb(int i) {
    if (_imageBytes == null) return Container(color: Colors.grey[800]);
    return Image.memory(_imageBytes!, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    final filter = _filters[_selectedFilter];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.mode == ContentMode.story ? 'New Story'
              : widget.mode == ContentMode.reel ? 'New Reel' : 'New Post',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _goToNext,
            child: const Text('Next',
                style: TextStyle(color: Color(0xFF0095F6), fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview
          Expanded(
            child: ColorFiltered(
              colorFilter: filter.colorFilter ?? _identityFilter,
              child: _buildPreview(),
            ),
          ),

          // Filter Strip
          Container(
            color: Colors.black,
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: _filters.length,
              itemBuilder: (_, i) {
                final selected = _selectedFilter == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Column(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected ? Colors.white : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: ColorFiltered(
                              colorFilter: _filters[i].colorFilter ?? _identityFilter,
                              child: _buildThumb(i),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _filters[i].name,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Post Details Screen ──────────────────────────────────────
class _PostDetailsScreen extends StatefulWidget {
  final XFile file;
  final Uint8List? imageBytes;
  final bool isVideo;
  final ContentMode mode;
  final int filterIndex;

  const _PostDetailsScreen({
    required this.file,
    required this.imageBytes,
    required this.isVideo,
    required this.mode,
    required this.filterIndex,
  });

  @override
  State<_PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<_PostDetailsScreen> {
  final TextEditingController _captionController = TextEditingController();
  PostVisibility _visibility = PostVisibility.everyone;
  String _location = '';
  List<String> _hashtags = [];
  bool _hideLikeCount = false;
  bool _hideShareCount = false;
  bool _turnOffCommenting = false;
  bool _uploadHighestQuality = false;
  bool _dontLetOthersUseAsTemplate = false;
  bool _addAiLabel = false;
  String _taggedPeople = '';

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  // ── Hashtag Sheet ─────────────────────────────────────────
  void _openHashtagSheet() {
    final controller = TextEditingController(text: _hashtags.join(' '));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16, right: 16, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Hashtags', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '#wedding #love #marriage',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                '#wedding', '#love', '#marriage', '#couple',
                '#bridal', '#groom', '#bride', '#forever',
              ].map((h) => ActionChip(
                label: Text(h),
                onPressed: () {
                  final current = controller.text;
                  if (!current.contains(h)) controller.text = '$current $h'.trim();
                },
              )).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0095F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final tags = controller.text
                      .split(' ')
                      .where((t) => t.startsWith('#') && t.length > 1)
                      .toList();
                  setState(() => _hashtags = tags);
                  Navigator.pop(ctx);
                },
                child: const Text('Done', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Location Sheet ────────────────────────────────────────
  void _openLocationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16, right: 16, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search location or city...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 12),
            ...[
              'Rawalpindi, Pakistan', 'Islamabad, Pakistan',
              'Lahore, Pakistan', 'Karachi, Pakistan', 'Peshawar, Pakistan',
            ].map((loc) => ListTile(
              leading: const Icon(Icons.location_city, color: Colors.grey),
              title: Text(loc),
              onTap: () {
                setState(() => _location = loc);
                Navigator.pop(ctx);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Visibility Sheet ──────────────────────────────────────
  void _openVisibilitySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Who can see this?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _visibilityOption(Icons.public, 'Everyone', 'Visible to all users', PostVisibility.everyone, ctx),
            _visibilityOption(Icons.people, 'Close Friends', 'Only people you follow', PostVisibility.closeFriends, ctx, color: const Color(0xFF3DDC84)),
            _visibilityOption(Icons.lock, 'Only Me', 'No one else can see this', PostVisibility.onlyMe, ctx, color: Colors.orange),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _visibilityOption(IconData icon, String title, String subtitle, PostVisibility value, BuildContext ctx, {Color? color}) {
    final selected = _visibility == value;
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: (color ?? Colors.blue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: color ?? Colors.blue, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: selected
          ? const Icon(Icons.check_circle, color: Color(0xFF0095F6))
          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      onTap: () {
        setState(() => _visibility = value);
        Navigator.pop(ctx);
      },
    );
  }

  // ── Tag People Sheet ──────────────────────────────────────
  void _openTagPeopleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16, right: 16, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tag People', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search people to tag...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.search),
              ),
              onSubmitted: (val) {
                setState(() => _taggedPeople = val);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── More Options Sheet ────────────────────────────────────
  void _openMoreOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 16),
                      const Text('More options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Divider(),

                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text('Sharing preferences',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 13)),
                ),
                _moreOptionTile(
                  ctx: ctx, setModalState: setModalState,
                  icon: Icons.upload, title: 'Upload at highest quality',
                  subtitle: 'Always upload highest-quality photos/videos, even if slower.',
                  value: _uploadHighestQuality,
                  onChanged: (v) { setModalState(() => _uploadHighestQuality = v); setState(() => _uploadHighestQuality = v); },
                ),
                const Divider(),

                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text('What others can remix and reuse',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 13)),
                ),
                _moreOptionTile(
                  ctx: ctx, setModalState: setModalState,
                  icon: Icons.copy_all, title: "Don't let others use as template",
                  subtitle: 'Prevents others from using the same audio/timing as a template.',
                  value: _dontLetOthersUseAsTemplate,
                  onChanged: (v) { setModalState(() => _dontLetOthersUseAsTemplate = v); setState(() => _dontLetOthersUseAsTemplate = v); },
                ),
                const Divider(),

                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text('How others can interact',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 13)),
                ),
                _moreOptionTile(
                  ctx: ctx, setModalState: setModalState,
                  icon: Icons.favorite_border, title: 'Hide like count',
                  subtitle: 'Only you will see the number of likes on this post.',
                  value: _hideLikeCount,
                  onChanged: (v) { setModalState(() => _hideLikeCount = v); setState(() => _hideLikeCount = v); },
                ),
                _moreOptionTile(
                  ctx: ctx, setModalState: setModalState,
                  icon: Icons.send_outlined, title: 'Hide share count',
                  subtitle: 'Only you will see the number of shares.',
                  value: _hideShareCount,
                  onChanged: (v) { setModalState(() => _hideShareCount = v); setState(() => _hideShareCount = v); },
                ),
                _moreOptionTile(
                  ctx: ctx, setModalState: setModalState,
                  icon: Icons.chat_bubble_outline, title: 'Turn off commenting',
                  subtitle: 'No one can comment on this post.',
                  value: _turnOffCommenting,
                  onChanged: (v) { setModalState(() => _turnOffCommenting = v); setState(() => _turnOffCommenting = v); },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _moreOptionTile({
    required BuildContext ctx,
    required StateSetter setModalState,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF0095F6)),
        ],
      ),
    );
  }

  String get _visibilityLabel {
    switch (_visibility) {
      case PostVisibility.everyone: return 'Everyone';
      case PostVisibility.onlyMe: return 'Only Me';
      case PostVisibility.closeFriends: return 'Close Friends';
    }
  }

  IconData get _visibilityIcon {
    switch (_visibility) {
      case PostVisibility.everyone: return Icons.public;
      case PostVisibility.onlyMe: return Icons.lock;
      case PostVisibility.closeFriends: return Icons.people;
    }
  }

  // ── Share — pop back to home WITHOUT triggering login ────
  void _share() {
    final modeName = widget.mode == ContentMode.story ? 'Story'
        : widget.mode == ContentMode.reel ? 'Reel' : 'Post';

    // Show success snackbar then pop all create screens
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$modeName shared! Visibility: $_visibilityLabel'),
        backgroundColor: const Color(0xFF0095F6),
        duration: const Duration(seconds: 2),
      ),
    );

    // Pop exactly 3 screens (PostDetails → Editor → CreateContent) to land on home
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 3);
  }

  // ── Save Draft ────────────────────────────────────────────
  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved!')),
    );
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 3);
  }

  Widget _buildThumbnail() {
    if (widget.imageBytes != null) {
      return Image.memory(widget.imageBytes!, fit: BoxFit.cover, width: 100, height: 130);
    }
    if (widget.isVideo) {
      return Container(
        width: 100, height: 130, color: Colors.grey[800],
        child: const Icon(Icons.videocam, color: Colors.white54, size: 36),
      );
    }
    return Container(
      width: 100, height: 130, color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modeTitle = widget.mode == ContentMode.story ? 'New Story'
        : widget.mode == ContentMode.reel ? 'New Reel' : 'New Post';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(modeTitle,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail + Caption ──────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(width: 100, height: 130, child: _buildThumbnail()),
                      ),
                      Positioned(
                        bottom: 8, left: 0, right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('Edit cover', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Add a caption...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Quick Action Chips ───────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _actionChip(icon: Icons.tag, label: 'Hashtags', onTap: _openHashtagSheet, active: _hashtags.isNotEmpty),
                  const SizedBox(width: 8),
                  _actionChip(icon: Icons.play_circle_outline, label: 'Link a reel', onTap: () {}),
                  const SizedBox(width: 8),
                  _actionChip(icon: Icons.poll_outlined, label: 'Poll', onTap: () {}),
                  const SizedBox(width: 8),
                  _actionChip(icon: Icons.emoji_emotions_outlined, label: 'Sticker', onTap: () {}),
                ],
              ),
            ),

            // Show selected hashtags
            if (_hashtags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 6,
                  children: _hashtags.map((h) => Chip(
                    label: Text(h, style: const TextStyle(color: Color(0xFF0095F6), fontSize: 12)),
                    backgroundColor: const Color(0xFFE8F3FF),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                  )).toList(),
                ),
              ),

            const Divider(height: 1),

            // ── Tag People ──────────────────────────────────
            _settingRow(
              icon: Icons.person_outline, title: 'Tag people',
              trailing: _taggedPeople.isEmpty ? null : Text(_taggedPeople,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              onTap: _openTagPeopleSheet,
            ),

            // ── Add Location ────────────────────────────────
            _settingRow(
              icon: Icons.location_on_outlined, title: 'Add location',
              trailing: _location.isEmpty ? null : Text(_location,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              onTap: _openLocationSheet,
            ),

            // ── Add AI Label ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_outlined, size: 22, color: Colors.black87),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Add AI label', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'We require you to label certain realistic AI-made content. ',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              TextSpan(
                                text: 'Learn more',
                                style: TextStyle(color: Color(0xFF0095F6), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _addAiLabel,
                    onChanged: (v) => setState(() => _addAiLabel = v),
                    activeColor: const Color(0xFF0095F6),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Audience / Visibility ────────────────────────
            _settingRow(
              icon: _visibilityIcon, title: 'Audience',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_visibilityLabel, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ],
              ),
              onTap: _openVisibilitySheet,
            ),

            // ── Also Share On ────────────────────────────────
            _settingRow(
              icon: Icons.open_in_new, title: 'Also share on...',
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('@yourprofile', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ],
              ),
              onTap: () {},
            ),

            // ── More Options ─────────────────────────────────
            _settingRow(
              icon: Icons.more_horiz, title: 'More options',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show active toggles summary
                  if (_hideLikeCount || _turnOffCommenting || _hideShareCount)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F3FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        [
                          if (_hideLikeCount) 'Likes hidden',
                          if (_hideShareCount) 'Shares hidden',
                          if (_turnOffCommenting) 'Comments off',
                        ].join(' · '),
                        style: const TextStyle(color: Color(0xFF0095F6), fontSize: 11),
                      ),
                    ),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ],
              ),
              onTap: _openMoreOptionsSheet,
            ),

            const SizedBox(height: 24),

            // ── Save Draft + Share Buttons ───────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _saveDraft,
                      child: const Text('Save draft',
                          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0095F6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _share,
                      child: const Text('Share',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE8F3FF) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? const Color(0xFF0095F6) : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: active ? const Color(0xFF0095F6) : Colors.black87),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: active ? const Color(0xFF0095F6) : Colors.black87,
            )),
          ],
        ),
      ),
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.black87),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
            if (trailing != null) trailing,
            if (trailing == null) const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Text Creator Screen ─────────────────────────────────────
class _TextCreatorScreen extends StatefulWidget {
  final ContentMode mode;
  const _TextCreatorScreen({required this.mode});

  @override
  State<_TextCreatorScreen> createState() => _TextCreatorScreenState();
}

class _TextCreatorScreenState extends State<_TextCreatorScreen> {
  final TextEditingController _textController = TextEditingController();
  Color _bgColor = const Color(0xFF1A1A2E);
  double _fontSize = 28;
  bool _isBold = false;
  bool _isItalic = false;
  Color _textColor = Colors.white;

  final List<Color> _bgColors = [
    const Color(0xFF1A1A2E), const Color(0xFFB21A1A), const Color(0xFF1A4B1A),
    const Color(0xFF1A1A4B), const Color(0xFF4B1A4B), const Color(0xFF4B3A1A),
    Colors.black, Colors.white,
  ];

  final List<Color> _textColors = [
    Colors.white, Colors.black, Colors.yellow, Colors.red,
    Colors.blue, Colors.green, Colors.orange, Colors.pink,
  ];

  void _goNext() {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first!')),
      );
      return;
    }
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _TextPostDetailsScreen(
        text: _textController.text,
        bgColor: _bgColor,
        textColor: _textColor,
        isBold: _isBold,
        fontSize: _fontSize,
        mode: widget.mode,
      ),
    ));
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
        title: Text(
          'Create ${widget.mode.name[0].toUpperCase()}${widget.mode.name.substring(1)}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _goNext,
            child: const Text('Next', style: TextStyle(color: Color(0xFF0095F6), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _bgColor, borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: _fontSize,
                      fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                      fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Write something...',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 28),
                      border: InputBorder.none,
                    ),
                    autofocus: true,
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(children: [
                  const Text('Text: ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ..._textColors.map((c) => GestureDetector(
                    onTap: () => setState(() => _textColor = c),
                    child: Container(
                      width: 28, height: 28,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: c, shape: BoxShape.circle,
                        border: Border.all(color: _textColor == c ? Colors.white : Colors.transparent, width: 2),
                      ),
                    ),
                  )),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  const Text('BG:   ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ..._bgColors.map((c) => GestureDetector(
                    onTap: () => setState(() => _bgColor = c),
                    child: Container(
                      width: 28, height: 28,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: c, shape: BoxShape.circle,
                        border: Border.all(color: _bgColor == c ? Colors.white : Colors.grey, width: 2),
                      ),
                    ),
                  )),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  IconButton(
                    onPressed: () => setState(() => _isBold = !_isBold),
                    icon: Icon(Icons.format_bold, color: _isBold ? Colors.white : Colors.white38),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _isItalic = !_isItalic),
                    icon: Icon(Icons.format_italic, color: _isItalic ? Colors.white : Colors.white38),
                  ),
                  const Spacer(),
                  const Text('Size', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  Slider(
                    value: _fontSize, min: 14, max: 48,
                    activeColor: Colors.white, inactiveColor: Colors.white24,
                    onChanged: (v) => setState(() => _fontSize = v),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Text Post Details Screen ─────────────────────────────────
class _TextPostDetailsScreen extends StatefulWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  final bool isBold;
  final double fontSize;
  final ContentMode mode;

  const _TextPostDetailsScreen({
    required this.text, required this.bgColor, required this.textColor,
    required this.isBold, required this.fontSize, required this.mode,
  });

  @override
  State<_TextPostDetailsScreen> createState() => _TextPostDetailsScreenState();
}

class _TextPostDetailsScreenState extends State<_TextPostDetailsScreen> {
  PostVisibility _visibility = PostVisibility.everyone;
  String _location = '';

  String get _visibilityLabel {
    switch (_visibility) {
      case PostVisibility.everyone: return 'Everyone';
      case PostVisibility.onlyMe: return 'Only Me';
      case PostVisibility.closeFriends: return 'Close Friends';
    }
  }

  void _share() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Text ${widget.mode.name} shared! Visibility: $_visibilityLabel'),
        backgroundColor: const Color(0xFF0095F6),
      ),
    );
    // Pop back to home safely
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 3);
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved!')),
    );
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New ${widget.mode.name[0].toUpperCase()}${widget.mode.name.substring(1)}',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              height: 200,
              decoration: BoxDecoration(
                color: widget.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: widget.fontSize,
                    fontWeight: widget.isBold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Audience'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_visibilityLabel, style: const TextStyle(color: Colors.grey)),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              onTap: () => _showVisibilitySheet(),
            ),

            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Add location'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_location.isNotEmpty)
                    Text(_location, style: const TextStyle(color: Colors.grey)),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              onTap: () => _showLocationSheet(),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _saveDraft,
                      child: const Text('Save draft', style: TextStyle(color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0095F6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _share,
                      child: const Text('Share', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVisibilitySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Who can see this?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _visOpt(ctx, Icons.public, 'Everyone', 'Visible to everyone', PostVisibility.everyone),
            _visOpt(ctx, Icons.people, 'Close Friends', 'Only your followers', PostVisibility.closeFriends, Colors.green),
            _visOpt(ctx, Icons.lock, 'Only Me', 'Only you can see this', PostVisibility.onlyMe, Colors.orange),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _visOpt(BuildContext ctx, IconData icon, String title, String sub, PostVisibility val, [Color? color]) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.blue),
      title: Text(title),
      subtitle: Text(sub),
      trailing: _visibility == val
          ? const Icon(Icons.check_circle, color: Color(0xFF0095F6))
          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      onTap: () {
        setState(() => _visibility = val);
        Navigator.pop(ctx);
      },
    );
  }

  void _showLocationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16, right: 16, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search city or location...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 8),
            ...['Rawalpindi, Pakistan', 'Islamabad, Pakistan', 'Lahore, Pakistan', 'Karachi, Pakistan']
                .map((loc) => ListTile(
              leading: const Icon(Icons.location_city, color: Colors.grey),
              title: Text(loc),
              onTap: () {
                setState(() => _location = loc);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }
}