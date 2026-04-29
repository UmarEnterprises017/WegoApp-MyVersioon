import 'package:image_picker/image_picker.dart';
import 'package:wego_marriage/screen/create_content_screen.dart';
import 'package:wego_marriage/services/local_storage_service.dart';
import 'package:flutter/foundation.dart';

class PostService {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  final LocalStorageService _storage = LocalStorageService();

  /// Save a new post/reel from CreateContentScreen data
  Future<bool> savePostFromCreateScreen({
    required XFile file,
    required Uint8List? imageBytes,
    required bool isVideo,
    required ContentMode mode,
    required String caption,
    required String location,
    required List<String> hashtags,
    required PostVisibility visibility,
    required String taggedPeople,
    required Map<String, dynamic> settings,
  }) async {
    try {
      // Create UserPost object with all details
      final userPost = UserPost(
        id: '${mode.name}_${DateTime.now().millisecondsSinceEpoch}',
        mediaPath: file.path,
        caption: caption,
        contentType: mode,
        timestamp: DateTime.now(),
        location: location,
        hashtags: hashtags,
        visibility: visibility,
        isVideo: isVideo,
        taggedPeople: taggedPeople.isNotEmpty ? [taggedPeople] : [],
        settings: settings,
        thumbnailBytes: imageBytes,
      );

      // Save to persistent storage
      await _storage.saveUserPost(userPost);
      return true;
    } catch (e) {
      debugPrint('Error saving post: $e');
      return false;
    }
  }

  /// Get all user posts/reels
  List<UserPost> getUserPosts() {
    return _storage.getUserPosts();
  }

  /// Delete a post/reel
  Future<bool> deletePost(String postId) async {
    try {
      await _storage.deleteUserPost(postId);
      return true;
    } catch (e) {
      debugPrint('Error deleting post: $e');
      return false;
    }
  }

  /// Update post details
  Future<bool> updatePost(UserPost updatedPost) async {
    try {
      await _storage.updateUserPost(updatedPost);
      return true;
    } catch (e) {
      debugPrint('Error updating post: $e');
      return false;
    }
  }

  /// Get post count
  int getPostCount() {
    return _storage.getUserPostCount();
  }

  /// Import posts from backup
  Future<bool> importPostsFromBackup() async {
    return await _storage.importUserPostsFromFile();
  }

  /// Export posts to backup
  Future<String?> exportPostsToBackup() async {
    return await _storage.exportUserPostsToFile();
  }

  /// Check if backup exists
  Future<bool> hasBackup() async {
    return await _storage.hasPostsBackupFile();
  }
}
