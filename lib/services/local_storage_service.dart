import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
// Chat message save karne ke liye function
  Future<void> saveChatMessage(String username, dynamic message) async {
    // Misal ke taur par agar aap String list save karna chahte hain:
    List<String> messages = _prefs?.getStringList('chat_$username') ?? [];
    messages.add(message);
    await _prefs?.setStringList('chat_$username', messages);
  }

  // Call status save karne ke liye function
  Future<void> saveCallStatus(String username, Map<String, dynamic> callStatus) async {
    // Save with proper JSON encoding
    final statusJson = {
      'isInCall': callStatus['isInCall'] ?? false,
      'isVideoCall': callStatus['isVideoCall'] ?? false,
      'isIncomingCall': callStatus['isIncomingCall'] ?? false,
      'callStatus': callStatus['callStatus'] ?? '',
      'timestamp': callStatus['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      'caller': callStatus['caller'] ?? username,
    };
    await _prefs?.setString('call_status_$username', jsonEncode(statusJson));
  }

  // Call status get karne ke liye function
  Map<String, dynamic>? getCallStatus(String username) {
    final status = _prefs?.getString('call_status_$username');
    if (status != null) {
      try {
        // Parse the JSON string back to Map
        final statusMap = jsonDecode(status) as Map<String, dynamic>;
        
        return {
          'isInCall': statusMap['isInCall'] ?? false,
          'isVideoCall': statusMap['isVideoCall'] ?? false,
          'isIncomingCall': statusMap['isIncomingCall'] ?? false,
          'callStatus': statusMap['callStatus'] ?? '',
          'timestamp': statusMap['timestamp'] ?? 0,
          'caller': statusMap['caller'] ?? '',
        };
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Call status remove karne ke liye function
  Future<void> removeCallStatus(String username) async {
    await _prefs?.remove('call_status_$username');
  }

  // Check if call status is recent (within last 30 seconds)
  bool isCallStatusRecent(String username) {
    final callStatus = getCallStatus(username);
    if (callStatus != null) {
      final timestamp = callStatus['timestamp'] as int? ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      return (now - timestamp) < 30000; // 30 seconds
    }
    return false;
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
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        }
        return Map<String, dynamic>.from(item as Map);
      }).toList();
    } catch (e) {
      // If JSON parsing fails, return empty list
      return [];
    }
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

  // ─────────────────────────────────────────────────────────────
  // PERSISTENT CHAT BACKUP - Survives app uninstall/reinstall
  // ─────────────────────────────────────────────────────────────

  /// Export all chats to a JSON file in device storage (Downloads/Documents)
  /// This file can be used to restore chats after app reinstall
  Future<String?> exportAllChatsToFile() async {
    try {
      final allChats = <String, dynamic>{};
      final chattedUsers = getChattedUsers();

      for (final userId in chattedUsers) {
        final messages = getChatMessages(userId);
        final settings = getUserChatSettings(userId);
        final favoriteStickers = getFavoriteStickers(userId);

        allChats[userId] = {
          'messages': messages,
          'settings': settings,
          'favoriteStickers': favoriteStickers,
          'exportTimestamp': DateTime.now().millisecondsSinceEpoch,
        };
      }

      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'totalChats': chattedUsers.length,
        'chats': allChats,
      };

      final jsonString = jsonEncode(exportData);

      // Try to save to Downloads folder first, then Documents
      String? filePath;
      try {
        // For Android - use external storage
        final directory = Directory('/storage/emulated/0/Download');
        if (await directory.exists()) {
          final file = File('${directory.path}/wego_chats_backup.json');
          await file.writeAsString(jsonString);
          filePath = file.path;
        }
      } catch (e) {
        // Fallback to app documents
      }

      // Save to app documents as backup
      final appDir = await getApplicationDocumentsDirectory();
      final backupFile = File('${appDir.path}/wego_chats_backup.json');
      await backupFile.writeAsString(jsonString);

      return filePath ?? backupFile.path;
    } catch (e) {
      print('Error exporting chats: $e');
      return null;
    }
  }

  /// Import chats from backup file
  Future<bool> importChatsFromFile([String? filePath]) async {
    try {
      File? backupFile;

      if (filePath != null && filePath.isNotEmpty) {
        backupFile = File(filePath);
      } else {
        // Try to find backup in Downloads
        try {
          final downloadDir = Directory('/storage/emulated/0/Download');
          final downloadFile = File('${downloadDir.path}/wego_chats_backup.json');
          if (await downloadFile.exists()) {
            backupFile = downloadFile;
          }
        } catch (e) {
          // Ignore and check app directory
        }

        // Fallback to app documents
        if (backupFile == null || !await backupFile.exists()) {
          final appDir = await getApplicationDocumentsDirectory();
          backupFile = File('${appDir.path}/wego_chats_backup.json');
        }
      }

      if (!await backupFile.exists()) {
        return false;
      }

      final jsonString = await backupFile.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (!data.containsKey('chats')) {
        return false;
      }

      final chats = data['chats'] as Map<String, dynamic>;

      for (final entry in chats.entries) {
        final userId = entry.key;
        final userData = entry.value as Map<String, dynamic>;

        // Restore messages
        if (userData.containsKey('messages')) {
          final messages = (userData['messages'] as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          await saveChatMessages(userId, messages);
        }

        // Restore settings
        if (userData.containsKey('settings')) {
          final settings = Map<String, dynamic>.from(userData['settings'] as Map);
          await saveUserChatSettings(userId, settings);
        }

        // Restore favorite stickers
        if (userData.containsKey('favoriteStickers')) {
          final stickers = (userData['favoriteStickers'] as List<dynamic>).cast<String>();
          await saveFavoriteStickers(userId, stickers);
        }
      }

      return true;
    } catch (e) {
      print('Error importing chats: $e');
      return false;
    }
  }

  /// Check if backup file exists
  Future<bool> hasBackupFile() async {
    try {
      // Check Downloads
      try {
        final downloadDir = Directory('/storage/emulated/0/Download');
        final downloadFile = File('${downloadDir.path}/wego_chats_backup.json');
        if (await downloadFile.exists()) {
          return true;
        }
      } catch (e) {
        // Ignore
      }

      // Check app documents
      final appDir = await getApplicationDocumentsDirectory();
      final backupFile = File('${appDir.path}/wego_chats_backup.json');
      return await backupFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// Auto-backup on important events (message sent, call ended, etc.)
  Future<void> autoBackupChats() async {
    // Only backup every 5 minutes to avoid performance issues
    final lastBackup = _prefs?.getInt('last_auto_backup') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastBackup > 5 * 60 * 1000) { // 5 minutes
      await exportAllChatsToFile();
      await _prefs?.setInt('last_auto_backup', now);
    }
  }

  /// Clear all data EXCEPT chat messages (for logout without losing chats)
  Future<void> clearAllDataExceptChats() async {
    final chattedUsers = getChattedUsers();
    final allChatData = <String, List<Map<String, dynamic>>>{};
    final allChatSettings = <String, Map<String, dynamic>>{};
    final allFavoriteStickers = <String, List<String>>{};

    // Save all chat data before clearing
    for (final userId in chattedUsers) {
      allChatData[userId] = getChatMessages(userId);
      allChatSettings[userId] = getUserChatSettings(userId);
      allFavoriteStickers[userId] = getFavoriteStickers(userId);
    }

    // Clear everything
    await _prefs?.clear();

    // Restore only chat data
    for (final entry in allChatData.entries) {
      await saveChatMessages(entry.key, entry.value);
      if (allChatSettings.containsKey(entry.key)) {
        await saveUserChatSettings(entry.key, allChatSettings[entry.key]!);
      }
      if (allFavoriteStickers.containsKey(entry.key)) {
        await saveFavoriteStickers(entry.key, allFavoriteStickers[entry.key]!);
      }
    }
  }

  /// Delete all chat history for a specific user
  Future<void> deleteChatHistory(String userId) async {
    await _prefs?.remove('chat_$userId');
    await _prefs?.remove('chat_settings_$userId');
    await _prefs?.remove('favorites_stickers_$userId');
    await _prefs?.remove('call_status_$userId');
    await _prefs?.remove('message_status_$userId');

    // Remove from chatted users list
    final chatList = getChattedUsers();
    chatList.remove(userId);
    await _prefs?.setStringList('chatted_users', chatList.toList());

    // Update last messages
    final lastMsgsJson = _prefs?.getString('last_messages') ?? '{}';
    final Map<String, dynamic> lastMsgs = jsonDecode(lastMsgsJson);
    lastMsgs.remove(userId);
    await _prefs?.setString('last_messages', jsonEncode(lastMsgs));
  }

  /// Delete ALL chat history across all users
  Future<void> deleteAllChatHistory() async {
    final chattedUsers = getChattedUsers().toList();

    for (final userId in chattedUsers) {
      await _prefs?.remove('chat_$userId');
      await _prefs?.remove('chat_settings_$userId');
      await _prefs?.remove('favorites_stickers_$userId');
      await _prefs?.remove('call_status_$userId');
      await _prefs?.remove('message_status_$userId');
    }

    await _prefs?.remove('chatted_users');
    await _prefs?.remove('last_messages');
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
    'replies': replies.map((reply) => reply.toJson()).toList(),
    'isTranslated': isTranslated,
    'translatedText': translatedText,
  };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: (json['id'] as String?) ?? "",
    username: (json['username'] as String?) ?? "",
    avatarUrl: (json['avatarUrl'] as String?) ?? "",
    text: (json['text'] as String?) ?? "",
    timestamp: DateTime.parse((json['timestamp'] as String?) ?? DateTime.now().toIso8601String()),
    likes: (json['likes'] as int?) ?? 0,
    dislikes: (json['dislikes'] as int?) ?? 0,
    replies: (json['replies'] as List<dynamic>?)
            ?.map((reply) => Comment.fromJson(reply as Map<String, dynamic>))
            .toList() ??
        [],
    isTranslated: (json['isTranslated'] as bool?) ?? false,
    translatedText: json['translatedText'] as String?,
  );
}
