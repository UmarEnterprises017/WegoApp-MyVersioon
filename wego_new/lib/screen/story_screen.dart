import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wego_marriage/providers/story_provider.dart';
import 'package:wego_marriage/screen/user_profile_screen.dart';

class StoryScreen extends StatefulWidget {
  final int initialUserIndex;

  const StoryScreen({super.key, required this.initialUserIndex});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentUserIndex = 0;
  int _currentStoryIndex = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _currentUserIndex = widget.initialUserIndex;
    _pageController = PageController(initialPage: 0);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToNextStory();
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _goToNextStory() {
    final storyProvider = context.read<StoryProvider>();
    final allUserStories = storyProvider.userStories;
    final currentUserStories = allUserStories[_currentUserIndex].stories;
    
    if (_currentStoryIndex < currentUserStories.length - 1) {
      // Next story of same user
      setState(() {
        _currentStoryIndex++;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      // Current user's stories finished, mark as watched
      storyProvider.markAsWatched(allUserStories[_currentUserIndex].userId);

      if (_currentUserIndex < allUserStories.length - 1) {
        // Move to next user
        setState(() {
          _currentUserIndex++;
          _currentStoryIndex = 0;
        });
        _animationController.reset();
        _animationController.forward();
      } else {
        // No more stories
        Navigator.of(context).pop();
      }
    }
  }

  void _goToPreviousStory() {
    final allUserStories = context.read<StoryProvider>().userStories;
    
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
      });
      _animationController.reset();
      _animationController.forward();
    } else if (_currentUserIndex > 0) {
      setState(() {
        _currentUserIndex--;
        _currentStoryIndex = allUserStories[_currentUserIndex].stories.length - 1;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      // At the very beginning, just restart current story
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _navigateToProfile(String username, String avatarUrl) {
    _animationController.stop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          username: username,
          avatarUrl: avatarUrl,
        ),
      ),
    ).then((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final allUserStories = storyProvider.userStories;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    
    // Safety check if index out of bounds due to reordering
    if (_currentUserIndex >= allUserStories.length) {
       _currentUserIndex = allUserStories.length - 1;
    }

    final userStory = allUserStories[_currentUserIndex];
    final currentStory = userStory.stories[_currentStoryIndex];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Current story image
          Center(
            child: GestureDetector(
              onLongPress: () {
                setState(() {
                  _isPaused = true;
                });
                _animationController.stop();
              },
              onLongPressUp: () {
                setState(() {
                  _isPaused = false;
                });
                _animationController.forward();
              },
              child: Image.network(
                currentStory.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    if (!_isPaused && !_animationController.isAnimating) {
                       _animationController.forward();
                    }
                    return child;
                  }
                  _animationController.stop();
                  return Center(
                    child: CircularProgressIndicator(color: isDark ? Colors.white : Colors.black87),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(Icons.broken_image, color: textColor, size: 64),
                ),
              ),
            ),
          ),

          // Tap areas for navigation
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _goToPreviousStory,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _goToNextStory,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),

          // Top overlay
          SafeArea(
            child: Column(
              children: [
                // Progress indicators (Segments)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Row(
                        children: List.generate(
                          userStory.stories.length,
                          (index) => _buildProgressBar(index, isDark),
                        ),
                      );
                    },
                  ),
                ),
                // User info bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _navigateToProfile(userStory.username, userStory.avatarUrl),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(userStory.avatarUrl),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _navigateToProfile(userStory.username, userStory.avatarUrl),
                        child: Text(
                          userStory.username,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: isDark ? [const Shadow(color: Colors.black54, blurRadius: 4)] : null,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: textColor),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int index, bool isDark) {
    double progress = 0.0;
    if (index < _currentStoryIndex) {
      progress = 1.0;
    } else if (index == _currentStoryIndex) {
      progress = _animationController.value;
    }

    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isDark ? Colors.white30 : Colors.black26,
          borderRadius: BorderRadius.circular(2),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white : Colors.black87, // Active story color
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}