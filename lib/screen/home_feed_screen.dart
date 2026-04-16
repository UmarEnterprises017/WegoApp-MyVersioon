import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'story_screen.dart';
import 'my_profile.dart';
import '../providers/user_provider.dart';

// ═══════════════════════════════════════════════════════════
//  IMAGE URLS
//  - Story avatars: randomuser.me gives REAL human face photos
//  - Post images:   picsum.photos (reliable in Flutter)
// ═══════════════════════════════════════════════════════════

// Story: 5 real human face photos (no solid color circles)
final List<dynamic> kStoryItems = [
  'https://randomuser.me/api/portraits/women/44.jpg',
  'https://randomuser.me/api/portraits/men/32.jpg',
  'https://randomuser.me/api/portraits/women/68.jpg',
  'https://randomuser.me/api/portraits/men/45.jpg',
  'https://randomuser.me/api/portraits/women/55.jpg',
];

// Post images
const String kPost1Url = 'https://picsum.photos/seed/portrait1/800/700';
const String kPost2Url = 'https://picsum.photos/seed/portrait2/800/700';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFF5B2BE8),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildStoryRow(),
                  const SizedBox(height: 10),
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _LargePostCard(
                    avatarUrl: user.avatarUrl,
                    username: user.name,
                    time: '01 day ago',
                    postImageUrl: kPost1Url,
                    likes: '4.2k',
                    comments: '908',
                  ),
                  const SizedBox(height: 8),
                  _CompactCard(
                    avatarUrl: user.avatarUrl,
                    username: user.name,
                    time: '01 day ago',
                  ),
                  const SizedBox(height: 8),
                  _LargePostCard(
                    avatarUrl: user.avatarUrl,
                    username: user.name,
                    time: '01 day ago',
                    postImageUrl: kPost2Url,
                    likes: '2.1k',
                    comments: '543',
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildStoryRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SizedBox(
        height: 68,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: kStoryItems.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            if (i == 0) return const _AddStoryButton();
            final item = kStoryItems[i - 1];
            if (item is String) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoryScreen(initialUserIndex: i - 1),
                    ),
                  );
                },
                child: _StoryFaceCircle(imageUrl: item),
              );
            } else {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoryScreen(initialUserIndex: i - 1),
                    ),
                  );
                },
                child: _SolidStoryCircle(color: item as Color),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
        ),
        child: const Row(
          children: [
            SizedBox(width: 16),
            Icon(Icons.search, color: Color(0xFFAAAAAA), size: 22),
            SizedBox(width: 8),
            Text(
              'Search',
              style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFF3DDC84),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x553DDC84),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    );
  }

  Widget _buildBottomNav() {
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.bookmark_border, 'label': 'favorite'},
      {'icon': null, 'label': ''},
      {'icon': Icons.chat_bubble_outline, 'label': 'Chats'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];

    return Container(
      height: 72,
      color: const Color(0xFF4A22CC),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          if (i == 2) return const SizedBox(width: 60);
          final bool selected = _selectedIndex == i;
          return GestureDetector(
            onTap: () {
              if (i == 4) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyProfileScreen(),
                  ),
                );
              } else {
                setState(() => _selectedIndex = i);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  items[i]['icon'] as IconData,
                  color: selected ? Colors.white : Colors.white54,
                  size: 24,
                ),
                const SizedBox(height: 3),
                Text(
                  items[i]['label'] as String,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white54,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _AddStoryButton extends StatelessWidget {
  const _AddStoryButton();

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const StoryScreen(initialUserIndex: 0),
        ),
      );
    },
    child: Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFB21A1A), width: 1.8),
      ),
      child: const Icon(Icons.add, color: Color(0xFFB21A1A), size: 28),
    ),
  );
}

class _StoryFaceCircle extends StatelessWidget {
  final String imageUrl;
  const _StoryFaceCircle({required this.imageUrl});

  @override
  Widget build(BuildContext context) => Container(
    width: 62,
    height: 62,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFFFF7B51), width: 2.5),
    ),
    child: ClipOval(
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        headers: const {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        },
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            color: const Color(0xFF7B4EDB),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white38,
                ),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFF9B6EDB),
          child: const Icon(Icons.person, color: Colors.white, size: 32),
        ),
      ),
    ),
  );
}

class _SolidStoryCircle extends StatelessWidget {
  final Color color;
  const _SolidStoryCircle({required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 62,
    height: 62,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      border: Border.all(color: Colors.white30, width: 2),
    ),
  );
}

class _Avatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  const _Avatar({required this.imageUrl, this.size = 46});

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: ClipOval(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            headers: const {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
            },
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                color: const Color(0xFF7B4EDB),
                child: const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white38,
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF7B4EDB),
              child: Icon(Icons.person, color: Colors.white, size: size * 0.55),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 1,
        right: 1,
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFF3DDC84),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
    ],
  );
}

class _LargePostCard extends StatelessWidget {
  final String avatarUrl;
  final String username;
  final String time;
  final String postImageUrl;
  final String likes;
  final String comments;

  const _LargePostCard({
    required this.avatarUrl,
    required this.username,
    required this.time,
    required this.postImageUrl,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            postImageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                color: const Color(0xFF3A7A7A),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white54),
                ),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF3A7A7A),
              child: const Center(
                child: Icon(Icons.image_not_supported, color: Colors.white38, size: 48),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _Avatar(imageUrl: avatarUrl),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        shadows: [
                          Shadow(blurRadius: 8, color: Colors.black87, offset: Offset(0, 1))
                        ],
                      ),
                    ),
                    Text(time, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.bookmark_border, color: Colors.white, size: 22),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 78,
            child: Column(
              children: [
                const Icon(Icons.send, color: Colors.white, size: 22),
                const SizedBox(height: 14),
                const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 22),
                const SizedBox(height: 4),
                Text(
                  comments,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 14,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE03070),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 22),
                  const SizedBox(height: 2),
                  Text(
                    likes,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            left: 12,
            child: Row(
              children: List.generate(
                4,
                (i) => Container(
                  margin: const EdgeInsets.only(right: 5),
                  width: i == 0 ? 20 : 7,
                  height: 4,
                  decoration: BoxDecoration(
                    color: i == 0 ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactCard extends StatelessWidget {
  final String avatarUrl;
  final String username;
  final String time;

  const _CompactCard({
    required this.avatarUrl,
    required this.username,
    required this.time,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 74,
    color: const Color(0xFF5B2BE8),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Row(
      children: [
        _Avatar(imageUrl: avatarUrl),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
            ),
            Text(time, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white38),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.bookmark_border, color: Colors.white, size: 18),
        ),
      ],
    ),
  );
}
