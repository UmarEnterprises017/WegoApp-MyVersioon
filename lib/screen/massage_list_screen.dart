import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeGo Marriage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'sans-serif'),
      home: const MessageListScreen(),
    );
  }
}

// ── Colors ────────────────────────────────────────────────────
const Color kPurple = Color(0xFF6B4EFF);
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

class MessageItem {
  final String name;
  final String lastMessage;
  final String time;
  final String imageUrl;
  final int unreadCount;
  final bool isTyping;

  const MessageItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.imageUrl,
    this.unreadCount = 0,
    this.isTyping = false,
  });
}

// ── Sample Data ───────────────────────────────────────────────
const List<ActivityUser> activities = [
  ActivityUser(
    name: 'You',
    imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    isOnline: true,
    isYou: true,
  ),
  ActivityUser(
    name: 'Emma',
    imageUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=200',
    isOnline: true,
  ),
  ActivityUser(
    name: 'Ava',
    imageUrl: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=200',
    isOnline: true,
  ),
  ActivityUser(
    name: 'Sophia',
    imageUrl: 'https://images.unsplash.com/photo-1488716820095-cbe80883c496?w=200',
    isOnline: true,
  ),
  ActivityUser(
    name: 'Amelia',
    imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200',
    isOnline: true,
  ),
];

const List<MessageItem> messages = [
  MessageItem(
    name: 'Emelie',
    lastMessage: 'Sticker 😍',
    time: '23 min',
    imageUrl: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=200',
    unreadCount: 1,
  ),
  MessageItem(
    name: 'Abigail',
    lastMessage: 'Typing..',
    time: '27 min',
    imageUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=200',
    unreadCount: 2,
    isTyping: true,
  ),
  MessageItem(
    name: 'Elizabeth',
    lastMessage: 'Ok, see you then.',
    time: '33 min',
    imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
  ),
  MessageItem(
    name: 'Penelope',
    lastMessage: 'You: Hey! What\'s up, long time..',
    time: '50 min',
    imageUrl: 'https://images.unsplash.com/photo-1488716820095-cbe80883c496?w=200',
  ),
  MessageItem(
    name: 'Chloe',
    lastMessage: 'You: Hello how are you?',
    time: '55 min',
    imageUrl: 'https://images.unsplash.com/photo-1519699047748-de8e457a634e?w=200',
  ),
  MessageItem(
    name: 'Grace',
    lastMessage: 'You: Great I will write later..',
    time: '1 hour',
    imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200',
  ),
  MessageItem(
    name: 'Chloe',
    lastMessage: 'You: Hello how are you?',
    time: '55 min',
    imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
  ),
];

// ── Main Screen ───────────────────────────────────────────────
class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  int _currentIndex = 2; // chats selected

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Status bar space
          Container(
            color: Colors.white,
            height: MediaQuery.of(context).padding.top,
          ),

          // ── Top bar: "category" ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Center(
              child: Text(
                'category',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header ──
                SliverToBoxAdapter(child: _buildHeader()),

                // ── Activities section ──
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 10),
                    child: Text(
                      'Activities',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildActivities()),

                // ── Messages section ──
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
                    child: Text(
                      'Messages',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _MessageTile(message: messages[index]),
                    childCount: messages.length,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),

      // ── FAB ──
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: kTeal,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── Bottom Nav ──
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Messages',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
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

  // ── Activities Row ───────────────────────────────────────────
  Widget _buildActivities() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final user = activities[index];
          return _ActivityAvatar(user: user);
        },
      ),
    );
  }
}

// ── Activity Avatar ───────────────────────────────────────────
class _ActivityAvatar extends StatelessWidget {
  final ActivityUser user;
  const _ActivityAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Stack(
            children: [
              // Ring border
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: user.isYou
                      ? null
                      : const LinearGradient(
                    colors: [Color(0xFFFF6B6B), kPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: user.isYou
                      ? Border.all(color: Colors.grey.shade300, width: 2)
                      : null,
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: Image.network(
                    user.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              // Online dot
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
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            user.name,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

// ── Message Tile ──────────────────────────────────────────────
class _MessageTile extends StatelessWidget {
  final MessageItem message;
  const _MessageTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Avatar with gradient ring
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B6B), kPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: Image.network(
                    message.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Name + last message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message.lastMessage,
                      style: TextStyle(
                        fontSize: 13,
                        color: message.isTyping
                            ? Colors.grey
                            : Colors.grey.shade600,
                        fontStyle: message.isTyping
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Time + unread badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (message.unreadCount > 0)
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: kUnreadRed,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${message.unreadCount}',
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
        // Divider
        Padding(
          padding: const EdgeInsets.only(left: 86),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ],
    );
  }
}

// ── Bottom Navigation Bar ─────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: kPurple,
      elevation: 10,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 62,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home,
              label: 'Home',
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.favorite_border,
              label: 'favorite',
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            const SizedBox(width: 48),
            _NavItem(
              icon: Icons.chat_bubble_outline,
              label: 'chats',
              selected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _NavItem(
              icon: Icons.person,
              label: 'Profile',
              selected: currentIndex == 3,
              onTap: () => onTap(3),
              showCircle: currentIndex == 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool showCircle;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.showCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          showCircle
              ? Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          )
              : Icon(
            icon,
            color: selected ? Colors.white : Colors.white.withValues(alpha: 0.6),
            size: 26,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: selected ? Colors.white : Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}