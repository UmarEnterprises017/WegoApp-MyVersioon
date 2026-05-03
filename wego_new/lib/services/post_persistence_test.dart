import 'package:flutter/material.dart';
import 'package:wego_marriage/services/post_service.dart';
import 'package:wego_marriage/services/local_storage_service.dart';
import 'package:wego_marriage/screen/create_content_screen.dart';

class PostPersistenceTest {
  static Future<void> runAllTests() async {
    print('🧪 Running Post Persistence Tests...\n');
    
    await testBasicPostSave();
    await testPostRetrieval();
    await testPostDeletion();
    await testBackupAndRestore();
    await testPersistenceAcrossSessions();
    
    print('\n✅ All tests completed!');
  }
  
  static Future<void> testBasicPostSave() async {
    print('📝 Test 1: Basic Post Save');
    
    try {
      final postService = PostService();
      
      // Create a test post
      final testPost = UserPost(
        id: 'test_post_${DateTime.now().millisecondsSinceEpoch}',
        mediaPath: '/test/path/image.jpg',
        caption: 'Test post for persistence',
        contentType: ContentMode.post,
        timestamp: DateTime.now(),
        location: 'Test City',
        hashtags: ['#test', '#persistence'],
        visibility: PostVisibility.everyone,
        isVideo: false,
        likes: 0,
        comments: 0,
        settings: {'test': true},
      );
      
      // Save using LocalStorageService directly
      final storage = LocalStorageService();
      await storage.saveUserPost(testPost);
      
      // Verify it was saved
      final posts = storage.getUserPosts();
      assert(posts.isNotEmpty, 'Posts list should not be empty');
      assert(posts.first.id == testPost.id, 'Saved post ID should match');
      
      print('   ✅ Post saved successfully');
      print('   📊 Total posts: ${posts.length}');
      
    } catch (e) {
      print('   ❌ Test failed: $e');
    }
  }
  
  static Future<void> testPostRetrieval() async {
    print('\n📂 Test 2: Post Retrieval');
    
    try {
      final storage = LocalStorageService();
      final posts = storage.getUserPosts();
      
      print('   📊 Retrieved ${posts.length} posts');
      
      if (posts.isNotEmpty) {
        final firstPost = posts.first;
        print('   📄 First post details:');
        print('      ID: ${firstPost.id}');
        print('      Caption: ${firstPost.caption}');
        print('      Type: ${firstPost.contentType.name}');
        print('      Created: ${firstPost.timestamp}');
        print('      Hashtags: ${firstPost.hashtags.join(', ')}');
      }
      
      print('   ✅ Post retrieval successful');
      
    } catch (e) {
      print('   ❌ Test failed: $e');
    }
  }
  
  static Future<void> testPostDeletion() async {
    print('\n🗑️ Test 3: Post Deletion');
    
    try {
      final storage = LocalStorageService();
      final postsBefore = storage.getUserPosts();
      
      if (postsBefore.isNotEmpty) {
        final postToDelete = postsBefore.first;
        print('   🗑️ Deleting post: ${postToDelete.id}');
        
        await storage.deleteUserPost(postToDelete.id);
        
        final postsAfter = storage.getUserPosts();
        final found = postsAfter.any((p) => p.id == postToDelete.id);
        
        assert(!found, 'Post should be deleted');
        assert(postsAfter.length == postsBefore.length - 1, 'Post count should decrease by 1');
        
        print('   ✅ Post deleted successfully');
        print('   📊 Posts before: ${postsBefore.length}, after: ${postsAfter.length}');
      } else {
        print('   ⚠️ No posts to delete');
      }
      
    } catch (e) {
      print('   ❌ Test failed: $e');
    }
  }
  
  static Future<void> testBackupAndRestore() async {
    print('\n💾 Test 4: Backup and Restore');
    
    try {
      final storage = LocalStorageService();
      
      // Create backup
      print('   💾 Creating backup...');
      final backupPath = await storage.exportUserPostsToFile();
      
      if (backupPath != null) {
        print('   ✅ Backup created at: $backupPath');
        
        // Clear posts
        await storage.clearAllUserPosts();
        final postsAfterClear = storage.getUserPosts();
        assert(postsAfterClear.isEmpty, 'Posts should be cleared');
        print('   🧹 Posts cleared');
        
        // Restore from backup
        print('   🔄 Restoring from backup...');
        final restored = await storage.importUserPostsFromFile();
        
        assert(restored, 'Restore should succeed');
        final postsAfterRestore = storage.getUserPosts();
        assert(postsAfterRestore.isNotEmpty, 'Posts should be restored');
        
        print('   ✅ Posts restored successfully');
        print('   📊 Restored ${postsAfterRestore.length} posts');
      } else {
        print('   ⚠️ No backup created');
      }
      
    } catch (e) {
      print('   ❌ Test failed: $e');
    }
  }
  
  static Future<void> testPersistenceAcrossSessions() async {
    print('\n🔄 Test 5: Persistence Across Sessions');
    
    try {
      // Simulate app restart by creating new storage instance
      final storage1 = LocalStorageService();
      await storage1.init();
      
      final posts1 = storage1.getUserPosts();
      final initialCount = posts1.length;
      print('   📊 Initial post count: $initialCount');
      
      // Create new storage instance (simulating app restart)
      final storage2 = LocalStorageService();
      await storage2.init();
      
      final posts2 = storage2.getUserPosts();
      final finalCount = posts2.length;
      print('   📊 Post count after "restart": $finalCount');
      
      assert(initialCount == finalCount, 'Post count should persist across sessions');
      
      if (posts2.isNotEmpty) {
        final firstPost = posts2.first;
        print('   📄 First persisted post:');
        print('      ID: ${firstPost.id}');
        print('      Caption: ${firstPost.caption}');
        print('      Type: ${firstPost.contentType.name}');
      }
      
      print('   ✅ Persistence across sessions verified');
      
    } catch (e) {
      print('   ❌ Test failed: $e');
    }
  }
  
  /// Call this method from your app to run tests
  static void runTestInApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Running Tests'),
        content: const Text('Running post persistence tests...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              runAllTests();
            },
            child: const Text('Run Tests'),
          ),
        ],
      ),
    );
  }
}
