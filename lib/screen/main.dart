import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/user_provider.dart';
import '../providers/settings_provider.dart';
import 'welcome_screen.dart'; // ✅

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E5FF6)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Status bar transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Scale animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Animations start karo
    _fadeController.forward();
    _scaleController.forward();

    // ✅ 3 seconds baad WelcomeScreen pe navigate karo
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
            const WelcomeScreen(), // ✅ welcome_screen.dart
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E5FF6),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ===== LOGO =====
                SizedBox(
                  width: 110,
                  height: 110,
                  child: CustomPaint(
                    painter: WeGoLogoPainter(),
                  ),
                ),

                const SizedBox(height: 24),

                // ===== APP NAME =====
                const Text(
                  'WeGo\nMarriage',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 10),

                // ===== TAGLINE =====
                const Text(
                  'Matrimonial App',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
//  Custom Painter — WeGo Logo (Cross + Leaf + Wave)
// ============================================================
class WeGoLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;

    // ----- CROSS / PLUS shape -----
    final double armW = w * 0.30;
    final double cx = w / 2;
    final double cy = h * 0.45;
    final double crossH = h * 0.60;
    final double crossW = w * 0.90;
    final double r = armW / 2;

    RRect vertBar = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: armW, height: crossH),
      Radius.circular(r),
    );
    RRect horizBar = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx, cy - h * 0.05), width: crossW, height: armW),
      Radius.circular(r),
    );

    canvas.drawRRect(vertBar, paint);
    canvas.drawRRect(horizBar, paint);

    // ----- LEAF -----
    final leafPaint = Paint()
      ..color = const Color(0xFF2E5FF6)
      ..style = PaintingStyle.fill;

    final Path leafPath = Path();
    final double lx = cx - w * 0.04;
    final double ly = cy - h * 0.02;

    leafPath.moveTo(lx, ly + h * 0.12);
    leafPath.quadraticBezierTo(
        lx + w * 0.20, ly - h * 0.10, lx + w * 0.22, ly + h * 0.10);
    leafPath.quadraticBezierTo(
        lx + w * 0.10, ly + h * 0.18, lx, ly + h * 0.12);
    leafPath.close();
    canvas.drawPath(leafPath, leafPaint);

    // ----- WAVE underline -----
    final wavePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final Path wavePath = Path();
    final double waveY = h * 0.82;
    final double waveStartX = w * 0.12;
    final double waveEndX = w * 0.88;

    wavePath.moveTo(waveStartX, waveY);
    wavePath.cubicTo(
      waveStartX + (waveEndX - waveStartX) * 0.25, waveY - h * 0.06,
      waveStartX + (waveEndX - waveStartX) * 0.40, waveY + h * 0.06,
      waveStartX + (waveEndX - waveStartX) * 0.55, waveY,
    );
    wavePath.cubicTo(
      waveStartX + (waveEndX - waveStartX) * 0.70, waveY - h * 0.06,
      waveStartX + (waveEndX - waveStartX) * 0.85, waveY + h * 0.04,
      waveEndX, waveY,
    );

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}