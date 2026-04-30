import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wego_marriage/providers/story_provider.dart';
import 'package:wego_marriage/providers/chat_provider.dart';
import 'package:wego_marriage/screen/story_screen.dart';
import 'package:wego_marriage/screen/my_profile.dart';
import 'package:wego_marriage/screen/massage_list_screen.dart';
import 'package:wego_marriage/screen/comments_screen.dart';
import 'package:wego_marriage/screen/user_profile_screen.dart';
import 'package:wego_marriage/screen/chat_screen.dart';
import 'package:wego_marriage/services/local_storage_service.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const _HomeTab(),
    const Center(child: Text('Favorite Screen Placeholder')),
    const SizedBox.shrink(), // Space for FAB
    const MessageListScreen(),
    const MyProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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

  Widget _buildBottomNav(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF4A6CF7);

    final List<Map<String, dynamic>> items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.bookmark_border, 'label': 'Match'},
      {'icon': null, 'label': ''},
      {'icon': Icons.chat_bubble_outline, 'label': 'Chats'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          if (i == 2) return const SizedBox(width: 60);
          final bool selected = _selectedIndex == i;
          final color = selected
              ? primaryColor
              : (isDark ? Colors.white54 : Colors.black38);

          return GestureDetector(
            onTap: () {
              if (i == 3) {
                // Refresh chats when clicking the chat tab
                context.read<ChatProvider>().loadChats();
              }
              setState(() => _selectedIndex = i);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  items[i]['icon'] as IconData,
                  color: color,
                  size: 24,
                ),
                const SizedBox(height: 3),
                Text(
                  items[i]['label'] as String,
                  style: TextStyle(
                    color: color,
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

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final ScrollController _scrollController = ScrollController();
  final List<Post> _posts = [];
  bool _isLoading = false;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _loadMorePosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final newPosts = _generatePosts(_page);

    setState(() {
      _posts.addAll(newPosts);
      _page++;
      _isLoading = false;
    });
  }

  List<Post> _generatePosts(int page) {
    final List<Post> posts = [];
    final startIndex = page * 5;

    for (int i = 0; i < 5; i++) {
      final index = startIndex + i;
      posts.add(
        Post(
          id: 'post_$index',
          avatarUrl: 'https://i.pravatar.cc/150?img=${(index % 70) + 1}',
          username: _getRandomUsername(index),
          time: '${index + 1} ${index == 0 ? 'day' : 'days'} ago',
          postImageUrl: 'https://picsum.photos/seed/post$index/800/700',
          likes: '${(4.2 - (index * 0.1)).toStringAsFixed(1)}k',
          comments: '${900 - (index * 10)}',
          isVideo: index % 4 == 0, // Every 4th post is a video
          caption: 'Living my best life! ${['#travel', '#lifestyle', '#fashion', '#photography', '#wedding', '#marriage'][index % 6]} ${['#love', '#happiness', '#blessed', '#instagood', '#beautiful', '#summer'][index % 6]}',
          hashtags: ['#love', '#instagood', '#photooftheday'],
          isLarge: index % 3 != 1,
        ),
      );
    }
    return posts;
  }

  String _getRandomUsername(int index) {
    final names = [
      'Alex Johnson',
      'Sarah Smith',
      'Mike Brown',
      'Emma Wilson',
      'James Davis',
      'Lisa Anderson',
      'Chris Taylor',
      'Anna Martinez',
      'David Lee',
      'Sophie Chen',
      'Ryan Garcia',
      'Maria Lopez',
      'Tom White',
      'Kate Miller',
      'Jack Wilson',
      'Nina Patel',
      'Leo Kim',
      'Olivia Jones',
      'Daniel Moore',
      'Emily Clark',
    ];
    return names[index % names.length];
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final userStories = storyProvider.userStories;
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          Container(
            color: theme.scaffoldBackgroundColor,
            child: Column(
              children: [
                _buildStoryRow(userStories),
                const SizedBox(height: 10),
                _buildSearchBar(context),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              itemCount: _posts.length + 1,
              itemBuilder: (context, index) {
                if (index == _posts.length) {
                  return _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF4A6CF7),
                            ),
                          ),
                        )
                      : const SizedBox(height: 80);
                }

                final post = _posts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _InstagramStylePostCard(post: post),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryRow(List<UserStory> userStories) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SizedBox(
        height: 68,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: userStories.length + 1,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, i) {
            if (i == 0) return const _AddStoryButton();
            final userStory = userStories[i - 1];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StoryScreen(initialUserIndex: i - 1),
                  ),
                );
              },
              child: _StoryFaceCircle(
                imageUrl: userStory.avatarUrl,
                isWatched: userStory.isWatched,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search, color: isDark ? Colors.white54 : const Color(0xFFAAAAAA), size: 22),
            const SizedBox(width: 8),
            Text(
              'Search',
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFFAAAAAA),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddStoryButton extends StatelessWidget {
  const _AddStoryButton();

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {},
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
  final bool isWatched;
  const _StoryFaceCircle({required this.imageUrl, this.isWatched = false});

  @override
  Widget build(BuildContext context) => Container(
    width: 62,
    height: 62,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: isWatched ? Colors.grey.shade400 : const Color(0xFFFF7B51),
        width: 2.5,
      ),
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
        errorBuilder: (_, _, _) => Container(
          color: const Color(0xFF9B6EDB),
          child: const Icon(Icons.person, color: Colors.white, size: 32),
        ),
      ),
    ),
  );
}

// Instagram Style Post Card with Video Support
class _InstagramStylePostCard extends StatefulWidget {
  final Post post;

  const _InstagramStylePostCard({required this.post});

  @override
  State<_InstagramStylePostCard> createState() => _InstagramStylePostCardState();
}

class _InstagramStylePostCardState extends State<_InstagramStylePostCard> {
  bool _isLiked = false;
  bool _isFollowing = false;
  bool _isSaved = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  final LocalStorageService _storage = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadPersistedState();
    if (widget.post.isVideo) {
      _initializeVideo();
    }
  }

  void _loadPersistedState() {
    // Load like status from local storage
    _isLiked = _storage.isPostLiked(widget.post.id);
    // Load saved status from local storage
    _isSaved = _storage.isPostSaved(widget.post.id);
    // Load follow status from local storage (using username as userId)
    _isFollowing = _storage.isUserFollowed(widget.post.username);
    setState(() {});
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _initializeVideo() {
    // For demo purposes, using a sample video URL
    // In production, this would be the actual video URL from the post
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
    )..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          _videoController?.setLooping(true);
          _videoController?.play();
        }
      });
  }

  void _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
    });
    // Save to local storage
    await _storage.toggleLike(widget.post.id, _isLiked);
  }

  void _toggleSave() async {
    setState(() {
      _isSaved = !_isSaved;
    });
    // Save to local storage
    await _storage.toggleSaved(widget.post.id, _isSaved);
  }

  void _toggleFollow() async {
    setState(() {
      _isFollowing = !_isFollowing;
    });
    // Save to local storage
    await _storage.toggleFollow(widget.post.username, _isFollowing);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFollowing ? 'Following ${widget.post.username}' : 'Unfollowed ${widget.post.username}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          username: widget.post.username,
          avatarUrl: widget.post.avatarUrl,
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildOptionTile(
              icon: Icons.save_alt,
              label: 'Save',
              onTap: () {
                Navigator.pop(context);
                _toggleSave();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_isSaved ? 'Saved to collection' : 'Removed from saved')),
                );
              },
            ),
            _buildOptionTile(
              icon: Icons.copy,
              label: 'Copy Link',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
              },
            ),
            _buildOptionTile(
              icon: Icons.share,
              label: 'Share to...',
              onTap: () {
                Navigator.pop(context);
                Share.share('Check out this amazing post!');
              },
            ),
            _buildOptionTile(
              icon: Icons.notifications_off,
              label: "Turn off notifications for ${widget.post.username}",
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notifications turned off for ${widget.post.username}')),
                );
              },
            ),
            _buildOptionTile(
              icon: Icons.hide_image,
              label: 'Hide',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post hidden')),
                );
              },
            ),
            _buildOptionTile(
              icon: Icons.flag,
              label: 'Report',
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context);
              },
            ),
            _buildOptionTile(
              icon: Icons.cancel,
              label: 'Cancel',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        title: const Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildReportOption('Nudity or sexual activity'),
            _buildReportOption('Harassment or bullying'),
            _buildReportOption('Hate speech or symbols'),
            _buildReportOption('False information'),
            _buildReportOption('Spam'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOption(String reason) {
    return ListTile(
      title: Text(reason),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reported for: $reason')),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: iconColor ?? (isDark ? Colors.white : Colors.black87)),
      title: Text(
        label,
        style: TextStyle(color: textColor ?? (isDark ? Colors.white : Colors.black87)),
      ),
      onTap: onTap,
    );
  }

  List<TextSpan> _buildCaptionWithHashtags(String caption) {
    final List<TextSpan> spans = [];
    final words = caption.split(' ');

    for (String word in words) {
      if (word.startsWith('#')) {
        spans.add(TextSpan(
          text: '$word ',
          style: const TextStyle(
            color: Color(0xFF003569),
            fontSize: 14,
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: '$word ',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ));
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF121212) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Avatar, Username, Follow Button, and More Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Avatar
                GestureDetector(
                  onTap: _navigateToProfile,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFDD2A7B),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        widget.post.avatarUrl,
                        fit: BoxFit.cover,
                        headers: const {
                          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
                        },
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Username and Follow Button
                Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _navigateToProfile,
                        child: Text(
                          widget.post.username,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Follow Button
                      if (!_isFollowing)
                        GestureDetector(
                          onTap: _toggleFollow,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0095F6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Follow',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: _toggleFollow,
                          child: Row(
                            children: [
                              const Icon(Icons.check, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Following',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // 3 Dots Menu
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () => _showMoreOptions(context),
                ),
              ],
            ),
          ),

          // Post Image/Video
          GestureDetector(
            onDoubleTap: _toggleLike,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 400),
              child: widget.post.isVideo && _isVideoInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : Image.network(
                      widget.post.postImageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 400,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 400,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
            ),
          ),

          // Action Buttons Row (Like, Comment, Share, Save)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Like Button
                GestureDetector(
                  onTap: _toggleLike,
                  child: AnimatedScale(
                    scale: _isLiked ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : (isDark ? Colors.white : Colors.black),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Comment Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommentsScreen(
                          postId: widget.post.id,
                          postUsername: widget.post.username,
                          currentUserAvatar: 'https://i.pravatar.cc/150?img=10',
                          currentUsername: 'You',
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: isDark ? Colors.white : Colors.black,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),

                // Share Button
                GestureDetector(
                  onTap: () {
                    Share.share('Check out this amazing post by ${widget.post.username}!');
                  },
                  child: Icon(
                    Icons.send,
                    color: isDark ? Colors.white : Colors.black,
                    size: 26,
                  ),
                ),

                const Spacer(),

                // Save Button
                GestureDetector(
                  onTap: _toggleSave,
                  child: Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isDark ? Colors.white : Colors.black,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          // Likes Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${widget.post.likes} likes',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Caption with Hashtags
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${widget.post.username} ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  ..._buildCaptionWithHashtags(widget.post.caption),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          // View Comments
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                // Navigate to comments
              },
              child: Text(
                'View all ${widget.post.comments} comments',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Time
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.post.time.toUpperCase(),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class Post {
  final String id;
  final String avatarUrl;
  final String username;
  final String time;
  final String postImageUrl;
  final String likes;
  final String comments;
  final bool isVideo;
  final String caption;
  final List<String> hashtags;
  final bool isLarge;

  Post({
    required this.id,
    required this.avatarUrl,
    required this.username,
    required this.time,
    required this.postImageUrl,
    required this.likes,
    required this.comments,
    this.isVideo = false,
    this.caption = '',
    this.hashtags = const [],
    required this.isLarge,
  });
}
