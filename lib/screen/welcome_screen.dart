import 'package:flutter/material.dart';
import 'login_screen.dart';           // ✅ Login Screen import
import 'create_account.dart';         // ✅ Sign Up Screen import

// ─────────────────────────────────────────────────────────────
// WELCOME SCREEN
// ─────────────────────────────────────────────────────────────
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Brand colour ─────────────────────────────────────────────
  static const Color kBlue     = Color(0xFF2B52F5);
  static const Color kBlueSoft = Color(0xFFD6DFFE);
  static const Color kBlueMid  = Color(0xFF4169F1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Top spacer ──────────────────────────────
                  const Spacer(flex: 2),

                  // ── Logo mark ───────────────────────────────
                  SizedBox(
                    width: 145,
                    height: 145,
                    child: CustomPaint(painter: _LogoPainter()),
                  ),

                  const SizedBox(height: 18),

                  // ── App name ─────────────────────────────────
                  const Text(
                    'WeGo\nMarriage',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kBlue,
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      height: 1.20,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Subtitle ─────────────────────────────────
                  const Text(
                    'Dermatology Center',
                    style: TextStyle(
                      color: kBlueMid,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),

                  // ── Middle spacer ────────────────────────────
                  const Spacer(flex: 2),

                  // ── Description text ─────────────────────────
                  const Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, '
                        'sed do eiusmod tempor incididunt ut labore et dolore '
                        'magna aliqua.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),

                  // ── Bottom spacer ────────────────────────────
                  const Spacer(flex: 1),

                  // ── Log In button ────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(              // ✅ Login Navigator
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      child: const Text('Log In'),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Sign Up button ───────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(              // ✅ Sign Up Navigator
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateAccountScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBlueSoft,
                        foregroundColor: kBlue,
                        elevation: 0,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      child: const Text('Sign Up'),
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LOGO CUSTOM PAINTER  (cross + leaf + wave)
// ─────────────────────────────────────────────────────────────
class _LogoPainter extends CustomPainter {
  static const Color kBlue = Color(0xFF2B52F5);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final blueFill = Paint()
      ..color = kBlue
      ..style = PaintingStyle.fill;

    // ── 1. CROSS ─────────────────────────────────────────────
    const double armT = 0.27;
    const double r    = armT / 2;
    const double cTop = 0.00;
    const double cBot = 0.70;
    const double cL   = 0.08;
    const double cR   = 0.92;
    const double vL   = 0.50 - armT / 2;
    const double vR   = 0.50 + armT / 2;
    const double hTop = cTop + (cBot - cTop) * 0.22;
    const double hBot = hTop + armT;

    // Vertical bar
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * vL, h * cTop, w * vR, h * cBot,
        Radius.circular(w * r),
      ),
      blueFill,
    );

    // Horizontal bar
    canvas.drawRRect(
      RRect.fromLTRBR(
        w * cL, h * hTop, w * cR, h * hBot,
        Radius.circular(w * r),
      ),
      blueFill,
    );

    // ── 2. LEAF ───────────────────────────────────────────────
    final double lTipX = w * 0.54;
    final double lTipY = h * 0.50;
    final double lBotX = w * 0.47;
    final double lBotY = h * 0.82;

    final Path leaf = Path();
    leaf.moveTo(lTipX, lTipY);
    leaf.cubicTo(
      lTipX + w * 0.24, lTipY + h * 0.10,
      lTipX + w * 0.20, lBotY - h * 0.05,
      lBotX,            lBotY,
    );
    leaf.cubicTo(
      lBotX - w * 0.16, lBotY - h * 0.05,
      lTipX - w * 0.20, lTipY + h * 0.12,
      lTipX,            lTipY,
    );
    leaf.close();
    canvas.drawPath(leaf, blueFill);

    // Leaf spine (white cutout vein)
    final spinePaint = Paint()
      ..color       = Colors.white
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap   = StrokeCap.round;

    final Path spine = Path();
    spine.moveTo(lTipX, lTipY + h * 0.03);
    spine.quadraticBezierTo(
      lTipX - w * 0.05, (lTipY + lBotY) / 2,
      lBotX + w * 0.02, lBotY - h * 0.015,
    );
    canvas.drawPath(spine, spinePaint);

    // ── 3. WAVE ───────────────────────────────────────────────
    final wavePaint = Paint()
      ..color       = kBlue
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap   = StrokeCap.round;

    final double wY  = h * 0.88;
    final double wL  = w * 0.12;
    final double wR  = w * 0.88;
    final double wM  = (wL + wR) / 2;
    final double amp = h * 0.028;

    final Path wave = Path();
    wave.moveTo(wL, wY);
    wave.cubicTo(
      wL + (wM - wL) * 0.35, wY - amp,
      wL + (wM - wL) * 0.65, wY + amp,
      wM, wY,
    );
    wave.cubicTo(
      wM + (wR - wM) * 0.35, wY - amp,
      wM + (wR - wM) * 0.65, wY + amp,
      wR, wY,
    );
    canvas.drawPath(wave, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}