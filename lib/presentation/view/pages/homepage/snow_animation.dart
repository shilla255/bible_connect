import 'dart:math';
import 'package:flutter/material.dart';

class SnowflakesPainter extends CustomPainter {
  final List<Snowflake> snowflakes;
  final double progress;
  final List<Color> festiveColors = [
    Colors.white,
    const Color(0xFFFFD700), // Gold
    const Color(0xFFE6252C), // Christmas Red
    const Color(0xFF34A853), // Christmas Green
  ];

  SnowflakesPainter(this.snowflakes, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (var snowflake in snowflakes) {
      final paint = Paint()
        ..color = festiveColors[snowflake.colorIndex].withOpacity(0.8)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, snowflake.size / 2);

      final position = Offset(
        snowflake.x + sin(progress * 2 * pi + snowflake.y) * snowflake.swayRange,
        (snowflake.y + progress * size.height * snowflake.speed) % size.height,
      );

      // Draw sparkle effect
      if (snowflake.isSparkle) {
        final sparkleSize = snowflake.size * (1 + sin(progress * 4 * pi) * 0.3);
        canvas.drawCircle(position, sparkleSize, paint);

        // Add glow effect
        final glowPaint = Paint()
          ..color = paint.color.withOpacity(0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, snowflake.size * 2);
        canvas.drawCircle(position, snowflake.size * 1.5, glowPaint);
      } else {
        canvas.drawCircle(position, snowflake.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SnowflakesPainter oldDelegate) => true;
}

class Snowflake {
  double x;
  double y;
  double size;
  double speed;
  int colorIndex;
  bool isSparkle;
  double swayRange;

  Snowflake({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.colorIndex,
    required this.isSparkle,
    required this.swayRange,
  });
}

class ChristmasSnowAnimation extends StatefulWidget {
  final Widget child;

  const ChristmasSnowAnimation({
    super.key,
    required this.child,
  });

  @override
  State<ChristmasSnowAnimation> createState() => _ChristmasSnowAnimationState();
}

class _ChristmasSnowAnimationState extends State<ChristmasSnowAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Snowflake> snowflakes;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Create initial snowflakes with more variety
    snowflakes = List.generate(70, (index) => _createSnowflake());
  }

  Snowflake _createSnowflake() {
    final isSparkle = random.nextDouble() < 0.3; // 30% chance of being a sparkle
    return Snowflake(
      x: random.nextDouble() * 400,
      y: random.nextDouble() * 800,
      size: isSparkle ? random.nextDouble() * 4 + 2 : random.nextDouble() * 3 + 1,
      speed: random.nextDouble() * 0.5 + 0.3,
      colorIndex: random.nextInt(4), // Random festive color
      isSparkle: isSparkle,
      swayRange: random.nextDouble() * 3 + 1, // Random sway range for gentle side movement
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            widget.child,
            CustomPaint(
              painter: SnowflakesPainter(snowflakes, _controller.value),
              size: Size.infinite,
            ),
          ],
        );
      },
    );
  }
}