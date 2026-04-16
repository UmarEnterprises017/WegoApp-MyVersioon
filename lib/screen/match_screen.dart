import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

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
      theme: ThemeData(useMaterial3: true),
      home: const MatchPopupScreen(),
    );
  }
}

// ── Colors ────────────────────────────────────────────────────
const Color kPurple = Color(0xFF6B4EFF);
const Color kPink = Color(0xFFE8405A);
const Color kPinkLight = Color(0xFFFFF0F2);
const Color kPinkBtn = Color(0xFFE8405A);

// ── Match Screen ──────────────────────────────────────────────
class MatchPopupScreen extends StatefulWidget {
  const MatchPopupScreen({super.key});

  @override
  State<MatchPopupScreen> createState() => _MatchPopupScreenState();
}

class _MatchPopupScreenState extends State<MatchPopupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: kPurple,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack),
    );
    _slideAnim = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Status bar
          Container(color: kPurple, height: MediaQuery.of(context).padding.top),

          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  children: [
                    // ── Photo Cards section ──
                    Expanded(
                      flex: 6,
                      child: _buildPhotoCards(size),
                    ),

                    // ── Text section ──
                    Expanded(
                      flex: 4,
                      child: _buildBottomSection(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Photo Cards ───────────────────────────────────────────────
  Widget _buildPhotoCards(Size size) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // ── Right card (Jake - man) — tilted right, behind ──
        Positioned(
          top: 30,
          right: size.width * 0.04,
          child: Transform.rotate(
            angle: 8 * math.pi / 180,
            child: _PhotoCard(
              imageUrl:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
              width: size.width * 0.52,
              height: size.height * 0.42,
            ),
          ),
        ),

        // ── Left card (Girl) — tilted left, in front ──
        Positioned(
          top: 55,
          left: size.width * 0.04,
          child: Transform.rotate(
            angle: -6 * math.pi / 180,
            child: _PhotoCard(
              imageUrl:
              'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400',
              width: size.width * 0.50,
              height: size.height * 0.40,
            ),
          ),
        ),

        // ── Top center heart badge ──
        Positioned(
          top: 10,
          child: _HeartBadge(size: 52),
        ),

        // ── Bottom left heart badge ──
        Positioned(
          bottom: 10,
          left: size.width * 0.06,
          child: _HeartBadge(size: 52),
        ),
      ],
    );
  }

  // ── Bottom Section ────────────────────────────────────────────
  Widget _buildBottomSection() {
    return AnimatedBuilder(
      animation: _slideAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnim.value),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Match text
            const Text(
              "It's a match, Jake!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: kPink,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Start a conversation now with each other',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black45,
              ),
            ),

            const SizedBox(height: 32),

            // ── Say Hello button ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPinkBtn,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Say hello',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Keep Swiping button ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPinkLight,
                  foregroundColor: kPink,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Keep swiping',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Photo Card Widget ─────────────────────────────────────────
class _PhotoCard extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  const _PhotoCard({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.person, size: 60, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

// ── Heart Badge Widget ────────────────────────────────────────
class _HeartBadge extends StatelessWidget {
  final double size;
  const _HeartBadge({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.favorite,
        color: kPink,
        size: size * 0.50,
      ),
    );
  }
}