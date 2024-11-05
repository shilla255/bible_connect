import 'dart:math';
import 'package:flutter/material.dart';

class ChristmasTheme extends StatefulWidget {
  final Widget child;

  const ChristmasTheme({
    super.key,
    required this.child,
  });

  @override
  State<ChristmasTheme> createState() => _ChristmasThemeState();
}

class _ChristmasThemeState extends State<ChristmasTheme>
    with TickerProviderStateMixin {
  late final AnimationController _snowController;
  late final AnimationController _twinkleController;
  late final AnimationController _lightsController;
  late final List<Snowflake> snowflakes;
  late final List<Star> stars;
  late final List<Light> lights;
  final Random random = Random();

  @override
  void initState() {
    super.initState();

    // Snow animation
    _snowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Twinkling stars animation
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Christmas lights animation
    _lightsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Initialize elements
    snowflakes = List.generate(40, (index) => _createSnowflake());
    stars = List.generate(20, (index) => _createStar());
    lights = _createLights();
  }

  Snowflake _createSnowflake() {
    return Snowflake(
      x: random.nextDouble() * 400,
      y: random.nextDouble() * 800,
      size: random.nextDouble() * 3 + 1,
      speed: random.nextDouble() * 0.5 + 0.5,
    );
  }

  Star _createStar() {
    return Star(
      x: random.nextDouble() * 400,
      y: random.nextDouble() * 400,
      size: random.nextDouble() * 2 + 1,
    );
  }

  List<Light> _createLights() {
    const spacing = 30.0;
    List<Light> lightsList = [];
    List<Color> christmasColors = [
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.blue,
      Colors.purple,
    ];

    // Create top border lights
    for (double x = 0; x <= 400; x += spacing) {
      lightsList.add(Light(
        x: x,
        y: 0,
        color: christmasColors[random.nextInt(christmasColors.length)],
      ));
    }

    return lightsList;
  }

  @override
  void dispose() {
    _snowController.dispose();
    _twinkleController.dispose();
    _lightsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Festive gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade900.withOpacity(0.3),
                Colors.purple.shade900.withOpacity(0.1),
              ],
            ),
          ),
        ),

        // Twinkling stars
        AnimatedBuilder(
          animation: _twinkleController,
          builder: (context, child) {
            return CustomPaint(
              painter: StarsPainter(stars, _twinkleController.value),
              size: Size.infinite,
            );
          },
        ),

        // Christmas lights
        AnimatedBuilder(
          animation: _lightsController,
          builder: (context, child) {
            return CustomPaint(
              painter: LightsPainter(lights, _lightsController.value),
              size: Size.infinite,
            );
          },
        ),

        // Snowfall
        AnimatedBuilder(
          animation: _snowController,
          builder: (context, child) {
            return CustomPaint(
              painter: SnowflakesPainter(snowflakes, _snowController.value),
              size: Size.infinite,
            );
          },
        ),

        // Main content
        widget.child,
      ],
    );
  }
}

// Painters and supporting classes

class SnowflakesPainter extends CustomPainter {
  final List<Snowflake> snowflakes;
  final double progress;

  SnowflakesPainter(this.snowflakes, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    for (var snowflake in snowflakes) {
      final position = Offset(
        snowflake.x,
        (snowflake.y + progress * size.height * 2) % size.height,
      );
      canvas.drawCircle(position, snowflake.size, paint);
    }
  }

  @override
  bool shouldRepaint(SnowflakesPainter oldDelegate) => true;
}

class StarsPainter extends CustomPainter {
  final List<Star> stars;
  final double progress;

  StarsPainter(this.stars, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow.withOpacity(0.3 + progress * 0.7)
      ..style = PaintingStyle.fill;

    for (var star in stars) {
      canvas.drawCircle(Offset(star.x, star.y), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(StarsPainter oldDelegate) => true;
}

class LightsPainter extends CustomPainter {
  final List<Light> lights;
  final double progress;

  LightsPainter(this.lights, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (var light in lights) {
      final paint = Paint()
        ..color = light.color.withOpacity(0.5 + progress * 0.5)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(Offset(light.x, light.y), 4, paint);

      // Draw light glow
      final glowPaint = Paint()
        ..color = light.color.withOpacity(0.3 * progress)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(Offset(light.x, light.y), 8, glowPaint);
    }
  }

  @override
  bool shouldRepaint(LightsPainter oldDelegate) => true;
}

class Snowflake {
  double x;
  double y;
  double size;
  double speed;

  Snowflake({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}

class Star {
  double x;
  double y;
  double size;

  Star({
    required this.x,
    required this.y,
    required this.size,
  });
}

class Light {
  double x;
  double y;
  Color color;

  Light({
    required this.x,
    required this.y,
    required this.color,
  });
}