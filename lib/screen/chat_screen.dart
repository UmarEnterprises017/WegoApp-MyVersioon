import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeGo Marriage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ChatScreen(),
    );
  }
}

// ── Colors ────────────────────────────────────────────────────
const Color kPurple = Color(0xFF6B4EFF);
const Color kTeal = Color(0xFF2EC4B6);
const Color kDarkBubble = Color(0xFF1E1E2E);

// ── Message Model ─────────────────────────────────────────────
enum MsgType { text, image, linkPreview }

class ChatMessage {
  final String? text;
  final bool isMine;
  final MsgType type;
  final String? imageUrl;
  final String? linkTitle;
  final String? linkDomain;
  final String? linkImageUrl;
  final String? avatarUrl;

  const ChatMessage({
    this.text,
    required this.isMine,
    this.type = MsgType.text,
    this.imageUrl,
    this.linkTitle,
    this.linkDomain,
    this.linkImageUrl,
    this.avatarUrl,
  });
}

// ── Sample Messages ───────────────────────────────────────────
const String _avatar =
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200';

final List<ChatMessage> chatMessages = [
  const ChatMessage(
    text: "What's up.",
    isMine: false,
    avatarUrl: _avatar,
  ),
  const ChatMessage(
    isMine: false,
    type: MsgType.image,
    imageUrl:
    'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=600',
    avatarUrl: _avatar,
  ),
  const ChatMessage(
    isMine: false,
    type: MsgType.linkPreview,
    linkTitle: 'Antelope Canyon guide tour',
    linkDomain: 'airbnb.com',
    linkImageUrl:
    'https://images.unsplash.com/photo-1527489377706-5bf97e608852?w=600',
    avatarUrl: _avatar,
  ),
  const ChatMessage(
    text: 'Oh hello there!',
    isMine: true,
  ),
  const ChatMessage(
    text: 'Hi, this is a message',
    isMine: false,
    avatarUrl: _avatar,
  ),
];

// ── Chat Screen ───────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _currentIndex = 2;
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<ChatMessage> _messages = List.from(chatMessages);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: kPurple,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    // Trigger vibration if enabled
    final settings = context.read<SettingsProvider>();
    if (settings.vibrate) {
      HapticFeedback.mediumImpact();
    }

    setState(() {
      _messages.add(ChatMessage(text: text, isMine: true));
      _msgCtrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Status bar
          Container(
            color: kPurple,
            height: MediaQuery.of(context).padding.top,
          ),

          // ── App Bar ──
          _buildAppBar(),

          // ── Messages ──
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageItem(_messages[index]);
              },
            ),
          ),

          // ── Input bar ──
          _buildInputBar(),
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

  // ── App Bar ──────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: kPurple,
      padding: const EdgeInsets.fromLTRB(10, 8, 16, 12),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 6),
          // Avatar
          ClipOval(
            child: Image.network(
              _avatar,
              width: 42,
              height: 42,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 42,
                height: 42,
                color: Colors.grey[400],
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Name
          const Text(
            'Emma',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Action icons
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam_outlined, color: Colors.white, size: 24),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call_outlined, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  // ── Build Message ─────────────────────────────────────────────
  Widget _buildMessageItem(ChatMessage msg) {
    if (msg.isMine) {
      return _MyBubble(message: msg);
    }
    switch (msg.type) {
      case MsgType.image:
        return _TheirImageMessage(message: msg);
      case MsgType.linkPreview:
        return _TheirLinkPreview(message: msg);
      default:
        return _TheirTextBubble(message: msg);
    }
  }

  // ── Input Bar ─────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      color: kDarkBubble,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Avatar
          ClipOval(
            child: Image.network(
              _avatar,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 36,
                height: 36,
                color: Colors.grey[400],
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Text field
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Hi, this is a message',
                hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          // Send icon
          GestureDetector(
            onTap: _sendMessage,
            child: const Icon(Icons.send, color: Colors.white54, size: 22),
          ),
        ],
      ),
    );
  }
}

// ── Their Text Bubble ─────────────────────────────────────────
class _TheirTextBubble extends StatelessWidget {
  final ChatMessage message;
  const _TheirTextBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _Avatar(url: message.avatarUrl),
          const SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Text(
              message.text ?? '',
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Their Image Message ───────────────────────────────────────
class _TheirImageMessage extends StatelessWidget {
  final ChatMessage message;
  const _TheirImageMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _Avatar(url: message.avatarUrl),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      message.imageUrl!,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 40),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.download,
                  color: Colors.grey,
                  size: 22,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Their Link Preview ────────────────────────────────────────
class _TheirLinkPreview extends StatelessWidget {
  final ChatMessage message;
  const _TheirLinkPreview({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _Avatar(url: message.avatarUrl),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Canyon image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    message.linkImageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 40),
                    ),
                  ),
                ),
                // Link info box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.linkTitle ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message.linkDomain ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
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
}

// ── My Bubble ─────────────────────────────────────────────────
class _MyBubble extends StatelessWidget {
  final ChatMessage message;
  const _MyBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: const BoxDecoration(
              color: kTeal,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              message.text ?? '',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar Widget ─────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String? url;
  const _Avatar({this.url});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: url != null
          ? Image.network(
        url!,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      )
          : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    width: 36,
    height: 36,
    color: Colors.grey[300],
    child: const Icon(Icons.person, size: 20, color: Colors.grey),
  );
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
            _NavItem(icon: Icons.home, label: 'Home', selected: currentIndex == 0, onTap: () => onTap(0)),
            _NavItem(icon: Icons.favorite_border, label: 'favorite', selected: currentIndex == 1, onTap: () => onTap(1)),
            const SizedBox(width: 48),
            _NavItem(icon: Icons.chat_bubble_outline, label: 'chats', selected: currentIndex == 2, onTap: () => onTap(2)),
            _NavItem(icon: Icons.person, label: 'Profile', selected: currentIndex == 3, onTap: () => onTap(3), showCircle: currentIndex == 3),
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
              : Icon(icon,
              color: selected ? Colors.white : Colors.white.withValues(alpha: 0.6),
              size: 26),
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