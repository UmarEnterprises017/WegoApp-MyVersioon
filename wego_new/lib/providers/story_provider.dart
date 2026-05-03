import 'package:flutter/material.dart';

class StoryItem {
  final String id;
  final String imageUrl;
  final String username;
  final String avatarUrl;

  StoryItem({
    required this.id,
    required this.imageUrl,
    required this.username,
    required this.avatarUrl,
  });
}

class UserStory {
  final String userId;
  final String username;
  final String avatarUrl;
  final List<StoryItem> stories;
  bool isWatched;

  UserStory({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.stories,
    this.isWatched = false,
  });
}

class StoryProvider with ChangeNotifier {
  final List<UserStory> _userStories = [
    UserStory(
      userId: 'u1',
      username: 'Sarah',
      avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      stories: [
        StoryItem(
          id: 's1_1',
          imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
          username: 'Sarah',
          avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
        ),
        StoryItem(
          id: 's1_2',
          imageUrl: 'https://picsum.photos/seed/story1/800/1200',
          username: 'Sarah',
          avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
        ),
        StoryItem(
          id: 's1_3',
          imageUrl: 'https://picsum.photos/seed/story2/800/1200',
          username: 'Sarah',
          avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
        ),
      ],
    ),
    UserStory(
      userId: 'u2',
      username: 'John',
      avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      stories: [
        StoryItem(
          id: 's2_1',
          imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
          username: 'John',
          avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
        ),
        StoryItem(
          id: 's2_2',
          imageUrl: 'https://picsum.photos/seed/story3/800/1200',
          username: 'John',
          avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
        ),
      ],
    ),
    UserStory(
      userId: 'u3',
      username: 'Emma',
      avatarUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
      stories: [
        StoryItem(
          id: 's3_1',
          imageUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
          username: 'Emma',
          avatarUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
        ),
      ],
    ),
    UserStory(
      userId: 'u4',
      username: 'Mike',
      avatarUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
      stories: [
        StoryItem(
          id: 's4_1',
          imageUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
          username: 'Mike',
          avatarUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
        ),
        StoryItem(
          id: 's4_2',
          imageUrl: 'https://picsum.photos/seed/story4/800/1200',
          username: 'Mike',
          avatarUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
        ),
      ],
    ),
    UserStory(
      userId: 'u5',
      username: 'Lisa',
      avatarUrl: 'https://randomuser.me/api/portraits/women/55.jpg',
      stories: [
        StoryItem(
          id: 's5_1',
          imageUrl: 'https://randomuser.me/api/portraits/women/55.jpg',
          username: 'Lisa',
          avatarUrl: 'https://randomuser.me/api/portraits/women/55.jpg',
        ),
      ],
    ),
  ];

  List<UserStory> get userStories {
    // Return stories sorted: Unwatched first, then Watched
    final unwatched = _userStories.where((u) => !u.isWatched).toList();
    final watched = _userStories.where((u) => u.isWatched).toList();
    return [...unwatched, ...watched];
  }

  void markAsWatched(String userId) {
    final index = _userStories.indexWhere((u) => u.userId == userId);
    if (index != -1 && !_userStories[index].isWatched) {
      _userStories[index].isWatched = true;
      notifyListeners();
    }
  }
}
