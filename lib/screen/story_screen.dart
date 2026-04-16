import 'package:flutter/material.dart';

// Story model
class StoryItem {
  final String imageUrl;
  final String username;
  final String avatarUrl;

  StoryItem({required this.imageUrl, required this.username, required this.avatarUrl});
}

// All stories - each user can have multiple stories
final List<List<StoryItem>> kAllStories = [
  // User 1 - 3 stories
  [
    StoryItem(
      imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      username: 'Sarah',
      avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    ),
    StoryItem(
      imageUrl: 'https://picsum.photos/seed/story1/800/1200',
      username: 'Sarah',
      avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    ),
    StoryItem(
      imageUrl: 'https://picsum.photos/seed/story2/800/1200',
      username: 'Sarah',
      avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    ),
  ],
  // User 2 - 2 stories
  [
    StoryItem(
      imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      username: 'John',
      avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    ),
    StoryItem(
      imageUrl: 'https://picsum.photos/seed/story3/800/1200',
      username: 'John',
      avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    ),
  ],
  // User 3 - 1 story
  [
    StoryItem(
      imageUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
      username: 'Emma',
      avatarUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
    ),
  ],
  // User 4 - 2 stories
  [
    StoryItem(
      imageUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
      username: 'Mike',
      avatarUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
    ),
    StoryItem(
      imageUrl: 'https://picsum.photos/seed/story4/800/1200',
      username: 'Mike',
      avatarUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
    ),
  ],
  // User 5 - 1 story
  [
    StoryItem(
      imageUrl: 'https://randomuser.me/api/portraits/women/55.jpg',
      username: 'Lisa',
      avatarUrl: 'https://randomuser.me/api/portraits/women/55.jpg',
    ),
  ],
];

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
    final currentUserStories = kAllStories[_currentUserIndex];
    
    if (_currentStoryIndex < currentUserStories.length - 1) {
      // Next story of same user
      setState(() {
        _currentStoryIndex++;
      });
      _animationController.reset();
      _animationController.forward();
    } else if (_currentUserIndex < kAllStories.length - 1) {
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

  void _goToPreviousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
      });
      _animationController.reset();
      _animationController.forward();
    } else if (_currentUserIndex > 0) {
      setState(() {
        _currentUserIndex--;
        _currentStoryIndex = kAllStories[_currentUserIndex].length - 1;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      // At the very beginning, just restart current story
      _animationController.reset();
      _animationController.forward();
    }
  }

  int _getTotalStoryCount() {
    int total = 0;
    for (final userStories in kAllStories) {
      total += userStories.length;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserStories = kAllStories[_currentUserIndex];
    final currentStory = currentUserStories[_currentStoryIndex];

    return Scaffold(
      backgroundColor: Colors.black,
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
                    // Start animation if it was stopped due to loading
                    if (!_isPaused && !_animationController.isAnimating) {
                       _animationController.forward();
                    }
                    return child;
                  }
                  // Stop animation while loading
                  _animationController.stop();
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.white, size: 64),
                ),
              ),
            ),
          ),

          // Tap areas for navigation
          Positioned.fill(
            child: Row(
              children: [
                // Left side - previous
                Expanded(
                  child: GestureDetector(
                    onTap: _goToPreviousStory,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                // Right side - next
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
                // Progress indicators
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return _buildProgressIndicators();
                    },
                  ),
                ),
                // User info bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(currentStory.avatarUrl),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        currentStory.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
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

  Widget _buildProgressIndicators() {
    final totalUsers = kAllStories.length;
    final List<Widget> indicators = [];

    for (int userIndex = 0; userIndex < totalUsers; userIndex++) {
      final userStoryCount = kAllStories[userIndex].length;
      
      if (userStoryCount == 1) {
        // Single story user
        indicators.add(
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentUserIndex = userIndex;
                  _currentStoryIndex = 0;
                });
                _animationController.reset();
                _animationController.forward();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 3,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: _isUserComplete(userIndex)
                          ? 1.0
                          : _isUserCurrent(userIndex)
                              ? _animationController.value
                              : 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        // Multiple stories user - show segments
        indicators.add(
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _isUserComplete(userIndex)
                        ? Colors.white
                        : _isUserCurrent(userIndex)
                            ? Colors.white
                            : Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                // Sub-indicators for multiple stories
                Row(
                  children: List.generate(
                    userStoryCount,
                    (storyIndex) => Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentUserIndex = userIndex;
                            _currentStoryIndex = storyIndex;
                          });
                          _animationController.reset();
                          _animationController.forward();
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          height: 2,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: _isStoryComplete(userIndex, storyIndex)
                                    ? 1.0
                                    : _isStoryCurrent(userIndex, storyIndex)
                                        ? _animationController.value
                                        : 0.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Row(children: indicators);
  }

  bool _isUserComplete(int userIndex) {
    return userIndex < _currentUserIndex;
  }

  bool _isUserCurrent(int userIndex) {
    return userIndex == _currentUserIndex;
  }

  bool _isStoryComplete(int userIndex, int storyIndex) {
    if (userIndex < _currentUserIndex) return true;
    if (userIndex == _currentUserIndex && storyIndex < _currentStoryIndex) return true;
    return false;
  }

  bool _isStoryCurrent(int userIndex, int storyIndex) {
    return userIndex == _currentUserIndex && storyIndex == _currentStoryIndex;
  }
}
