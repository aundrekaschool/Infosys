import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Palette
  static const Color _red = Color(0xFFFF2A2A);
  static const Color _darkRed = Color(0xFF8B0000);
  static const Color _nearBlack = Color(0xFF080808);

  // Controllers
  late final AnimationController _intro;
  late final AnimationController _clouds;
  late final AnimationController _grassWind;
  late final AnimationController _titleGlow;
  late final AnimationController _buttonFloat;

  // Anims
  late final Animation<double> _titleFade;
  late final Animation<double> _titleScale;
  late final Animation<double> _houseRise;
  late final Animation<double> _glowIntensity;
  late final Animation<double> _floatAnimation;

  // Music
  late final AudioPlayer _bgm;
  bool _muted = false;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _titleFade = CurvedAnimation(parent: _intro, curve: const Interval(0.0, 0.65, curve: Curves.easeOut));
    _titleScale = Tween(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _intro, curve: const Interval(0.0, 0.65, curve: Curves.elasticOut)),
    );
    _houseRise = CurvedAnimation(parent: _intro, curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic));

    _clouds = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _grassWind = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _titleGlow = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _buttonFloat = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

    _glowIntensity = Tween(begin: 0.3, end: 0.8).animate(CurvedAnimation(parent: _titleGlow, curve: Curves.easeInOut));
    _floatAnimation = Tween(begin: -3.0, end: 3.0).animate(CurvedAnimation(parent: _buttonFloat, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) => _intro.forward());

    // Music
    _bgm = AudioPlayer();
    _bgm.setReleaseMode(ReleaseMode.loop);
    _unawaited(_bgm.setVolume(0.25));
    _unawaited(_bgm.play(AssetSource('opening.mp3')));
  }

  @override
  void dispose() {
    _intro.dispose();
    _clouds.dispose();
    _grassWind.dispose();
    _titleGlow.dispose();
    _buttonFloat.dispose();
    _bgm.dispose();
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
          // Sky gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _red,
                    _darkRed,
                    const Color(0xFF2A0000),
                    const Color(0xFF0A0202),
                    _nearBlack,
                  ],
                  stops: const [0.0, 0.35, 0.58, 0.58, 1.0],
                ),
              ),
            ),
          ),

          // Atmospheric particles
          AnimatedBuilder(
            animation: _clouds,
            builder: (_, __) => _AtmosphericParticles(progress: _clouds.value, screenSize: size),
          ),

          // Cloud shadow
          AnimatedBuilder(
            animation: _clouds,
            builder: (_, __) => _RealisticCloudShadow(
              progress: _clouds.value,
              topFraction: isNarrow ? 0.15 : 0.18,
              screenSize: size,
            ),
          ),

          // Grass layer
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

          // House + shadow
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
                        // Ground shadow ellipse
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
                        // House image
                        Container(
                          constraints: BoxConstraints(maxWidth: isNarrow ? size.width * 1000:2000),
                          decoration: BoxDecoration(
                            boxShadow: [BoxShadow(color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3), blurRadius: 30, spreadRadius: 5)],
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

          // Floating pill buttons
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
                    _EnhancedPillButton(
                      label: 'Activity 1',
                      route: '/a1',
                      delay: 0,
                      base: Color(0xFF5C0B0B),
                      glow: Color(0xFFFF5A5A),
                    ),
                    _EnhancedPillButton(
                      label: 'Activity 2',
                      route: '/a2',
                      delay: 0.25,
                      base: Color(0xFF4A0C14),
                      glow: Color(0xFFFF7A5A),
                    ),
                    _EnhancedPillButton(
                      label: 'Activity 3',
                      route: '/a3',
                      delay: 0.5,
                      base: Color(0xFF3B0E1C),
                      glow: Color(0xFFFF9A6A),
                    ),
                    _EnhancedPillButton(
                      label: 'Activity 4',
                      route: '/a4',
                      delay: 0.75,
                      base: Color(0xFF2D1024),
                      glow: Color(0xFFFFBA7A),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ===== ALL TEXT IN FRONT (added after house/buttons) =====

          // Title + Subheading overlay (front)
          Positioned.fill(
            child: IgnorePointer(
              child: Column(
                children: [
                  SizedBox(height: isNarrow ? 50 : 60),
                  AnimatedBuilder(
                    animation: Listenable.merge([_intro, _titleGlow]),
                    builder: (_, __) => Opacity(
                      opacity: _titleFade.value,
                      child: Transform.scale(
                        scale: _titleScale.value,
                        child: Text(
                          'HOME',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'PlayfairDisplay', // your bundled serif
                            fontSize: 170,
                            letterSpacing: 4,
                            color: Color(0xFF2B0000),
                            fontWeight: FontWeight.w800,
                            height: 0.9,
                            shadows: [
                              Shadow(color: Colors.black87, offset: Offset(3, 3), blurRadius: 8),
                              Shadow(color: Color(0x33FF2A2A), offset: Offset(-2, -2), blurRadius: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Subheading: Poppins, small, large letter spacing
                  Text(
                    'ALL LABORATORY ACTIVITIES',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 8, // large tracking
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),

          // Japanese vertical text — moved closer to center (front)
          Align(
            alignment: const Alignment(-0.75, -0.75), // closer to middle
            child: AnimatedBuilder(
              animation: _titleGlow,
              builder: (_, __) => RotatedBox(
                quarterTurns: 3,
                child: Opacity(
                  opacity: 0.55 + (_glowIntensity.value - 0.3) * 0.25,
                  child: Text(
                    '普通に死ねるなら幸運だ',
                    style: GoogleFonts.poppins( // keeps your current look; swap to a JP serif if desired
                      fontSize: isNarrow ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: const Color(0xFF4A0000),
                      shadows: [
                        Shadow(color: Colors.black.withOpacity(0.6), offset: const Offset(1, 1), blurRadius: 3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Author tag — moved closer to center (front)
          Align(
            alignment: const Alignment(0.75, 0.75), // closer to middle
            child: RotatedBox(
              quarterTurns: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF5A0A0A).withOpacity(0.5), width: 1),
                ),
                child: Text(
                  'BY  AUNDREKA  PEREZ',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF7A1A1A),
                    fontSize: isNarrow ? 12 : 14,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          // Music mute/unmute (front-most control)
          Positioned(
            right: 14,
            top: 14,
            child: _MusicButton(
              muted: _muted,
              onToggle: () async {
                setState(() => _muted = !_muted);
                await _bgm.setVolume(_muted ? 0.0 : 0.25);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// fire-and-forget helper
void _unawaited(Future<void> f) {}

/// ---------- Visual FX ----------

class _AtmosphericParticles extends StatelessWidget {
  final double progress;
  final Size screenSize;

  const _AtmosphericParticles({required this.progress, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(size: screenSize, painter: _ParticlesPainter(progress: progress)),
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
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => oldDelegate.progress != progress;
}

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
          child: CustomPaint(painter: _RealisticCloudShadowPainter()),
        ),
      ),
    );
  }
}

class _RealisticCloudShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25)
      ..color = Colors.black.withOpacity(0.15);
    final denseShadowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15)
      ..color = Colors.black.withOpacity(0.08);

    void cloudBlob(double x, double y, double w, double h, Paint paint) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(h * 0.4)),
        paint,
      );
    }

    final w = size.width;
    final h = size.height;

    cloudBlob(w * 0.1, h * 0.3, w * 0.25, h * 0.25, denseShadowPaint);
    cloudBlob(w * 0.25, h * 0.2, w * 0.3, h * 0.3, shadowPaint);
    cloudBlob(w * 0.45, h * 0.25, w * 0.28, h * 0.28, shadowPaint);
    cloudBlob(w * 0.65, h * 0.35, w * 0.22, h * 0.2, denseShadowPaint);

    // Wispy edges
    cloudBlob(
      w * 0.05,
      h * 0.4,
      w * 0.15,
      h * 0.15,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35)
        ..color = Colors.black.withOpacity(0.05),
    );
    cloudBlob(
      w * 0.8,
      h * 0.45,
      w * 0.18,
      h * 0.12,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35)
        ..color = Colors.black.withOpacity(0.05),
    );

    final fadeShader = LinearGradient(
      colors: [Colors.transparent, Colors.black.withOpacity(0.05), Colors.transparent],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = fadeShader);
  }

  @override
  bool shouldRepaint(covariant _RealisticCloudShadowPainter oldDelegate) => false;
}

class _RealisticGrassPainter extends CustomPainter {
  final double windPhase;
  final double screenWidth;

  static const Color _grassBack = Color(0xFF1A1A1A);
  static const Color _grassMid = Color(0xFF0F0F0F);
  static const Color _grassFront = Color(0xFF000000);

  _RealisticGrassPainter({required this.windPhase, required this.screenWidth});

  @override
  void paint(Canvas canvas, Size size) {
    _paintGrassLayer(canvas, size, 0, _grassBack, 0.9, 2.5);
    _paintGrassLayer(canvas, size, 1, _grassMid, 1.1, 2.0);
    _paintGrassLayer(canvas, size, 2, _grassFront, 1.3, 1.5);
  }

  void _paintGrassLayer(
    Canvas canvas,
    Size size,
    int layerIndex,
    Color baseColor,
    double heightMultiplier,
    double densityMultiplier,
  ) {
    final rng = math.Random(layerIndex * 23 + 17);
    final baseY = size.height;
    final step = 6.0 / densityMultiplier;

    for (double x = -40; x < size.width + 40; x += step + rng.nextDouble() * 3) {
      if (rng.nextDouble() < 0.2) continue;

      final clumpSize = 1 + rng.nextInt(4);
      for (int blade = 0; blade < clumpSize; blade++) {
        final bladeX = x + (blade - clumpSize / 2) * (1.5 + rng.nextDouble() * 2);
        _paintGrassBlade(canvas, size, rng, bladeX, baseY, baseColor, heightMultiplier, layerIndex);
      }
    }
  }

  void _paintGrassBlade(
    Canvas canvas,
    Size size,
    math.Random rng,
    double x,
    double baseY,
    Color baseColor,
    double heightMultiplier,
    int layerIndex,
  ) {
    final height = (25 + rng.nextDouble() * 45) * heightMultiplier;
    final width = 2.0 + rng.nextDouble() * 3.0;

    final windStrength = 0.4 + layerIndex * 0.3;
    final windOffset = math.sin(windPhase + x * 0.008) * windStrength * (height / 35);

    final colorVariation = rng.nextDouble() * 0.2 - 0.1;
    final grassColor = Color.lerp(
      baseColor,
      colorVariation > 0 ? const Color(0xFF2A2A2A) : const Color(0xFF000000),
      colorVariation.abs(),
    )!;

    final paint = Paint()..color = grassColor;

    final path = Path();
    path.moveTo(x - width / 2, baseY);
    const segments = 5;
    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final y = baseY - height * t;
      final segX = x + windOffset * t * t * t;
      final segW = width * (1 - t * 0.8);
      if (i == segments) {
        path.lineTo(segX, y);
      } else {
        path.lineTo(segX - segW / 2, y);
      }
    }
    for (int i = segments - 1; i >= 0; i--) {
      final t = i / segments;
      final y = baseY - height * t;
      final segX = x + windOffset * t * t * t;
      final segW = width * (1 - t * 0.8);
      path.lineTo(segX + segW / 2, y);
    }
    path.close();
    canvas.drawPath(path, paint);

    // subtle edge highlight on the front layer
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
  bool shouldRepaint(covariant _RealisticGrassPainter oldDelegate) => oldDelegate.windPhase != windPhase;
}

/// ---------- Buttons & Controls ----------

class _EnhancedPillButton extends StatefulWidget {
  final String label;
  final String route;
  final double delay;
  final Color base;
  final Color glow;

  const _EnhancedPillButton({
    required this.label,
    required this.route,
    required this.delay,
    required this.base,
    required this.glow,
    super.key,
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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _hover
                        ? [
                            widget.base.withOpacity(0.35),
                            widget.base.withOpacity(0.25),
                            widget.glow.withOpacity(0.35),
                          ]
                        : [
                            widget.base.withOpacity(0.28),
                            widget.base.withOpacity(0.18),
                            widget.base.withOpacity(0.28),
                          ],
                    stops: [
                      (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                      _shimmerAnimation.value.clamp(0.0, 1.0),
                      (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: _hover ? Colors.white.withOpacity(0.65) : Colors.white.withOpacity(0.35),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_hover ? 0.85 : 0.65),
                      blurRadius: _hover ? 26 : 18,
                      spreadRadius: _hover ? -4 : -6,
                      offset: Offset(0, _hover ? 9 : 6),
                    ),
                    BoxShadow(
                      color: widget.glow.withOpacity(_hover ? 0.20 : 0.08),
                      blurRadius: _hover ? 24 : 10,
                      spreadRadius: _hover ? 2 : 0,
                    ),
                  ],
                ),
                child: Text(
                  widget.label,
                  style: GoogleFonts.playfairDisplay(
                    color: _hover ? const Color(0xFFFFFFFF) : const Color(0xFFECECEC),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(color: Colors.black.withOpacity(0.8), offset: const Offset(1, 1), blurRadius: 3),
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

class _MusicButton extends StatelessWidget {
  final bool muted;
  final VoidCallback onToggle;

  const _MusicButton({super.key, required this.muted, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: muted ? 'Unmute' : 'Mute',
      preferBelow: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Material(
          color: Colors.black.withOpacity(0.25),
          child: InkWell(
            onTap: onToggle,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.volume_up_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
