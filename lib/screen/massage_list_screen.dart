import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wego_marriage/providers/chat_provider.dart';
import 'package:wego_marriage/screen/user_profile_screen.dart';
import 'package:wego_marriage/screen/chat_screen.dart';

// ── Colors ────────────────────────────────────────────────────
const Color kPrimaryBlue = Color(0xFF4A6CF7);
const Color kTeal = Color(0xFF2EC4B6);
const Color kOnline = Color(0xFF44D362);
const Color kUnreadRed = Color(0xFFFF3B30);

// ── Models ────────────────────────────────────────────────────
class ActivityUser {
  final String name;
  final String imageUrl;
  final bool isOnline;
  final bool isYou;

  const ActivityUser({
    required this.name,
    required this.imageUrl,
    this.isOnline = false,
    this.isYou = false,
  });
}

// ── Main Screen ───────────────────────────────────────────────
class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  @override
  void initState() {
    super.initState();
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadChats();
    });
  }

  final List<ActivityUser> _activities = [
    const ActivityUser(
      name: 'You',
      imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
      isOnline: true,
      isYou: true,
    ),
    const ActivityUser(
      name: 'Emma',
      imageUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=200',
      isOnline: true,
    ),
  ];

  void _onChatOpened(ChatUser chat) async {
    final chatProvider = context.read<ChatProvider>();

    // Mark as read (WhatsApp-style: blue ticks when seen)
    await chatProvider.markChatAsSeen(chat.name);

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          username: chat.name,
          avatarUrl: chat.imageUrl,
          lastMessage: chat.lastMessage,
        ),
      ),
    );

    if (!mounted) return;
    // Reload chats when returning (for any new messages)
    chatProvider.loadChats();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            height: MediaQuery.of(context).padding.top,
          ),
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                'category',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(textColor)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    child: Text(
                      'Activities',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildActivities(textColor)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                    child: Text(
                      'Messages',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                // WhatsApp-style: Realtime chat list with Consumer
                Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final chat = chatProvider.chats[index];
                          return _MessageTile(
                            chat: chat,
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            onTap: () => _onChatOpened(chat),
                          );
                        },
                        childCount: chatProvider.chats.length,
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Messages',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              border: Border.all(color: textColor.withValues(alpha: 0.1), width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '1L',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivities(Color textColor) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final user = _activities[index];
          return _ActivityAvatar(user: user, textColor: textColor);
        },
      ),
    );
  }
}

class _ActivityAvatar extends StatelessWidget {
  final ActivityUser user;
  final Color textColor;
  const _ActivityAvatar({required this.user, required this.textColor});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfileScreen(
              username: user.name,
              avatarUrl: user.imageUrl,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: user.isYou
                        ? null
                        : const LinearGradient(
                      colors: [Color(0xFFFF6B6B), kPrimaryBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: user.isYou
                        ? Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300, width: 2)
                        : null,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: Image.network(
                      user.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (user.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: kOnline,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? Colors.black : Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(user.name, style: TextStyle(fontSize: 12, color: textColor)),
          ],
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final ChatUser chat;
  final Color textColor;
  final Color secondaryTextColor;
  final VoidCallback onTap;

  const _MessageTile({
    required this.chat,
    required this.textColor,
    required this.secondaryTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserProfileScreen(
                          username: chat.name,
                          avatarUrl: chat.imageUrl,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF6B6B), kPrimaryBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: Image.network(
                        chat.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        chat.isTyping ? 'Typing...' : chat.formattedLastMessage,
                        style: TextStyle(
                          fontSize: 13,
                          color: chat.isTyping
                              ? kTeal
                              : (chat.unreadCount > 0 ? (isDark ? Colors.white : Colors.black) : secondaryTextColor),
                          fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      chat.time,
                      style: TextStyle(
                        fontSize: 12,
                        color: chat.unreadCount > 0 ? kPrimaryBlue : secondaryTextColor.withValues(alpha: 0.5),
                        fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (chat.unreadCount > 0)
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: kPrimaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${chat.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 22),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 86),
            child: Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade200),
          ),
        ],
      ),
    );
  }
}
