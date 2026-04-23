import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Like Actions ---
  Future<void> toggleLike(String postId, bool isLiked) async {
    final likedPosts = getLikedPosts();
    if (isLiked) {
      likedPosts.add(postId);
    } else {
      likedPosts.remove(postId);
    }
    await _prefs?.setStringList('liked_posts', likedPosts.toList());
  }

  Set<String> getLikedPosts() {
    return _prefs?.getStringList('liked_posts')?.toSet() ?? {};
  }

  bool isPostLiked(String postId) {
    return getLikedPosts().contains(postId);
  }

  // --- Save/Favorite Actions ---
  Future<void> toggleSaved(String postId, bool isSaved) async {
    final savedPosts = getSavedPosts();
    if (isSaved) {
      savedPosts.add(postId);
    } else {
      savedPosts.remove(postId);
    }
    await _prefs?.setStringList('saved_posts', savedPosts.toList());
  }

  Set<String> getSavedPosts() {
    return _prefs?.getStringList('saved_posts')?.toSet() ?? {};
  }

  bool isPostSaved(String postId) {
    return getSavedPosts().contains(postId);
  }

  // --- Follow Actions ---
  Future<void> toggleFollow(String userId, bool isFollowing) async {
    final followingUsers = getFollowingUsers();
    if (isFollowing) {
      followingUsers.add(userId);
    } else {
      followingUsers.remove(userId);
    }
    await _prefs?.setStringList('following_users', followingUsers.toList());
  }

  Set<String> getFollowingUsers() {
    return _prefs?.getStringList('following_users')?.toSet() ?? {};
  }

  bool isUserFollowed(String userId) {
    return getFollowingUsers().contains(userId);
  }

  // --- Persistent Chat Storage ---
  Future<void> saveChatMessages(String userId, List<Map<String, dynamic>> messages) async {
    final encoded = jsonEncode(messages);
    await _prefs?.setString('chat_$userId', encoded);

    final chatList = getChattedUsers();
    if (!chatList.contains(userId)) {
      chatList.add(userId);
      await _prefs?.setStringList('chatted_users', chatList.toList());
    }
  }

  Set<String> getChattedUsers() {
    return _prefs?.getStringList('chatted_users')?.toSet() ?? {};
  }

  List<Map<String, dynamic>> getChatMessages(String userId) {
    final jsonStr = _prefs?.getString('chat_$userId');
    if (jsonStr == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonStr);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> updateLastMessage(
      String userId,
      String message,
      String time, {
        String? avatarUrl,
        String? messageType,
        bool? isFromMe,
      }) async {
    final lastMsgsJson = _prefs?.getString('last_messages') ?? '{}';
    final Map<String, dynamic> lastMsgs = jsonDecode(lastMsgsJson);
    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    lastMsgs[userId] = {
      'message': message,
      'time': time,
      'avatarUrl': avatarUrl,
      'timestamp': timestamp,
      'messageType': messageType ?? 'text',
      'isFromMe': isFromMe ?? false,
      'isSeen': false,
    };
    await _prefs?.setString('last_messages', jsonEncode(lastMsgs));
  }

  // --- Message Status Management ---
  Future<void> updateMessageStatus(String userId, String messageTime, String status) async {
    final statusJson = _prefs?.getString('message_status_$userId') ?? '{}';
    final Map<String, dynamic> statusMap = jsonDecode(statusJson);
    statusMap[messageTime] = status;
    await _prefs?.setString('message_status_$userId', jsonEncode(statusMap));
  }

  String getMessageStatus(String userId, String messageTime) {
    final statusJson = _prefs?.getString('message_status_$userId') ?? '{}';
    final Map<String, dynamic> statusMap = jsonDecode(statusJson);
    return (statusMap[messageTime] as String?) ?? 'sent';
  }

  Future<void> markChatAsSeen(String userId) async {
    final lastMsgsJson = _prefs?.getString('last_messages') ?? '{}';
    final Map<String, dynamic> lastMsgs = jsonDecode(lastMsgsJson);
    if (lastMsgs.containsKey(userId)) {
      lastMsgs[userId]['isSeen'] = true;
      await _prefs?.setString('last_messages', jsonEncode(lastMsgs));
    }
  }

  bool isChatSeen(String userId) {
    final lastMsgsJson = _prefs?.getString('last_messages') ?? '{}';
    final Map<String, dynamic> lastMsgs = jsonDecode(lastMsgsJson);
    return lastMsgs[userId]?['isSeen'] ?? false;
  }

  Map<String, dynamic> getLastMessage(String userId) {
    final lastMsgsJson = _prefs?.getString('last_messages') ?? '{}';
    final Map<String, dynamic> lastMsgs = jsonDecode(lastMsgsJson);
    return (lastMsgs[userId] as Map<String, dynamic>?) ?? {};
  }

  // --- Sticker & Settings Methods ---
  Future<void> saveFavoriteStickers(String username, List<String> stickers) async {
    await _prefs?.setStringList('favorites_stickers_$username', stickers);
  }

  List<String> getFavoriteStickers(String username) {
    return _prefs?.getStringList('favorites_stickers_$username') ?? [];
  }

  Future<void> saveUserChatSettings(String username, Map<String, dynamic> settings) async {
    final jsonStr = jsonEncode(settings);
    await _prefs?.setString('chat_settings_$username', jsonStr);
  }

  Map<String, dynamic> getUserChatSettings(String username) {
    final jsonStr = _prefs?.getString('chat_settings_$username');
    if (jsonStr == null) return {};
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  // --- Comments Storage ---
  Future<void> addComment(String postId, Comment comment) async {
    final comments = getComments(postId);
    comments.add(comment);
    await _saveComments(postId, comments);
  }

  Future<void> deleteComment(String postId, String commentId) async {
    final comments = getComments(postId);
    comments.removeWhere((c) => c.id == commentId);
    await _saveComments(postId, comments);
  }

  List<Comment> getComments(String postId) {
    final commentsJson = _prefs?.getString('comments_$postId');
    if (commentsJson == null) return [];
    final List<dynamic> decoded = jsonDecode(commentsJson);
    // Yahan explicit cast 'as Map<String, dynamic>' add kiya hai
    return decoded.map((json) => Comment.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> _saveComments(String postId, List<Comment> comments) async {
    final encoded = jsonEncode(comments.map((c) => c.toJson()).toList());
    await _prefs?.setString('comments_$postId', encoded);
  }

  // --- Comment Interactions ---
  Future<void> toggleCommentLike(String commentId, bool isLiked) async {
    final likedComments = getLikedComments();
    if (isLiked) {
      likedComments.add(commentId);
      await toggleCommentDislike(commentId, false);
    } else {
      likedComments.remove(commentId);
    }
    await _prefs?.setStringList('liked_comments', likedComments.toList());
  }

  Set<String> getLikedComments() {
    return _prefs?.getStringList('liked_comments')?.toSet() ?? {};
  }

  bool isCommentLiked(String commentId) {
    return getLikedComments().contains(commentId);
  }

  Future<void> toggleCommentDislike(String commentId, bool isDisliked) async {
    final dislikedComments = getDislikedComments();
    if (isDisliked) {
      dislikedComments.add(commentId);
      await toggleCommentLike(commentId, false);
    } else {
      dislikedComments.remove(commentId);
    }
    await _prefs?.setStringList('disliked_comments', dislikedComments.toList());
  }

  Set<String> getDislikedComments() {
    return _prefs?.getStringList('disliked_comments')?.toSet() ?? {};
  }

  bool isCommentDisliked(String commentId) {
    return getDislikedComments().contains(commentId);
  }

  // --- Utility ---
  Future<void> clearAllData() async {
    await _prefs?.clear();
  }

  Future<void> saveActionTimestamp(String actionType) async {
    await _prefs?.setInt('action_${actionType}_timestamp', DateTime.now().millisecondsSinceEpoch);
  }
}

// --- Comment Model ---
class Comment {
  final String id;
  final String username;
  final String avatarUrl;
  final String text;
  final DateTime timestamp;
  int likes;
  int dislikes;
  List<Comment> replies;
  bool isTranslated;
  String? translatedText;

  Comment({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.text,
    required this.timestamp,
    this.likes = 0,
    this.dislikes = 0,
    this.replies = const [],
    this.isTranslated = false,
    this.translatedText,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'avatarUrl': avatarUrl,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'likes': likes,
    'dislikes': dislikes,
    'isTranslated': isTranslated,
    'translatedText': translatedText,
  };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: (json['id'] as String?) ?? "",
    username: (json['username'] as String?) ?? "",
    avatarUrl: (json['avatarUrl'] as String?) ?? "",
    text: (json as String?) ?? "", // Sab jagah 'as String' add kar diya
    timestamp: DateTime.parse((json['timestamp'] as String?) ?? DateTime.now().toIso8601String()),
    likes: json['likes'] ?? 0,
    dislikes: json['dislikes'] ?? 0,
    isTranslated: json['isTranslated'] ?? false,
    translatedText: json['translatedText'] as String?,
  );
}
