import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Enhanced color palette
  static const Color _red = Color(0xFFFF2A2A);
  static const Color _darkRed = Color(0xFF8B0000);
  static const Color _nearBlack = Color(0xFF080808);
  static const Color _grassGreen = Color(0xFF1B4D1B);
  static const Color _darkGrass = Color(0xFF0F2F0F);

  late final AnimationController _intro;
  late final AnimationController _clouds;
  late final AnimationController _grassWind;
  late final AnimationController _titleGlow;
  late final AnimationController _buttonFloat;

  late final Animation<double> _titleFade;
  late final Animation<double> _titleScale;
  late final Animation<double> _houseRise;
  late final Animation<double> _glowIntensity;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _titleFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );
    _titleScale = Tween(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
      ),
    );
    _houseRise = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic),
    );

    _clouds = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _grassWind = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _titleGlow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _buttonFloat = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _glowIntensity = Tween(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _titleGlow, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _buttonFloat, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _intro.forward());
  }

  @override
  void dispose() {
    _intro.dispose();
    _clouds.dispose();
    _grassWind.dispose();
    _titleGlow.dispose();
    _buttonFloat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isNarrow = size.width < 900;
    final horizonY = size.height * 0.58;

    return Scaffold(
      backgroundColor: _red,
      body: Stack(
        children: [
          // Enhanced gradient sky with atmospheric layers
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _red,
                    _darkRed,
                    const Color(0xFF2D0000),
                    _nearBlack,
                    _nearBlack,
                  ],
                  stops: const [0.0, 0.35, 0.58, 0.58, 1.0],
                ),
              ),
            ),
          ),

          // Atmospheric particles/dust motes
          AnimatedBuilder(
            animation: _clouds,
            builder: (_, __) => _AtmosphericParticles(
              progress: _clouds.value,
              screenSize: size,
            ),
          ),

          // Enhanced cloud shadow with more realistic shape
          AnimatedBuilder(
            animation: _clouds,
            builder: (_, __) => _RealisticCloudShadow(
              progress: _clouds.value,
              topFraction: isNarrow ? 0.15 : 0.18,
              screenSize: size,
            ),
          ),

          // Enhanced grass with multiple layers and realistic appearance
          Positioned(
            left: 0,
            right: 0,
            top: horizonY - 30,
            height: 100,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _grassWind,
                builder: (_, __) => CustomPaint(
                  painter: _RealisticGrassPainter(
                    windPhase: _grassWind.value * 2 * math.pi,
                    screenWidth: size.width,
                  ),
                ),
              ),
            ),
          ),

          // Enhanced "HOME" title with glow effect
          Align(
            alignment: Alignment(0, isNarrow ? -0.75 : -0.72),
            child: AnimatedBuilder(
              animation: Listenable.merge([_intro, _titleGlow]),
              builder: (_, __) {
                return Opacity(
                  opacity: _titleFade.value,
                  child: Transform.scale(
                    scale: _titleScale.value,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B0000).withOpacity(_glowIntensity.value * 0.6),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                          BoxShadow(
                            color: _red.withOpacity(_glowIntensity.value * 0.3),
                            blurRadius: 80,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                      child: Text(
                        'HOME',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isNarrow ? 120 : 180,
                          letterSpacing: 6,
                          color: const Color(0xFF3C0000),
                          fontWeight: FontWeight.w900,
                          height: 0.9,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              offset: const Offset(3, 3),
                              blurRadius: 8,
                            ),
                            Shadow(
                              color: _red.withOpacity(0.4),
                              offset: const Offset(-2, -2),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Enhanced Japanese text with subtle animation
          Positioned(
            left: 28,
            top: size.height * 0.10,
            child: AnimatedBuilder(
              animation: _titleGlow,
              builder: (_, __) => RotatedBox(
                quarterTurns: 3,
                child: Opacity(
                  opacity: 0.45 + (_glowIntensity.value - 0.3) * 0.3,
                  child: Text(
                    '普通に死ねるなら幸運だ',
                    style: TextStyle(
                      color: const Color(0xFF4A0000),
                      fontSize: isNarrow ? 17 : 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.6),
                          offset: const Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Enhanced author tag
          Positioned(
            right: 20,
            bottom: size.height * 0.16,
            child: RotatedBox(
              quarterTurns: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF5A0A0A).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  'BY  AUNDREKA  PEREZ',
                  style: TextStyle(
                    color: const Color(0xFF7A1A1A),
                    fontSize: isNarrow ? 12 : 14,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          // Enhanced house with better shadow and lighting
          Align(
            alignment: Alignment(0, isNarrow ? 0.20 : 0.16),
            child: AnimatedBuilder(
              animation: _intro,
              builder: (_, __) {
                final rise = lerpDouble(80, 0, _houseRise.value)!;
                final opacity = CurvedAnimation(
                  parent: _intro,
                  curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
                ).value;

                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, rise),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Enhanced ground shadow
                        IgnorePointer(
                          child: Container(
                            margin: EdgeInsets.only(top: isNarrow ? 220 : 270),
                            width: math.min(size.width * 0.7, 800),
                            height: isNarrow ? 40 : 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(200),
                              gradient: RadialGradient(
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 60,
                                  spreadRadius: -10,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // House with atmospheric lighting
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: isNarrow ? size.width * 0.92 : 980,
                          ),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: _red.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/house.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Enhanced floating pill buttons
          Align(
            alignment: const Alignment(0, 0.88),
            child: AnimatedBuilder(
              animation: _buttonFloat,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 32,
                  runSpacing: 20,
                  children: const [
                    _EnhancedPillButton(label: 'Chapter 1', route: '/a1', delay: 0),
                    _EnhancedPillButton(label: 'Chapter 2', route: '/a2', delay: 0.25),
                    _EnhancedPillButton(label: 'Chapter 3', route: '/a3', delay: 0.5),
                    _EnhancedPillButton(label: 'Chapter 4', route: '/a4', delay: 0.75),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Atmospheric particles floating in the air
class _AtmosphericParticles extends StatelessWidget {
  final double progress;
  final Size screenSize;

  const _AtmosphericParticles({
    required this.progress,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: screenSize,
        painter: _ParticlesPainter(progress: progress),
      ),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final double progress;

  _ParticlesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.1);
    final rng = math.Random(42);

    for (int i = 0; i < 30; i++) {
      final x = (rng.nextDouble() * size.width + progress * 20) % size.width;
      final y = rng.nextDouble() * size.height * 0.6;
      final radius = 0.5 + rng.nextDouble() * 1.5;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// More realistic cloud shadow with proper cloud-like shape
class _RealisticCloudShadow extends StatelessWidget {
  final double progress;
  final double topFraction;
  final Size screenSize;

  const _RealisticCloudShadow({
    required this.progress,
    required this.topFraction,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final left = lerpDouble(-0.7 * screenSize.width, 1.2 * screenSize.width, progress)!;
    final width = math.max(screenSize.width * 0.8, 800.0);
    final height = math.max(screenSize.height * 0.3, 200.0);

    return Positioned(
      top: screenSize.height * topFraction,
      left: left - width / 2,
      child: IgnorePointer(
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: _RealisticCloudShadowPainter(),
          ),
        ),
      ),
    );
  }
}

class _RealisticCloudShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Create a more realistic cloud shadow with varied opacity
    final shadowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25)
      ..color = Colors.black.withOpacity(0.15);

    final denseShadowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15)
      ..color = Colors.black.withOpacity(0.08);

    void cloudBlob(double x, double y, double w, double h, Paint paint) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, w, h),
          Radius.circular(h * 0.4),
        ),
        paint,
      );
    }

    final w = size.width;
    final h = size.height;

    // Main cloud body with varied density
    cloudBlob(w * 0.1, h * 0.3, w * 0.25, h * 0.25, denseShadowPaint);
    cloudBlob(w * 0.25, h * 0.2, w * 0.3, h * 0.3, shadowPaint);
    cloudBlob(w * 0.45, h * 0.25, w * 0.28, h * 0.28, shadowPaint);
    cloudBlob(w * 0.65, h * 0.35, w * 0.22, h * 0.2, denseShadowPaint);
    
    // Wispy edges
    cloudBlob(w * 0.05, h * 0.4, w * 0.15, h * 0.15, Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35)
      ..color = Colors.black.withOpacity(0.05));
    cloudBlob(w * 0.8, h * 0.45, w * 0.18, h * 0.12, Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35)
      ..color = Colors.black.withOpacity(0.05));

    // Gradient fade for natural look
    final fadeShader = LinearGradient(
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..shader = fadeShader,
    );
  }

  @override
  bool shouldRepaint(covariant _RealisticCloudShadowPainter oldDelegate) => false;
}

/// Realistic grass painter with multiple layers and natural variation
class _RealisticGrassPainter extends CustomPainter {
  final double windPhase;
  final double screenWidth;

  // Black grass colors for silhouette effect
  static const Color _grassBack = Color(0xFF1A1A1A);
  static const Color _grassMid = Color(0xFF0F0F0F);
  static const Color _grassFront = Color(0xFF000000);

  _RealisticGrassPainter({
    required this.windPhase,
    required this.screenWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Multiple grass layers for depth with black silhouette
    _paintGrassLayer(canvas, size, 0, _grassBack, 0.9, 2.5); // Back layer - lighter black
    _paintGrassLayer(canvas, size, 1, _grassMid, 1.1, 2.0); // Mid layer - medium black
    _paintGrassLayer(canvas, size, 2, _grassFront, 1.3, 1.5); // Front layer - pure black
  }

  void _paintGrassLayer(Canvas canvas, Size size, int layerIndex, Color baseColor, 
                       double heightMultiplier, double densityMultiplier) {
    final rng = math.Random(layerIndex * 23 + 17);
    final baseY = size.height;
    final step = 6.0 / densityMultiplier;
    
    for (double x = -40; x < size.width + 40; x += step + rng.nextDouble() * 3) {
      // More varied spacing for natural look
      if (rng.nextDouble() < 0.2) continue;
      
      final clumpSize = 1 + rng.nextInt(4); // Larger clumps
      
      for (int blade = 0; blade < clumpSize; blade++) {
        final bladeX = x + (blade - clumpSize / 2) * (1.5 + rng.nextDouble() * 2);
        _paintGrassBlade(canvas, size, rng, bladeX, baseY, baseColor, 
                        heightMultiplier, layerIndex);
      }
    }
  }

  void _paintGrassBlade(Canvas canvas, Size size, math.Random rng, double x, 
                       double baseY, Color baseColor, double heightMultiplier, int layerIndex) {
    final height = (25 + rng.nextDouble() * 45) * heightMultiplier;
    final width = 2.0 + rng.nextDouble() * 3.0;
    
    // Enhanced wind effect with more dramatic movement
    final windStrength = 0.4 + layerIndex * 0.3;
    final windOffset = math.sin(windPhase + x * 0.008) * windStrength * 
                      (height / 35); // More dramatic bend
    
    // Subtle color variation within black spectrum
    final colorVariation = rng.nextDouble() * 0.2 - 0.1;
    final grassColor = Color.lerp(baseColor, 
        colorVariation > 0 ? const Color(0xFF2A2A2A) : const Color(0xFF000000), 
        colorVariation.abs())!;
    
    final paint = Paint()
      ..color = grassColor
      ..style = PaintingStyle.fill;
    
    // Create more dramatic grass blade shape
    final path = Path();
    
    // Base of blade - wider for better silhouette
    path.moveTo(x - width / 2, baseY);
    
    // Main stem with enhanced wind bend
    final segments = 5;
    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final segmentY = baseY - height * t;
      final segmentX = x + windOffset * t * t * t; // Cubic bend for more natural look
      final segmentWidth = width * (1 - t * 0.8); // More dramatic taper
      
      if (i == segments) {
        // Sharp tip
        path.lineTo(segmentX, segmentY);
      } else {
        // Side of blade
        path.lineTo(segmentX - segmentWidth / 2, segmentY);
      }
    }
    
    // Other side back down
    for (int i = segments - 1; i >= 0; i--) {
      final t = i / segments;
      final segmentY = baseY - height * t;
      final segmentX = x + windOffset * t * t * t;
      final segmentWidth = width * (1 - t * 0.8);
      
      path.lineTo(segmentX + segmentWidth / 2, segmentY);
    }
    
    path.close();
    canvas.drawPath(path, paint);
    
    // Add subtle edge highlight for depth (very subtle on black grass)
    if (rng.nextDouble() < 0.15 && layerIndex == 2) {
      final edgePaint = Paint()
        ..color = const Color(0xFF333333).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      
      canvas.drawLine(
        Offset(x + width / 3, baseY),
        Offset(x + windOffset * 0.8 + width / 3, baseY - height * 0.8),
        edgePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RealisticGrassPainter oldDelegate) {
    return oldDelegate.windPhase != windPhase;
  }
}

/// Enhanced pill button with better animations and effects
class _EnhancedPillButton extends StatefulWidget {
  final String label;
  final String route;
  final double delay;

  const _EnhancedPillButton({
    required this.label,
    required this.route,
    required this.delay,
  });

  @override
  State<_EnhancedPillButton> createState() => _EnhancedPillButtonState();
}

class _EnhancedPillButtonState extends State<_EnhancedPillButton>
    with TickerProviderStateMixin {
  bool _hover = false;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _shimmerAnimation = Tween(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    
    // Stagger the shimmer effect
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
      if (mounted) {
        _shimmerController.repeat(period: const Duration(seconds: 6));
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(_hover ? 1.08 : 1.0),
          child: AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _hover
                        ? [
                            const Color(0x44FFFFFF),
                            const Color(0x22FFFFFF),
                            const Color(0x44FFFFFF),
                          ]
                        : [
                            const Color(0x33000000),
                            const Color(0x22000000),
                            const Color(0x33000000),
                          ],
                    stops: [
                      (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                      _shimmerAnimation.value.clamp(0.0, 1.0),
                      (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: _hover
                        ? Colors.white.withOpacity(0.6)
                        : Colors.white.withOpacity(0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_hover ? 0.8 : 0.6),
                      blurRadius: _hover ? 25 : 18,
                      spreadRadius: _hover ? -4 : -6,
                      offset: Offset(0, _hover ? 8 : 6),
                    ),
                    if (_hover)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: -8,
                        offset: const Offset(0, -4),
                      ),
                  ],
                ),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: _hover ? const Color(0xFFFFFFFF) : const Color(0xFFE0E0E0),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.8),
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}