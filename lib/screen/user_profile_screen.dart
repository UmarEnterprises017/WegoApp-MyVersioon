import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  final String username;
  final String avatarUrl;

  const UserProfileScreen({
    super.key,
    required this.username,
    required this.avatarUrl,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final primaryColor = const Color(0xFF4A6CF7);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.username,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: textColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ClipOval(
                        child: Image.network(
                          widget.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 40),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Stats
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Posts', '45', textColor),
                        _buildStatItem('Followers', '1.2k', textColor),
                        _buildStatItem('Following', '380', textColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bio & Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Digital Creator',
                    style: TextStyle(color: subTextColor, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Living life one pixel at a time. 📸✨\nWego Marriage User',
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Edit Profile / Follow Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isFollowing = !_isFollowing;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFollowing
                            ? (isDark ? Colors.white10 : Colors.grey[200])
                            : primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        _isFollowing ? 'Following' : 'Follow',
                        style: TextStyle(
                          color: _isFollowing
                              ? textColor
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        'Message',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.person_add_outlined, color: textColor, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar Area
            const Divider(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.grid_on, color: textColor),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.video_library_outlined, color: subTextColor),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.person_pin_outlined, color: subTextColor),
                  onPressed: () {},
                ),
              ],
            ),
            const Divider(height: 1),

            // Grid View of Posts
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: 18,
              itemBuilder: (context, index) {
                return Image.network(
                  'https://picsum.photos/seed/userpost${index + widget.username.length}/300/300',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color textColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: textColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
