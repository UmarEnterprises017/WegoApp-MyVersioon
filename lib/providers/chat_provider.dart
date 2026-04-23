import 'package:flutter/material.dart';
import 'package:wego_marriage/services/local_storage_service.dart';

class ChatUser {
  final String id;
  final String name;
  String lastMessage;
  String time;
  final String imageUrl;
  int timestamp;
  int unreadCount;
  bool isTyping;
  String messageType; // 'text', 'image', 'sticker', 'voice'
  bool isFromMe;
  bool isSeen;

  ChatUser({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.imageUrl,
    required this.timestamp,
    this.unreadCount = 0,
    this.isTyping = false,
    this.messageType = 'text',
    this.isFromMe = false,
    this.isSeen = false,
  });

  // Get formatted last message preview based on type
  String get formattedLastMessage {
    if (isFromMe) {
      switch (messageType) {
        case 'image':
          return 'You: 📷 Photo';
        case 'sticker':
          return 'You: 😍 Sticker';
        case 'voice':
          return 'You: 🎤 Voice message';
        case 'gif':
          return 'You: 🎬 GIF';
        case 'text':
        default:
          if (lastMessage.startsWith('You: ')) {
            return lastMessage;
          }
          return 'You: $lastMessage';
      }
    } else {
      switch (messageType) {
        case 'image':
          return '📷 Photo';
        case 'sticker':
          return '😍 Sticker';
        case 'voice':
          return '🎤 Voice message';
        case 'gif':
          return '🎬 GIF';
        case 'text':
        default:
          return lastMessage;
      }
    }
  }
}

class ChatProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  List<ChatUser> _chats = [];

  List<ChatUser> get chats => _chats;

  ChatProvider() {
    loadChats();
  }

  void loadChats() {
    // Base default chats
    final List<ChatUser> baseChats = [
      ChatUser(
        id: '1',
        name: 'Emelie',
        lastMessage: 'Sticker 😍',
        time: '23 min',
        imageUrl: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=200',
        unreadCount: 1,
        timestamp: DateTime.now().subtract(const Duration(minutes: 23)).millisecondsSinceEpoch,
      ),
      ChatUser(
        id: '2',
        name: 'Abigail',
        lastMessage: 'Typing..',
        time: '27 min',
        imageUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=200',
        unreadCount: 2,
        isTyping: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 27)).millisecondsSinceEpoch,
      ),
      ChatUser(
        id: '3',
        name: 'Elizabeth',
        lastMessage: 'Ok, see you then.',
        time: '33 min',
        imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
        timestamp: DateTime.now().subtract(const Duration(minutes: 33)).millisecondsSinceEpoch,
      ),
      ChatUser(
        id: '4',
        name: 'Penelope',
        lastMessage: 'Hey! What\'s up, long time..',
        time: '50 min',
        imageUrl: 'https://images.unsplash.com/photo-1488716820095-cbe80883c496?w=200',
        timestamp: DateTime.now().subtract(const Duration(minutes: 50)).millisecondsSinceEpoch,
      ),
      ChatUser(
        id: '5',
        name: 'Chloe',
        lastMessage: 'Hello how are you?',
        time: '55 min',
        imageUrl: 'https://images.unsplash.com/photo-1519699047748-de8e457a634e?w=200',
        timestamp: DateTime.now().subtract(const Duration(minutes: 55)).millisecondsSinceEpoch,
      ),
    ];

    final Map<String, ChatUser> mergedMap = {};

    // Add base chats
    for (var chat in baseChats) {
      mergedMap[chat.name] = chat;
    }

    // Add persisted chats
    final chattedUserIds = _storage.getChattedUsers();
    for (String userId in chattedUserIds) {
      final lastData = _storage.getLastMessage(userId);
      if (lastData.isNotEmpty) {
        mergedMap[userId] = ChatUser(
          id: 'dyn_$userId',
          name: userId,
          lastMessage: lastData['message'] ?? 'No message',
          time: lastData['time'] ?? 'Just now',
          imageUrl: lastData['avatarUrl'] ?? 'https://i.pravatar.cc/150?u=$userId',
          timestamp: lastData['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
          messageType: lastData['messageType'] ?? 'text',
          isFromMe: lastData['isFromMe'] ?? false,
          isSeen: lastData['isSeen'] ?? false,
        );
      }
    }

    // Sort by timestamp (Latest on Top - WhatsApp style)
    _chats = mergedMap.values.toList();
    _chats.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    notifyListeners();
  }

  // WhatsApp-style: Move chat to top when new message received
  void updateChatPosition(String username, String lastMessage, String time, String avatarUrl, {String messageType = 'text'}) {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Check if chat already exists
    final existingIndex = _chats.indexWhere((c) => c.name == username);

    if (existingIndex >= 0) {
      // Update existing chat and move to top
      final existingChat = _chats[existingIndex];
      existingChat.lastMessage = lastMessage;
      existingChat.time = time;
      existingChat.timestamp = now;
      existingChat.messageType = messageType;
      existingChat.isFromMe = false; // Received from other user
      existingChat.isSeen = false;
      existingChat.unreadCount++;

      // Remove and re-insert at top
      _chats.removeAt(existingIndex);
      _chats.insert(0, existingChat);
    } else {
      // Add new chat at top
      _chats.insert(0, ChatUser(
        id: 'dyn_$username',
        name: username,
        lastMessage: lastMessage,
        time: time,
        imageUrl: avatarUrl,
        timestamp: now,
        unreadCount: 1,
        messageType: messageType,
        isFromMe: false,
        isSeen: false,
      ));
    }

    notifyListeners();
  }

  // Add or update chat from sent message (my messages)
  void addSentMessage(String username, String messagePreview, String time, String avatarUrl, {String messageType = 'text'}) {
    final now = DateTime.now().millisecondsSinceEpoch;

    final existingIndex = _chats.indexWhere((c) => c.name == username);

    if (existingIndex >= 0) {
      // Move to top
      final chat = _chats[existingIndex];
      chat.lastMessage = messagePreview;
      chat.time = time;
      chat.timestamp = now;
      chat.messageType = messageType;
      chat.isFromMe = true;
      chat.isSeen = false; // Will be updated when seen

      _chats.removeAt(existingIndex);
      _chats.insert(0, chat);
    } else {
      // New chat at top
      _chats.insert(0, ChatUser(
        id: 'dyn_$username',
        name: username,
        lastMessage: messagePreview,
        time: time,
        imageUrl: avatarUrl,
        timestamp: now,
        messageType: messageType,
        isFromMe: true,
        isSeen: false,
      ));
    }

    notifyListeners();
  }

  // Mark chat as seen when I view it
  Future<void> markChatAsSeen(String username) async {
    final chatIndex = _chats.indexWhere((c) => c.name == username);

    if (chatIndex >= 0) {
      _chats[chatIndex].isSeen = true;
      _chats[chatIndex].unreadCount = 0;
      await _storage.markChatAsSeen(username);
      notifyListeners();
    }
  }
}
