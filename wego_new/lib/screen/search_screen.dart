import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────
// SEARCH SCREEN — Users + Posts + Videos
// ─────────────────────────────────────────────────────────────
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late TabController _tabController;

  String _query = '';
  bool _isSearching = false;

  // Search results
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _videos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _focusNode.requestFocus();
    _searchController.addListener(() {
      final text = _searchController.text.trim();
      if (text != _query) {
        setState(() => _query = text);
        if (text.isEmpty) {
          setState(() {
            _users = [];
            _posts = [];
            _videos = [];
          });
        } else {
          _performSearch(text);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ── FIREBASE SEARCH ──────────────────────────────────────────
  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    final lower = query.toLowerCase();
    final end = lower.substring(0, lower.length - 1) +
        String.fromCharCode(lower.codeUnitAt(lower.length - 1) + 1);

    try {
      // ── Users: username prefix match + client-side includes filter
      final usersSnap = await FirebaseFirestore.instance
          .collection('user')  // 'users' → 'user'
          .where('username_lower', isGreaterThanOrEqualTo: lower)
          .where('username_lower', isLessThan: end)
          .limit(20)
          .get();

      // ── Posts: caption contains (client-side filter)
      final postsSnap = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      // ── Videos: title contains (client-side filter)
      final videosSnap = await FirebaseFirestore.instance
          .collection('videos')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      if (!mounted) return;

      setState(() {
        _users = usersSnap.docs.map((d) => {...d.data(), 'id': d.id}).toList();

        _posts = postsSnap.docs
            .where((d) {
          final caption =
          (d.data()['caption'] as String? ?? '').toLowerCase();
          return caption.contains(lower);
        })
            .map((d) => {...d.data(), 'id': d.id})
            .toList();

        _videos = videosSnap.docs
            .where((d) {
          final title =
          (d.data()['title'] as String? ?? '').toLowerCase();
          return title.contains(lower);
        })
            .map((d) => {...d.data(), 'id': d.id})
            .toList();

        _isSearching = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primary = Color(0xFF4A6CF7);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildSearchField(isDark),
        actions: [
          if (_query.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
                _focusNode.requestFocus();
              },
              child: const Text('Clear',
                  style: TextStyle(color: primary, fontSize: 14)),
            ),
        ],
        bottom: _query.isNotEmpty
            ? TabBar(
          controller: _tabController,
          indicatorColor: primary,
          labelColor: primary,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: 'Users (${_users.length})'),
            Tab(text: 'Posts (${_posts.length})'),
            Tab(text: 'Videos (${_videos.length})'),
          ],
        )
            : null,
      ),
      body: _query.isEmpty
          ? _buildEmptyState(isDark)
          : _isSearching
          ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF4A6CF7)))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildUsersList(isDark),
          _buildPostsList(isDark),
          _buildVideosList(isDark),
        ],
      ),
    );
  }

  // ── SEARCH FIELD ─────────────────────────────────────────────
  Widget _buildSearchField(bool isDark) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color:
        isDark ? Colors.white.withOpacity(0.07) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        style: TextStyle(
            color: isDark ? Colors.white : Colors.black, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search users, posts, videos...',
          hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey, fontSize: 14),
          prefixIcon: Icon(Icons.search,
              color: isDark ? Colors.white38 : Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────────
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search,
              size: 72,
              color: isDark ? Colors.white24 : Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Search for users, posts or videos',
              style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey,
                  fontSize: 15)),
        ],
      ),
    );
  }

  // ── USERS LIST ────────────────────────────────────────────────
  Widget _buildUsersList(bool isDark) {
    if (_users.isEmpty) return _buildNoResults('No users found', isDark);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _users.length,
      itemBuilder: (_, i) {
        final u = _users[i];
        return ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF4A6CF7).withOpacity(0.2),
            backgroundImage: u['photoUrl'] != null && u['photoUrl'] != ''
                ? NetworkImage(u['photoUrl'] as String)
                : null,
            child: u['photoUrl'] == null || u['photoUrl'] == ''
                ? Text(
              (u['username'] as String? ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                  color: Color(0xFF4A6CF7),
                  fontWeight: FontWeight.bold),
            )
                : null,
          ),
          title: Text(
            u['username'] as String? ?? '',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black),
          ),
          subtitle: Text(
            u['bio'] as String? ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey, fontSize: 12),
          ),
          trailing: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0095F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Follow',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
          onTap: () {
            // Navigate to user profile
            // Navigator.push(context, MaterialPageRoute(
            //   builder: (_) => UserProfileScreen(username: u['username'])));
          },
        );
      },
    );
  }

  // ── POSTS LIST ────────────────────────────────────────────────
  Widget _buildPostsList(bool isDark) {
    if (_posts.isEmpty) return _buildNoResults('No posts found', isDark);
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _posts.length,
      itemBuilder: (_, i) {
        final p = _posts[i];
        final imageUrl = p['imageUrl'] as String? ?? '';
        return GestureDetector(
          onTap: () {
            // Navigate to post detail
          },
          child: Container(
            color: isDark ? Colors.grey[850] : Colors.grey[200],
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image, color: Colors.grey))
                : Center(
              child: Text(
                p['caption'] as String? ?? '',
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── VIDEOS LIST ───────────────────────────────────────────────
  Widget _buildVideosList(bool isDark) {
    if (_videos.isEmpty) return _buildNoResults('No videos found', isDark);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _videos.length,
      itemBuilder: (_, i) {
        final v = _videos[i];
        return ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: v['thumbnailUrl'] != null && v['thumbnailUrl'] != ''
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(v['thumbnailUrl'] as String,
                  fit: BoxFit.cover),
            )
                : const Icon(Icons.videocam, color: Color(0xFF4A6CF7)),
          ),
          title: Text(
            v['title'] as String? ?? 'Untitled Video',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black),
          ),
          subtitle: Text(
            v['uploaderName'] as String? ?? '',
            style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey, fontSize: 12),
          ),
          trailing: const Icon(Icons.play_circle_outline,
              color: Color(0xFF4A6CF7), size: 32),
          onTap: () {
            // Navigate to video player
          },
        );
      },
    );
  }

  Widget _buildNoResults(String message, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off,
              size: 60,
              color: isDark ? Colors.white24 : Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey,
                  fontSize: 15)),
        ],
      ),
    );
  }
}