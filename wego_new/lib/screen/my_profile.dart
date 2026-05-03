import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wego_marriage/screen/follow_list_screen.dart';
import 'package:wego_marriage/screen/profile_edit.dart';
import 'package:wego_marriage/screen/notification_screen.dart';
import 'package:wego_marriage/screen/policy_privacy.dart';
import 'package:wego_marriage/screen/setting_screeen.dart';
import 'package:wego_marriage/screen/help_center_screen.dart';
import 'package:wego_marriage/providers/user_provider.dart';
import 'package:wego_marriage/services/post_service.dart';
import 'package:wego_marriage/services/local_storage_service.dart';
import 'package:wego_marriage/screen/create_content_screen.dart';
import 'package:wego_marriage/screen/connection_secreen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _postsKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();
  final PostService _postService = PostService();
  List<UserPost> _userPosts = [];
  bool _isLoadingPosts = true;

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPosts() async {
    setState(() => _isLoadingPosts = true);
    try {
      final posts = _postService.getUserPosts();
      setState(() {
        _userPosts = posts;
        _isLoadingPosts = false;
      });
    } catch (e) {
      debugPrint('Error loading user posts: $e');
      setState(() => _isLoadingPosts = false);
    }
  }

  Future<void> _changeProfilePicture() async {
    // Step 1: Pehle hamara custom permission dialog dikhao
    final bool allowed = await _showPermissionDialog();
    
    if (!allowed) {
      return; // User ne deny kiya
    }

    // Step 2: Ab actual system permission maango
    // Android 13+ ke liye photos permission, purane versions ke liye storage
    PermissionStatus status;
    if (Platform.isAndroid) {
      // Check if it's Android 13 or higher
      // Note: In a real app, you'd check SDK version. 
      // For now, we try photos first as it's the modern way.
      status = await Permission.photos.request();
      if (status.isDenied) {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }

    // Step 3: Check karo permission mili ya nahi
    if (!status.isGranted && !status.isLimited) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('❌ Permission denied. Please allow access from settings.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      if (status.isPermanentlyDenied) {
        if (mounted) _showSettingsDialog();
      }
      return;
    }

    // Step 4: Permission granted - ab gallery open karo
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (image != null) {
      if (mounted) {
        context.read<UserProvider>().updateAvatar(image.path);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Profile picture updated!'),
            backgroundColor: const Color(0xFF3DDC84),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<bool> _showPermissionDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF5B2BE8),
          title: const Text(
            '🔒 Gallery Permission',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Please allow access to your gallery to change profile picture.\n\n'
            'This is our security filter.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Deny
              },
              child: const Text(
                'Deny',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Allow
              },
              child: const Text(
                'Allow',
                style: TextStyle(
                  color: Color(0xFF3DDC84),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ) ?? false;
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF5B2BE8),
        title: const Text(
          'Open Settings',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Please enable photo access in app settings.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open', style: TextStyle(color: Color(0xFF3DDC84))),
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                      border: Theme.of(context).brightness == Brightness.dark 
                          ? const Border(left: BorderSide(color: Colors.white10)) 
                          : null,
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: Icon(Icons.close, 
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, 
                                size: 28),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          Text(
                            'Menu',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.person_outline,
                            title: 'Edit Profile',
                            color: Colors.blue,
                            onTap: () {
                              Navigator.pop(context);
                              _showEditProfile(context);
                            },
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            color: Colors.orange,
                            onTap: () {
                              Navigator.pop(context);
                              _showNotifications(context);
                            },
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy',
                            color: Colors.green,
                            onTap: () {
                              Navigator.pop(context);
                              _showPrivacy(context);
                            },
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.settings_outlined,
                            title: 'Settings',
                            color: Colors.purple,
                            onTap: () {
                              Navigator.pop(context);
                              _showSettings(context);
                            },
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.favorite_border,
                            title: 'Favorites',
                            color: Colors.red,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MatchesScreen(),
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.help_outline,
                            title: 'Help & Support',
                            color: Colors.teal,
                            onTap: () {
                              Navigator.pop(context);
                              _showHelpSupport(context);
                            },
                          ),
                          const Spacer(),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.logout,
                            title: 'Logout',
                            color: Colors.red,
                            onTap: () {
                              Navigator.pop(context);
                              _showLogoutDialog(context);
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? Colors.white54 : Colors.black26,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileEditScreen(),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationSettingScreen(),
      ),
    );
  }

  void _showPrivacy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyScreen(),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HelpCenterScreen(),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF5B2BE8),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Add logout logic here
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = const Color(0xFF4A6CF7);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: textColor, size: 28),
            onPressed: () => _showMenu(context),
          ),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        children: [
            const SizedBox(height: 20),
            // Profile Avatar (Circle - NO tap on whole circle)
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: user.avatarUrl.startsWith('http')
                          ? Image.network(
                              user.avatarUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                        errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.person,
                                    color: primaryColor, size: 60),
                              ),
                            )
                          : Image.file(
                              File(user.avatarUrl),
                              fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.person,
                                    color: primaryColor, size: 60),
                              ),
                            ),
                    ),
                  ),
                  // Camera icon overlay (ONLY this button is tappable)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _changeProfilePicture,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child:
                            const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Username
            Center(
              child: Text(
                user.name,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                user.username,
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Stats
            _buildStatsSection(context),
            const SizedBox(height: 30),
            // Posts Section
            Container(
              key: _postsKey,
              child: _buildPostsSection(),
            ),
            const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              // Scroll to posts section
              _scrollToPosts(context);
            },
            child: _buildStatItem(context, 'Posts', '${_userPosts.length}'),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FollowListScreen(
                    title: 'Followers',
                    users: _getFollowersData(),
                    isFollowing: false,
                  ),
                ),
              );
            },
            child: _buildStatItem(context, 'Followers', '12.5k'),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FollowListScreen(
                    title: 'Following',
                    users: _getFollowingData(),
                    isFollowing: true,
                  ),
                ),
              );
            },
            child: _buildStatItem(context, 'Following', '892'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFollowersData() {
    return [
      {
        'name': 'Sarah Johnson',
        'username': '@sarah_j',
        'avatar': 'https://randomuser.me/api/portraits/women/44.jpg',
        'isFollowing': false,
      },
      {
        'name': 'John Smith',
        'username': '@john_s',
        'avatar': 'https://randomuser.me/api/portraits/men/32.jpg',
        'isFollowing': true,
      },
      {
        'name': 'Emma Watson',
        'username': '@emma_w',
        'avatar': 'https://randomuser.me/api/portraits/women/68.jpg',
        'isFollowing': false,
      },
      {
        'name': 'Mike Brown',
        'username': '@mike_b',
        'avatar': 'https://randomuser.me/api/portraits/men/45.jpg',
        'isFollowing': true,
      },
      {
        'name': 'Lisa Davis',
        'username': '@lisa_d',
        'avatar': 'https://randomuser.me/api/portraits/women/55.jpg',
        'isFollowing': false,
      },
      {
        'name': 'David Wilson',
        'username': '@david_w',
        'avatar': 'https://randomuser.me/api/portraits/men/22.jpg',
        'isFollowing': true,
      },
      {
        'name': 'Anna Lee',
        'username': '@anna_l',
        'avatar': 'https://randomuser.me/api/portraits/women/33.jpg',
        'isFollowing': false,
      },
    ];
  }

  List<Map<String, dynamic>> _getFollowingData() {
    return [
      {
        'name': 'Alex Turner',
        'username': '@alex_t',
        'avatar': 'https://randomuser.me/api/portraits/men/11.jpg',
        'isFollowing': true,
      },
      {
        'name': 'Maria Garcia',
        'username': '@maria_g',
        'avatar': 'https://randomuser.me/api/portraits/women/23.jpg',
        'isFollowing': true,
      },
      {
        'name': 'James Chen',
        'username': '@james_c',
        'avatar': 'https://randomuser.me/api/portraits/men/33.jpg',
        'isFollowing': true,
      },
      {
        'name': 'Sophia Kim',
        'username': '@sophia_k',
        'avatar': 'https://randomuser.me/api/portraits/women/12.jpg',
        'isFollowing': true,
      },
      {
        'name': 'Daniel Park',
        'username': '@daniel_p',
        'avatar': 'https://randomuser.me/api/portraits/men/44.jpg',
        'isFollowing': true,
      },
    ];
  }

  void _scrollToPosts(BuildContext context) {
    // Scroll to posts section smoothly
    Scrollable.ensureVisible(
      _postsKey.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildPostsSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Posts',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_userPosts.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _showPostsOptions(context),
                  icon: Icon(Icons.more_vert, color: textColor, size: 16),
                  label: Text('Options', style: TextStyle(color: textColor, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingPosts)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_userPosts.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: textColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No posts yet',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first post to see it here',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _userPosts.length,
              itemBuilder: (context, index) {
                final post = _userPosts[index];
                return GestureDetector(
                  onTap: () => _showUserPostDetail(context, post),
                  onLongPress: () => _showPostOptions(context, post),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          // Post media
                          _buildPostMedia(post),
                          // Post type indicator
                          if (post.isVideo)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showOldPostDetail(BuildContext context, String imageUrl, int postNumber) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = const Color(0xFF4A6CF7);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: isDark ? Border.all(color: Colors.white12) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Post image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    height: 300,
                    child: const Center(
                      child: Icon(Icons.image, color: Colors.grey, size: 64),
                    ),
                  ),
                ),
              ),
              // Post info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Post #$postNumber',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Beautiful moment captured! 📸',
                      style: TextStyle(color: subTextColor, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    // Like and comment buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite_border, color: textColor, size: 20),
                            const SizedBox(width: 4),
                            Text('245', style: TextStyle(color: textColor)),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.chat_bubble_outline, color: textColor, size: 20),
                            const SizedBox(width: 4),
                            Text('18', style: TextStyle(color: textColor)),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.bookmark_border, color: textColor),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostMedia(UserPost post) {
  if (post.thumbnailBytes != null) {
    return Image.memory(
      post.thumbnailBytes!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image, color: Colors.grey),
      ),
    );
  }
  
  if (post.mediaPath.startsWith('http')) {
    return Image.network(
      post.mediaPath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image, color: Colors.grey),
      ),
    );
  }
  
  // Local file
  final file = File(post.mediaPath);
  if (file.existsSync()) {
    return Image.file(
      file,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image, color: Colors.grey),
      ),
    );
  }
  
  // Fallback
  return Container(
    color: Colors.grey[300],
    child: Icon(
      post.isVideo ? Icons.videocam : Icons.image,
      color: Colors.grey,
    ),
  );
}

void _showUserPostDetail(BuildContext context, UserPost post) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black87;
  final subTextColor = isDark ? Colors.white70 : Colors.black54;

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: Colors.white12) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Post image/video
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 300,
                child: _buildPostMedia(post),
              ),
            ),
            // Post info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: post.contentType == ContentMode.post 
                              ? Colors.blue
                              : post.contentType == ContentMode.story 
                                  ? Colors.orange
                                  : Colors.purple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          post.contentType.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(post.timestamp),
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (post.caption.isNotEmpty)
                    Text(
                      post.caption,
                      style: TextStyle(color: textColor, fontSize: 14),
                    ),
                  if (post.hashtags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 6,
                        children: post.hashtags.map((tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 11)),
                          backgroundColor: Colors.blue.withValues(alpha: 0.1),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        )).toList(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(Icons.favorite_border, '${post.likes}'),
                      _buildStat(Icons.chat_bubble_outline, '${post.comments}'),
                      _buildStat(Icons.visibility, post.visibility.name),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showPostOptions(context, post);
                        },
                        icon: const Icon(Icons.more_vert),
                        label: const Text('Options'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showPostOptions(BuildContext context, UserPost post) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          _buildOptionTile(Icons.edit, 'Edit Post', () {
            Navigator.pop(context);
            // TODO: Navigate to edit screen
          }),
          _buildOptionTile(Icons.share, 'Share', () {
            Navigator.pop(context);
            // TODO: Implement sharing
          }),
          _buildOptionTile(Icons.copy, 'Copy Link', () {
            Navigator.pop(context);
            // TODO: Copy post link
          }),
          _buildOptionTile(Icons.delete, 'Delete Post', () async {
            Navigator.pop(context);
            final confirmed = await _showDeleteConfirmation(context);
            if (confirmed) {
              final success = await _postService.deletePost(post.id);
              if (success) {
                _loadUserPosts(); // Refresh posts
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete post'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          }, iconColor: Colors.red),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

void _showPostsOptions(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          _buildOptionTile(Icons.backup, 'Backup Posts', () async {
            Navigator.pop(context);
            final path = await _postService.exportPostsToBackup();
            if (path != null && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Posts backed up to: $path'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }),
          _buildOptionTile(Icons.restore, 'Restore from Backup', () async {
            Navigator.pop(context);
            final success = await _postService.importPostsFromBackup();
            if (success) {
              _loadUserPosts(); // Refresh posts
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Posts restored successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No backup found or restore failed'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          }),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

Widget _buildOptionTile(IconData icon, String label, VoidCallback onTap, {Color? iconColor}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  return ListTile(
    leading: Icon(icon,
        color: iconColor ?? (isDark ? Colors.white : Colors.black87)),
    title: Text(label,
        style: TextStyle(
            color: isDark ? Colors.white : Colors.black87)),
    onTap: onTap,
  );
}

Widget _buildStat(IconData icon, String value) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black87;
  
  return Row(
    children: [
      Icon(icon, color: textColor, size: 20),
      const SizedBox(width: 4),
      Text(value, style: TextStyle(color: textColor)),
    ],
  );
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);
  
  if (difference.inDays > 0) {
    return '${difference.inDays}d ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m ago';
  } else {
    return 'Just now';
  }
}

Future<bool> _showDeleteConfirmation(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Post'),
      content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  ) ?? false;
}

Widget _buildStatItem(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: subTextColor,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
