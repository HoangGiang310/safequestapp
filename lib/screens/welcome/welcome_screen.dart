import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/widgets/custom_widgets.dart';
import '../auth/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFEBF6FE),
      body: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFEEF8FF),
                Color(0xFFE3F3FE),
                Color(0xFFD8EEFD),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Subtle background cloud decorations
              Positioned(
                top: -30,
                right: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 90,
                left: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Scrollable content with bottom-anchored mascot
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 46),

                        // Top Brand Logo & Slogan
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildHeader(),
                        ),

                        const SizedBox(height: 32),

                        // Action List: "Bắt Đầu" + 3 Feature Cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Column(
                              children: [
                                // Primary "Bắt đầu" button
                                _buildStartButton(context),

                                const SizedBox(height: 14),

                                // 1. Hỗ trợ khẩn cấp
                                _buildFeatureCard(
                                  outerBgColor: const Color(0xFFD5F6EC),
                                  innerColor: const Color(0xFF20B69E),
                                  icon: Icons.shield_rounded,
                                  title: 'Hỗ trợ khẩn cấp',
                                  subtitle:
                                      'Kết nối nhanh với người thân và lực lượng cứu hộ.',
                                ),

                                // 2. Giáo dục kỹ năng
                                _buildFeatureCard(
                                  outerBgColor: const Color(0xFFFEE8C5),
                                  innerColor: const Color(0xFFF7A21E),
                                  icon: Icons.menu_book_rounded,
                                  title: 'Giáo dục kỹ năng',
                                  subtitle:
                                      'Học cách tự bảo vệ bản thân qua các trò chơi thú vị.',
                                ),

                                // 3. Theo dõi an toàn
                                _buildFeatureCard(
                                  outerBgColor: const Color(0xFFFFDCE5),
                                  innerColor: const Color(0xFFFF6384),
                                  icon: Icons.favorite_rounded,
                                  title: 'Theo dõi an toàn',
                                  subtitle:
                                      'Luôn bên bạn trên mọi hành trình.',
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  // Mascot character anchored nicely at the bottom
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: const SizedBox(
                            height: 225,
                            width: double.infinity,
                            child: PenguinMascot(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Top Logo with custom graphics, slogan and smile accent underline
  Widget _buildHeader() {
    return Column(
      children: [
        // "SafeQuest" Logo with Route Trail, 2 Pins & Shield Badge
        FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: 320,
            height: 98,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Dashed route trail across the top
                Positioned.fill(
                  child: CustomPaint(
                    painter: _FlightPathPainter(),
                  ),
                ),

                // Yellow pin above 'a'
                Positioned(
                  left: 52,
                  top: 4,
                  child: Transform.rotate(
                    angle: 0.16,
                    child: const _MapPin(
                      color: Color(0xFFFBB03B),
                      size: 26,
                    ),
                  ),
                ),

                // Blue pin at top right
                Positioned(
                  right: 4,
                  top: -6,
                  child: Transform.rotate(
                    angle: -0.18,
                    child: const _MapPin(
                      color: Color(0xFF2683E2),
                      size: 26,
                    ),
                  ),
                ),

                // "SafeQuest" Main Text
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text(
                            'Safe',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2683E2),
                              letterSpacing: -1.0,
                              height: 1.0,
                            ),
                          ),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Text(
                                'Quest',
                                style: TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFBB03B),
                                  letterSpacing: -1.0,
                                  height: 1.0,
                                ),
                              ),
                              // Shield badge at bottom right of 't'
                              Positioned(
                                right: -16,
                                bottom: -2,
                                child: CustomPaint(
                                  size: const Size(20, 24),
                                  painter: _ShieldBadgePainter(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Slogan: "Khám phá thế giới\nan toàn hơn cùng SafeQuest!"
        Column(
          children: [
            const Text(
              'Khám phá thế giới',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1B72CE),
                fontSize: 18.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'an toàn hơn cùng SafeQuest!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1B72CE),
                fontSize: 18.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 5),
            // Double smile underline accents
            CustomPaint(
              size: const Size(230, 8),
              painter: _DoubleUnderlinePainter(),
            ),
          ],
        ),
      ],
    );
  }

  /// 3D Cartoon "Bắt đầu" button synchronized with app design system
  Widget _buildStartButton(BuildContext context) {
    return PrimaryButton(
      text: 'BẮT ĐẦU',
      height: 56,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
    );
  }

  /// Illustrative feature tile with soft shadow, concentric circular icon, title and subtitle (non-clickable)
  Widget _buildFeatureCard({
    required Color outerBgColor,
    required Color innerColor,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: innerColor.withOpacity(0.35),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: innerColor.withOpacity(0.18),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF1E82E4).withOpacity(0.06),
            offset: const Offset(0, 6),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        children: [
          // Concentric circular icon container
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: outerBgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: innerColor.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: innerColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1E3A56),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF5A758D),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
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

/// Location Map Pin with white center hole
class _MapPin extends StatelessWidget {
  final Color color;
  final double size;

  const _MapPin({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.35),
      painter: _PinPainter(color: color),
    );
  }
}

class _PinPainter extends CustomPainter {
  final Color color;
  _PinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = w / 2;

    final pinPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(r, h);
    path.cubicTo(0, h * 0.65, 0, r * 1.2, 0, r);
    path.arcToPoint(
      Offset(w, r),
      radius: Radius.circular(r),
      clockwise: true,
    );
    path.cubicTo(w, r * 1.2, w, h * 0.65, r, h);
    path.close();

    canvas.drawPath(path, pinPaint);

    // Inner white circular hole
    final holePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(r, r * 0.95), r * 0.44, holePaint);
  }

  @override
  bool shouldRepaint(covariant _PinPainter oldDelegate) => oldDelegate.color != color;
}

/// Dashed light blue flight path connecting the two pins
class _FlightPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF86C3F8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Arc before yellow pin
    path.moveTo(34, 38);
    path.quadraticBezierTo(42, 26, 62, 22);
    // Arch over yellow pin to middle
    path.quadraticBezierTo(95, 18, 134, 25);
    // Gentle dip in middle
    path.lineTo(142, 29);
    path.lineTo(150, 24);
    // Arch across to blue pin
    path.quadraticBezierTo(205, 14, 250, 18);
    path.quadraticBezierTo(275, 20, 296, 12);

    // Draw as dashed line
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      const dashLength = 6.0;
      const gapLength = 5.0;
      while (distance < metric.length) {
        final nextDistance = math.min(distance + dashLength, metric.length);
        final extract = metric.extractPath(distance, nextDistance);
        canvas.drawPath(extract, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Shield badge at bottom right of Quest
class _ShieldBadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final shieldPath = Path();
    shieldPath.moveTo(2, 2);
    shieldPath.lineTo(w - 2, 2);
    shieldPath.quadraticBezierTo(w, h * 0.55, w / 2, h);
    shieldPath.quadraticBezierTo(0, h * 0.55, 2, 2);
    shieldPath.close();

    final shieldPaint = Paint()
      ..color = const Color(0xFF2683E2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shieldPath, shieldPaint);

    // Right half darker blue shading
    final rightShadePath = Path();
    rightShadePath.moveTo(w / 2, 2);
    rightShadePath.lineTo(w - 2, 2);
    rightShadePath.quadraticBezierTo(w, h * 0.55, w / 2, h);
    rightShadePath.close();
    final shadePaint = Paint()
      ..color = const Color(0xFF1B6ECA)
      ..style = PaintingStyle.fill;
    canvas.drawPath(rightShadePath, shadePaint);

    // White emblem inside (four-pointed star)
    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final starPath = Path();
    final cx = w / 2;
    final cy = h * 0.44;
    final rOut = w * 0.30;

    starPath.moveTo(cx, cy - rOut);
    starPath.quadraticBezierTo(cx, cy, cx + rOut, cy);
    starPath.quadraticBezierTo(cx, cy, cx, cy + rOut);
    starPath.quadraticBezierTo(cx, cy, cx - rOut, cy);
    starPath.quadraticBezierTo(cx, cy, cx, cy - rOut);
    starPath.close();

    canvas.drawPath(starPath, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Two smile underline accents under the slogan
class _DoubleUnderlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFBB03B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    // Stroke 1: under "an toàn hơn"
    final path1 = Path();
    path1.moveTo(10, 2);
    path1.quadraticBezierTo(56, 7, 98, 3);
    canvas.drawPath(path1, paint);

    // Stroke 2: under "SafeQuest!"
    final path2 = Path();
    path2.moveTo(140, 3);
    path2.quadraticBezierTo(178, 8, 218, 4);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Graduation Penguin Mascot Widget with Clouds, Mortarboard, and Hearts
class PenguinMascot extends StatelessWidget {
  const PenguinMascot({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PenguinPainter(),
    );
  }
}

class _PenguinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    // 1. Background Soft Clouds and Pastel Green Hill
    _drawBackgroundScenery(canvas, size, cx);

    // 2. Yellow Radiating Joy Rays (upper-right)
    _drawJoyRays(canvas, size, cx);

    // 3. Penguin Head Base (Slate Navy Dome)
    final headRadius = math.min(w * 0.36, 134.0);
    final cy = h * 0.70;

    final headPaint = Paint()
      ..color = const Color(0xFF2B4E7A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), headRadius, headPaint);

    // 4. Three-Part Feather Tuft on top of head
    _drawThreeFeatherTufts(canvas, Offset(cx, cy - headRadius));

    // 5. White Face Mask Patch with chubby cheeks
    _drawFaceMask(canvas, Offset(cx, cy), headRadius);

    // 6. Rosy Blush Cheeks
    final blushPaint = Paint()
      ..color = const Color(0xFFFFB2BC).withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final eyeDistance = headRadius * 0.44;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - eyeDistance * 1.52, cy + headRadius * 0.16),
        width: 36,
        height: 22,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + eyeDistance * 1.52, cy + headRadius * 0.16),
        width: 36,
        height: 22,
      ),
      blushPaint,
    );

    // 7. Eyebrows (Arched cute blue brows)
    final browY = cy - headRadius * 0.28;
    _drawEyebrow(canvas, Offset(cx - eyeDistance, browY), isLeft: true);
    _drawEyebrow(canvas, Offset(cx + eyeDistance, browY), isLeft: false);

    // 8. Cute Anime Eyes (Sparkling blue eyes with dual white reflections)
    _drawEye(canvas, Offset(cx - eyeDistance, cy - headRadius * 0.05), headRadius * 0.24);
    _drawEye(canvas, Offset(cx + eyeDistance, cy - headRadius * 0.05), headRadius * 0.24);

    // 9. Open Smiling Beak with Tongue
    _drawSmilingBeak(canvas, Offset(cx, cy + headRadius * 0.18), headRadius * 0.24);

    // 10. Foreground Sky-Blue Curved Wave Mask
    _drawForegroundWave(canvas, size, cx);
  }

  void _drawBackgroundScenery(Canvas canvas, Size size, double cx) {
    final w = size.width;
    final h = size.height;

    // Pastel mint-green hill on the left
    final greenHillPaint = Paint()
      ..color = const Color(0xFFA2DFCD)
      ..style = PaintingStyle.fill;
    final greenPath = Path();
    greenPath.addOval(Rect.fromCenter(center: Offset(w * 0.08, h * 0.54), width: 75, height: 95));
    canvas.drawPath(greenPath, greenHillPaint);

    // Sky-blue cloud puffs on the left
    final cloudPaint = Paint()
      ..color = const Color(0xFFC4E4FE).withOpacity(0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.14, h * 0.48), 55, cloudPaint);
    canvas.drawCircle(Offset(w * 0.05, h * 0.38), 50, cloudPaint);

    // Sky-blue cloud puff on the right
    canvas.drawCircle(Offset(w * 0.92, h * 0.46), 65, cloudPaint);
  }

  void _drawJoyRays(Canvas canvas, Size size, double cx) {
    final rayPaint = Paint()
      ..color = const Color(0xFFFFAE26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.2
      ..strokeCap = StrokeCap.round;

    final rayOrigin = Offset(cx + 85, size.height * 0.28);

    // Top ray (steep)
    canvas.drawLine(
      Offset(rayOrigin.dx + 8, rayOrigin.dy - 10),
      Offset(rayOrigin.dx + 16, rayOrigin.dy - 32),
      rayPaint,
    );

    // Middle ray (diagonal)
    canvas.drawLine(
      Offset(rayOrigin.dx + 22, rayOrigin.dy + 2),
      Offset(rayOrigin.dx + 42, rayOrigin.dy - 14),
      rayPaint,
    );

    // Bottom ray (horizontal-ish)
    canvas.drawLine(
      Offset(rayOrigin.dx + 26, rayOrigin.dy + 18),
      Offset(rayOrigin.dx + 48, rayOrigin.dy + 16),
      rayPaint,
    );
  }

  void _drawThreeFeatherTufts(Canvas canvas, Offset center) {
    final tuftPaint = Paint()
      ..color = const Color(0xFF26456E)
      ..style = PaintingStyle.fill;

    void drawLobe(Offset pos, double angle, double length, double width) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle);
      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -length / 2), width: width, height: length),
        Radius.circular(width / 2),
      );
      canvas.drawRRect(rrect, tuftPaint);
      canvas.restore();
    }

    // Left petal
    drawLobe(Offset(center.dx - 8, center.dy + 4), -0.45, 18, 12);
    // Right petal
    drawLobe(Offset(center.dx + 8, center.dy + 4), 0.45, 18, 12);
    // Center petal
    drawLobe(Offset(center.dx, center.dy + 2), 0.0, 22, 13);
  }

  void _drawFaceMask(Canvas canvas, Offset center, double headRadius) {
    final facePaint = Paint()
      ..color = const Color(0xFFFCFEFF)
      ..style = PaintingStyle.fill;

    final cx = center.dx;
    final cy = center.dy;
    final eyeDistance = headRadius * 0.44;
    final browRadius = headRadius * 0.38;
    final browY = cy - headRadius * 0.12;

    final facePath = Path();
    facePath.addOval(Rect.fromCircle(
      center: Offset(cx - eyeDistance, browY),
      radius: browRadius,
    ));
    facePath.addOval(Rect.fromCircle(
      center: Offset(cx + eyeDistance, browY),
      radius: browRadius,
    ));
    facePath.addOval(Rect.fromCenter(
      center: Offset(cx, cy + headRadius * 0.18),
      width: headRadius * 1.56,
      height: headRadius * 0.98,
    ));
    facePath.addOval(Rect.fromCircle(
      center: Offset(cx - headRadius * 0.58, cy + headRadius * 0.18),
      radius: headRadius * 0.28,
    ));
    facePath.addOval(Rect.fromCircle(
      center: Offset(cx + headRadius * 0.58, cy + headRadius * 0.18),
      radius: headRadius * 0.28,
    ));

    canvas.drawPath(facePath, facePaint);
  }

  void _drawEyebrow(Canvas canvas, Offset center, {required bool isLeft}) {
    final paint = Paint()
      ..color = const Color(0xFF284D78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final dx = center.dx;
    final dy = center.dy;

    if (isLeft) {
      path.moveTo(dx - 12, dy + 2);
      path.quadraticBezierTo(dx - 1, dy - 8, dx + 12, dy);
    } else {
      path.moveTo(dx - 12, dy);
      path.quadraticBezierTo(dx + 1, dy - 8, dx + 12, dy + 2);
    }

    canvas.drawPath(path, paint);
  }

  void _drawEye(Canvas canvas, Offset center, double radius) {
    final eyeWidth = radius * 1.25;
    final eyeHeight = radius * 1.58;

    final eyeRect = Rect.fromCenter(
      center: center,
      width: eyeWidth,
      height: eyeHeight,
    );

    // Deep blue gradient iris
    final irisPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0E233F),
          Color(0xFF1B60AA),
          Color(0xFF2575D2),
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(eyeRect);

    canvas.drawOval(eyeRect, irisPaint);

    // Bright cyan/sky-blue lower crescent shimmer
    final crescentPaint = Paint()
      ..color = const Color(0xFF5AB6FF)
      ..style = PaintingStyle.fill;
    final crescentRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + eyeHeight * 0.24),
      width: eyeWidth * 0.78,
      height: eyeHeight * 0.38,
    );
    canvas.drawOval(crescentRect, crescentPaint);

    // Big top-right white sparkle
    final sparklePaint = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + eyeWidth * 0.15, center.dy - eyeHeight * 0.16),
        width: eyeWidth * 0.44,
        height: eyeHeight * 0.48,
      ),
      sparklePaint,
    );

    // Small bottom-left white sparkle
    canvas.drawCircle(
      Offset(center.dx - eyeWidth * 0.20, center.dy + eyeHeight * 0.20),
      eyeWidth * 0.14,
      sparklePaint,
    );
  }

  void _drawSmilingBeak(Canvas canvas, Offset center, double size) {
    final w = size * 1.25;
    final h = size * 0.85;

    // 1. Open mouth cavity (behind upper beak)
    final mouthPath = Path();
    mouthPath.moveTo(center.dx - w * 0.35, center.dy + 2);
    mouthPath.quadraticBezierTo(center.dx, center.dy + h, center.dx + w * 0.35, center.dy + 2);
    mouthPath.close();

    final mouthPaint = Paint()
      ..color = const Color(0xFFA32828)
      ..style = PaintingStyle.fill;
    canvas.drawPath(mouthPath, mouthPaint);

    // 2. Tongue inside
    final tonguePaint = Paint()
      ..color = const Color(0xFFFF8595)
      ..style = PaintingStyle.fill;
    final tongueRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + h * 0.55),
      width: w * 0.46,
      height: h * 0.48,
    );
    canvas.save();
    canvas.clipPath(mouthPath);
    canvas.drawOval(tongueRect, tonguePaint);
    canvas.restore();

    // 3. Upper beak (golden-yellow rounded triangle/pill)
    final upperBeakPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFB836), Color(0xFFFFA01E)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCenter(center: center, width: w, height: h * 0.6))
      ..style = PaintingStyle.fill;

    final upperPath = Path();
    upperPath.moveTo(center.dx - w * 0.50, center.dy - 2);
    upperPath.quadraticBezierTo(center.dx, center.dy - 6, center.dx + w * 0.50, center.dy - 2);
    upperPath.quadraticBezierTo(center.dx, center.dy + h * 0.38, center.dx - w * 0.50, center.dy - 2);
    upperPath.close();

    canvas.drawPath(upperPath, upperBeakPaint);
  }

  void _drawForegroundWave(Canvas canvas, Size size, double cx) {
    final w = size.width;
    final h = size.height;

    final wavePaint = Paint()
      ..color = const Color(0xFF8DC4FA)
      ..style = PaintingStyle.fill;

    final wavePath = Path();
    wavePath.moveTo(0, h * 0.62);
    wavePath.quadraticBezierTo(cx * 0.45, h * 0.72, cx, h * 0.74);
    wavePath.quadraticBezierTo(cx * 1.55, h * 0.72, w, h * 0.62);
    wavePath.lineTo(w, h);
    wavePath.lineTo(0, h);
    wavePath.close();

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
