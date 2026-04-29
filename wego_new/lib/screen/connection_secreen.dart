import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wego_marriage/screen/chat_screen.dart';
import 'package:wego_marriage/screen/video_call_screen.dart';
import 'package:wego_marriage/screen/voice_call_screen.dart';

// ─── Data Model ──────────────────────────────────────────────────────────────
class MatchUser {
  final String uid;        // ← NEW: real Firebase UID
  final String name;
  final int age;
  final String imageUrl;
  final bool hasLiked;
  final bool isFollowing;
  final bool isPermanentlyFollowed;

  const MatchUser({
    required this.uid,
    required this.name,
    required this.age,
    required this.imageUrl,
    this.hasLiked = false,
    this.isFollowing = false,
    this.isPermanentlyFollowed = false,
  });

  MatchUser copyWith({
    String? uid,
    String? name,
    int? age,
    String? imageUrl,
    bool? hasLiked,
    bool? isFollowing,
    bool? isPermanentlyFollowed,
  }) {
    return MatchUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      age: age ?? this.age,
      imageUrl: imageUrl ?? this.imageUrl,
      hasLiked: hasLiked ?? this.hasLiked,
      isFollowing: isFollowing ?? this.isFollowing,
      isPermanentlyFollowed: isPermanentlyFollowed ?? this.isPermanentlyFollowed,
    );
  }
}

// ─── Sample Data ─────────────────────────────────────────────────────────────
final List<MatchUser> initialMatches = [
  MatchUser(uid: 'user_1', name: 'Leilani',   age: 19, imageUrl: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=400'),
  MatchUser(uid: 'user_2', name: 'Annabelle', age: 20, imageUrl: 'https://images.unsplash.com/photo-1488716820095-cbe80883c496?w=400'),
  MatchUser(uid: 'user_3', name: 'Reagan',    age: 24, imageUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400'),
  MatchUser(uid: 'user_4', name: 'Hadley',    age: 25, imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400'),
  MatchUser(uid: 'user_5', name: 'Kyle',      age: 24, imageUrl: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=400'),
  MatchUser(uid: 'user_6', name: 'Kyle',      age: 24, imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400', hasLiked: true),
];

// ─── Main Screen ─────────────────────────────────────────────────────────────
class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  static const Color primaryPurple = Color(0xFF6C3FEB);
  late List<MatchUser> matches;

  @override
  void initState() {
    super.initState();
    matches = List.from(initialMatches);
  }

  void _removeUser(int index) => setState(() => matches.removeAt(index));

  void _openVideoCall(MatchUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoCallScreen(
          remoteUserId: user.uid,
          remoteUserName: user.name,
          remoteUserImage: user.imageUrl,
        ),
      ),
    );
  }

  void _openProfile(MatchUser user) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => ProfileScreen(user: user)));

  void _toggleFollow(int index) {
    final user = matches[index];
    if (user.isPermanentlyFollowed) return;
    setState(() => matches[index] = user.copyWith(isFollowing: !user.isFollowing));
  }

  void _permanentFollow(int index) {
    setState(() {
      matches[index] = matches[index].copyWith(
        isFollowing: true,
        isPermanentlyFollowed: true,
      );
    });
  }

  void _onComment(int index) => _permanentFollow(index);
  void _onLike(int index)    => _permanentFollow(index);
  void _onMessage(int index) => _permanentFollow(index);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(color: primaryPurple, height: MediaQuery.of(context).padding.top),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Matches',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black)),
                      const SizedBox(height: 4),
                      Text(
                          'This is a list of people who have liked you\nand your matches.',
                          style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black54,
                              height: 1.4)),
                    ],
                  ),
                ),
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                      border: Border.all(color: primaryPurple, width: 2),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Center(
                      child: Text('1L',
                          style: TextStyle(
                              color: primaryPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 16))),
                ),
              ],
            ),
          ),
          Expanded(
            child: matches.isEmpty
                ? const Center(
                child: Text('Koi match nahi mila!',
                    style: TextStyle(fontSize: 18, color: Colors.grey)))
                : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.78),
              itemCount: matches.length,
              itemBuilder: (context, index) => _MatchCard(
                user: matches[index],
                onRemove: () => _removeUser(index),
                onVideoCall: () => _openVideoCall(matches[index]),
                onProfileTap: () => _openProfile(matches[index]),
                onFollow: () => _toggleFollow(index),
                onComment: () => _onComment(index),
                onLike: () => _onLike(index),
                onMessage: () => _onMessage(index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Match Card ──────────────────────────────────────────────────────────────
class _MatchCard extends StatelessWidget {
  final MatchUser user;
  final VoidCallback onRemove;
  final VoidCallback onVideoCall;
  final VoidCallback onProfileTap;
  final VoidCallback? onFollow;
  final VoidCallback? onComment;
  final VoidCallback? onLike;
  final VoidCallback? onMessage;

  const _MatchCard({
    required this.user,
    required this.onRemove,
    required this.onVideoCall,
    required this.onProfileTap,
    this.onFollow,
    this.onComment,
    this.onLike,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onProfileTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              user.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, progress) => progress == null
                  ? child
                  : Container(
                  color: Colors.grey[300],
                  child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2))),
              errorBuilder: (e, s, w) => Container(
                  color: Colors.grey[400],
                  child: const Icon(Icons.person, size: 60, color: Colors.white)),
            ),
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.75)
                          ]))),
            ),
            Positioned(
              left: 10, bottom: 48,
              child: Text('${user.name}, ${user.age}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black45)])),
            ),
            // ── Bottom Action Bar ──
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ❌ Cross - profile remove karo
                    GestureDetector(
                      onTap: onRemove,
                      child: Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 18)),
                    ),
                    Container(width: 1, height: 24, color: Colors.white24),
                    // ❤️ Heart - real video call
                    GestureDetector(
                      onTap: onVideoCall,
                      child: Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.favorite_border,
                              color: Colors.white, size: 18)),
                    ),
                    Container(width: 1, height: 24, color: Colors.white24),
                    // 👤 Follow
                    GestureDetector(
                      onTap: onFollow,
                      child: Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle),
                          child: Icon(
                              user.isFollowing ? Icons.person : Icons.person_add,
                              color: Colors.white,
                              size: 18)),
                    ),
                  ],
                ),
              ),
            ),
            if (user.hasLiked)
              Positioned(
                top: 10, right: 10,
                child: Container(
                    width: 36, height: 36,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
                        ]),
                    child: const Icon(Icons.favorite, color: Colors.redAccent, size: 20)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile Screen ───────────────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  final MatchUser user;
  const ProfileScreen({super.key, required this.user});
  static const Color primaryPurple = Color(0xFF6C3FEB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, color: Colors.black),
            ),
            title: Text(user.name,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            centerTitle: true,
            actions: [
              IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {})
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        width: 110, height: 110,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                colors: [Color(0xFF6C3FEB), Color(0xFFFF6B9D)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight))),
                    Container(
                        width: 104, height: 104,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white)),
                    ClipOval(
                        child: Image.network(user.imageUrl,
                            width: 98, height: 98, fit: BoxFit.cover)),
                    Positioned(
                        bottom: 4, right: 4,
                        child: Container(
                            width: 16, height: 16,
                            decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2)))),
                  ],
                ),
                const SizedBox(height: 16),
                Text(user.name,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 4),
                Text('@${user.name.toLowerCase().replaceAll(' ', '_')}',
                    style: const TextStyle(fontSize: 14, color: primaryPurple)),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                      'Looking for a soulmate who loves travel and coffee. ☕✈️ Living life to the fullest!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey[600], height: 1.5)),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                elevation: 0),
                            child: const Text('Follow',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    username: user.name,
                                    avatarUrl: user.imageUrl,
                                    lastMessage: 'Start a conversation...',
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                                foregroundColor: primaryPurple,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: primaryPurple),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            child: const Text('Message',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(count: '45', label: 'Posts'),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      _StatItem(count: '1.2k', label: 'Followers'),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      _StatItem(count: '380', label: 'Following'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Posts',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      Icon(Icons.grid_view, color: Colors.grey[600]),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    final postImages = [
                      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300',
                      'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=300',
                      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300',
                      'https://images.unsplash.com/photo-1490750967868-88df5691cc35?w=300',
                      'https://images.unsplash.com/photo-1448375240586-88df5691cc35?w=300',
                      'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=300',
                    ];
                    return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(postImages[index], fit: BoxFit.cover));
                  },
                ),
                const SizedBox(height: 24),
                // ── Video Call from Profile ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Video Call
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VideoCallScreen(
                                remoteUserId: user.uid,
                                remoteUserName: user.name,
                                remoteUserImage: user.imageUrl,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.video_call),
                          label: const Text('Video'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Voice Call
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VoiceCallScreen(
                                remoteUserId: user.uid,
                                remoteUserName: user.name,
                                remoteUserImage: user.imageUrl,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.call),
                          label: const Text('Voice'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Item ────────────────────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }
}