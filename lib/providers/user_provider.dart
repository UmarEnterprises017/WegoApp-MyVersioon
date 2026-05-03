import 'package:flutter/foundation.dart';
import 'dart:math' as math;

// ── Unified Profile Model ────────────────────────────────────
class AppProfile {
  final String id;
  final String name;
  final int age;
  final String imageUrl;
  final String bio;
  final List<String> interests;
  final double latitude;
  final double longitude;
  final List<String> likedBy; // IDs of users who liked this profile
  final List<String> likes;   // IDs of users this profile has liked
  final bool isMatch;         // Helper to identify mutual match

  AppProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.bio,
    required this.interests,
    required this.latitude,
    required this.longitude,
    this.likedBy = const [],
    this.likes = const [],
    this.isMatch = false,
  });

  AppProfile copyWith({
    String? name,
    int? age,
    String? imageUrl,
    String? bio,
    List<String>? interests,
    double? latitude,
    double? longitude,
    List<String>? likedBy,
    List<String>? likes,
    bool? isMatch,
  }) {
    return AppProfile(
      id: this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      imageUrl: imageUrl ?? this.imageUrl,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      likedBy: likedBy ?? this.likedBy,
      likes: likes ?? this.likes,
      isMatch: isMatch ?? this.isMatch,
    );
  }
}

class UserProvider extends ChangeNotifier {
  // ── Current Logged-in User ──
  AppProfile _currentUser = AppProfile(
    id: 'me',
    name: 'Jung Taekwoon',
    age: 26,
    imageUrl: 'https://randomuser.me/api/portraits/men/52.jpg',
    bio: 'Living life to the fullest! 🌟',
    interests: ['coffee', 'music', 'travel'],
    latitude: 37.5665, // Seoul
    longitude: 126.9780,
    likes: [],
    likedBy: ['user_6'], // Simulated: user_6 already liked us
  );

  // ── Discoverable Users (Pool) ──
  List<AppProfile> _discoveryPool = [
    AppProfile(
      id: 'user_1',
      name: 'Leilani',
      age: 19,
      imageUrl: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=400',
      bio: 'Art lover and weekend hiker.',
      interests: ['art', 'hiking', 'coffee'],
      latitude: 37.5700,
      longitude: 126.9800,
    ),
    AppProfile(
      id: 'user_2',
      name: 'Annabelle',
      age: 20,
      imageUrl: 'https://images.unsplash.com/photo-1488716820095-cbe80883c496?w=400',
      bio: 'Looking for someone to share pizza with.',
      interests: ['pizza', 'movies', 'music'],
      latitude: 37.5500,
      longitude: 126.9600,
    ),
    AppProfile(
      id: 'user_3',
      name: 'Reagan',
      age: 24,
      imageUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400',
      bio: 'Deep convos and spontaneous trips.',
      interests: ['travel', 'coffee', 'photography'],
      latitude: 37.5800,
      longitude: 127.0000,
    ),
    AppProfile(
      id: 'user_6',
      name: 'Tanisha',
      age: 24,
      imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
      bio: 'Lover of cold coffee and deep convos.',
      interests: ['coffee', 'music', 'R&B'],
      latitude: 37.5600,
      longitude: 126.9700,
      likes: ['me'], // She already liked us (Simulated)
    ),
  ];

  AppProfile get currentUser => _currentUser;
  List<AppProfile> get discoveryPool => _getRankedDiscoveryPool();

  // ── Action: Like User ──
  bool likeUser(String targetId) {
    if (!_currentUser.likes.contains(targetId)) {
      _currentUser = _currentUser.copyWith(
        likes: [..._currentUser.likes, targetId],
      );

      // Check for mutual match
      final targetUser = _discoveryPool.firstWhere((u) => u.id == targetId);
      if (targetUser.likes.contains(_currentUser.id) || _currentUser.likedBy.contains(targetId)) {
        // It's a match!
        notifyListeners();
        return true;
      }
    }
    notifyListeners();
    return false;
  }

  // ── 1. Interest Score Logic ──
  int getSharedInterestsCount(AppProfile other) {
    return _currentUser.interests
        .where((interest) => other.interests.contains(interest))
        .length;
  }

  // ── 2. Location Proximity Logic ──
  double getDistanceInKm(AppProfile other) {
    const double earthRadius = 6371;
    double dLat = _degreesToRadians(other.latitude - _currentUser.latitude);
    double dLon = _degreesToRadians(other.longitude - _currentUser.longitude);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(_currentUser.latitude)) *
            math.cos(_degreesToRadians(other.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180;

  // ── 3. Behavioral Ranking Logic ──
  // Ranks the discovery pool based on shared interests, location, and previous likes
  List<AppProfile> _getRankedDiscoveryPool() {
    List<AppProfile> pool = List.from(_discoveryPool);

    // Filter out users already liked
    pool = pool.where((u) => !_currentUser.likes.contains(u.id)).toList();

    pool.sort((a, b) {
      double scoreA = _calculateRankingScore(a);
      double scoreB = _calculateRankingScore(b);
      return scoreB.compareTo(scoreA); // Higher score first
    });

    return pool;
  }

  double _calculateRankingScore(AppProfile profile) {
    double score = 0;

    // shared interests (+10 per interest)
    score += getSharedInterestsCount(profile) * 10;

    // proximity (closer is better, max +20)
    double dist = getDistanceInKm(profile);
    score += math.max(0, 20 - (dist * 2));

    // Behavioral: if they liked us, boost them (+50)
    if (_currentUser.likedBy.contains(profile.id)) {
      score += 50;
    }

    return score;
  }

  // ── 4. Mutual Matches Getter ──
  List<AppProfile> get matches {
    return _discoveryPool.where((u) =>
    _currentUser.likes.contains(u.id) &&
        (u.likes.contains(_currentUser.id) || _currentUser.likedBy.contains(u.id))
    ).toList();
  }
}
