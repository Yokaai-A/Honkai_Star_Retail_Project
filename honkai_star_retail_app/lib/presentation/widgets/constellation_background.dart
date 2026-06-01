import 'dart:math';
import 'package:flutter/material.dart';

class ConstellationBackground extends StatefulWidget {
  final Widget child;

  const ConstellationBackground({super.key, required this.child});

  @override
  State<ConstellationBackground> createState() => _ConstellationBackgroundState();
}

class _ConstellationBackgroundState extends State<ConstellationBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];
  final List<Star> _staticStars = []; // List for static background stars
  final Random _random = Random();
  Size _screenSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        _updateStars();
      })..repeat();
  }

  void _initStars(Size size) {
    _stars.clear();
    
    // Stratified Sampling (Grid-based distribution) for moving stars
    // This mathematically prevents clustering (the Poisson clumping effect)
    const int cols = 6;
    const int rows = 6;
    final double cellWidth = size.width / cols;
    final double cellHeight = size.height / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        _stars.add(
          Star(
            position: Offset(
              (c + _random.nextDouble()) * cellWidth,
              (r + _random.nextDouble()) * cellHeight,
            ),
            velocity: Offset(
              (_random.nextDouble() - 0.5) * 0.12, // Slow cosmic drift
              (_random.nextDouble() - 0.5) * 0.12,
            ),
            size: _random.nextDouble() * 2.5 + 1.0,
            opacity: _random.nextDouble() * 0.5 + 0.3,
          ),
        );
      }
    }

    // Stratified Sampling for static background stars (8x8 grid = 64 stars)
    _staticStars.clear();
    const int sCols = 8;
    const int sRows = 8;
    final double sCellWidth = size.width / sCols;
    final double sCellHeight = size.height / sRows;

    for (int r = 0; r < sRows; r++) {
      for (int c = 0; c < sCols; c++) {
        _staticStars.add(
          Star(
            position: Offset(
              (c + _random.nextDouble()) * sCellWidth,
              (r + _random.nextDouble()) * sCellHeight,
            ),
            velocity: Offset.zero,
            size: _random.nextDouble() * 1.0 + 0.2, // Tiny background specs
            opacity: _random.nextDouble() * 0.35 + 0.1,
          ),
        );
      }
    }
  }

  void _updateStars() {
    if (_screenSize == Size.zero) return;
    setState(() {
      for (var star in _stars) {
        star.position += star.velocity;

        // Wrap around screen boundaries
        if (star.position.dx < 0) star.position = Offset(_screenSize.width, star.position.dy);
        if (star.position.dx > _screenSize.width) star.position = Offset(0, star.position.dy);
        if (star.position.dy < 0) star.position = Offset(star.position.dx, _screenSize.height);
        if (star.position.dy > _screenSize.height) star.position = Offset(star.position.dx, 0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final currentSize = Size(constraints.maxWidth, constraints.maxHeight);
        if (_screenSize != currentSize) {
          _screenSize = currentSize;
          _initStars(_screenSize);
        }

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: ConstellationPainter(
                  stars: _stars,
                  staticStars: _staticStars,
                  maxDistance: 110.0,
                ),
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}

class Star {
  Offset position;
  final Offset velocity;
  final double size;
  final double opacity;

  Star({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
  });
}

class ConstellationPainter extends CustomPainter {
  final List<Star> stars;
  final List<Star> staticStars;
  final double maxDistance;

  ConstellationPainter({
    required this.stars,
    this.staticStars = const [],
    required this.maxDistance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Deep Space Solid Background
    final Rect rect = Offset.zero & size;
    final Paint bgPaint = Paint()..color = const Color(0xFF0B1220);
    canvas.drawRect(rect, bgPaint);

    // 2. Draw Static Background Stars (deepest layer)
    final Paint staticStarPaint = Paint()..style = PaintingStyle.fill;
    for (var star in staticStars) {
      staticStarPaint.color = Colors.white.withOpacity(star.opacity);
      canvas.drawCircle(star.position, star.size, staticStarPaint);
    }

    // 3. Draw Stars and Connecting Lines (middle layer)
    final Paint linePaint = Paint()
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    final Paint starPaint = Paint()..style = PaintingStyle.fill;

    // Draw lines first (so they are rendered behind the stars)
    for (int i = 0; i < stars.length; i++) {
      for (int j = i + 1; j < stars.length; j++) {
        final dx = stars[i].position.dx - stars[j].position.dx;
        final dy = stars[i].position.dy - stars[j].position.dy;
        final distance = sqrt(dx * dx + dy * dy);

        if (distance < maxDistance) {
          // Calculate opacity based on distance (closer = more opaque)
          final double alphaFactor = 1.0 - (distance / maxDistance);
          // Set color to faint gold/blue cosmic lines
          linePaint.color = const Color(0xFFD4B375).withOpacity(alphaFactor * 0.25);
          canvas.drawLine(stars[i].position, stars[j].position, linePaint);
        }
      }
    }

    // Draw moving stars (foreground layer)
    for (var star in stars) {
      // Create a glowing star effect
      final glowPaint = Paint()
        ..color = const Color(0xFFD4B375).withOpacity(star.opacity * 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      canvas.drawCircle(star.position, star.size * 2, glowPaint);

      starPaint.color = Colors.white.withOpacity(star.opacity);
      canvas.drawCircle(star.position, star.size, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ConstellationPainter oldDelegate) => true;
}
