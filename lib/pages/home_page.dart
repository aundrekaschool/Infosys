import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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
    final horizonY = size.height * (isNarrow ? 0.53 : 0.55);

    return Scaffold(
      backgroundColor: AppColors.red,
      body: Stack(
        children: [
          Positioned.fill(child: DecoratedBox(decoration: AppDecorations.sky())),

          AnimatedBuilder(
            animation: _clouds,
            builder: (_, __) => _AtmosphericParticles(progress: _clouds.value, screenSize: size),
          ),

          Positioned(
            left: 0,
            right: 0,
            top: horizonY - (isNarrow ? 70 : 50),
            height: isNarrow ? 160 : 140,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _grassWind,
                builder: (_, __) => CustomPaint(
                  painter: _RealisticGrassPainter(
                    windPhase: _grassWind.value * 2 * math.pi,
                    screenWidth: size.width,
                    densityBoost: isNarrow ? 1.6 : 1.3,
                  ),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment(0, isNarrow ? 0.20 : 0.16),
            child: AnimatedBuilder(
              animation: _intro,
              builder: (_, __) {
                final rise = lerpDouble(80, 0, _houseRise.value)!;
                final opacity = CurvedAnimation(parent: _intro, curve: const Interval(0.35, 1.0, curve: Curves.easeOut)).value;
                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, rise),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IgnorePointer(
                          child: Container(
                            margin: EdgeInsets.only(top: isNarrow ? 220 : 270),
                            width: math.min(size.width * 0.7, 800),
                            height: isNarrow ? 40 : 50,
                            decoration: AppDecorations.groundShadowEllipse(),
                          ),
                        ),
                        Image.asset(
                          'assets/house.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          width: math.min(size.width * 0.9, 2000),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

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
                    _EnhancedPillButton(label: 'Activity 1', route: '/a1', delay: 0, base: Color(0xFF5C0B0B), glow: Color(0xFFFF5A5A)),
                    _EnhancedPillButton(label: 'Activity 2', route: '/a2', delay: 0.25, base: Color(0xFF4A0C14), glow: Color(0xFFFF7A5A)),
                    _EnhancedPillButton(label: 'Activity 3', route: '/a3', delay: 0.5, base: Color(0xFF3B0E1C), glow: Color(0xFFFF9A6A)),
                    _EnhancedPillButton(label: 'Activity 4', route: '/a4', delay: 0.75, base: Color(0xFF2D1024), glow: Color(0xFFFFBA7A)),
                  ],
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: Column(
                children: [
                  SizedBox(height: isNarrow ? 40 : 60),
                  AnimatedBuilder(
                    animation: Listenable.merge([_intro, _titleGlow]),
                    builder: (_, __) => Opacity(
                      opacity: _titleFade.value,
                      child: Transform.scale(
                        scale: _titleScale.value,
                        child: Text('HOME', textAlign: TextAlign.center, style: AppTextStyles.title(size.width)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('ALL LABORATORY ACTIVITIES', textAlign: TextAlign.center, style: AppTextStyles.subheading(size.width)),
                  const Spacer(),
                ],
              ),
            ),
          ),

          Align(
            alignment: isNarrow ? const Alignment(-0.96, -0.82) : const Alignment(-0.78, -0.75),
            child: AnimatedBuilder(
              animation: _titleGlow,
              builder: (_, __) => RotatedBox(
                quarterTurns: 3,
                child: Opacity(
                  opacity: 0.55 + (_glowIntensity.value - 0.3) * 0.25,
                  child: Text('普通に死ねるなら幸運だ', style: AppTextStyles.japanese(isNarrow, 1, size.width)),
                ),
              ),
            ),
          ),

          Align(
            alignment: isNarrow ? const Alignment(0.96, 0.82) : const Alignment(0.78, 0.75),
            child: RotatedBox(
              quarterTurns: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: AppDecorations.authorTag(),
                child: Text('BY  AUNDREKA  PEREZ', style: AppTextStyles.authorTag(isNarrow, size.width)),
              ),
            ),
          ),

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

          AnimatedBuilder(
            animation: _clouds,
            builder: (_, __) => _RealisticCloudShadow(
              progress: _clouds.value,
              topFraction: isNarrow ? 0.13 : 0.18,
              screenSize: size,
            ),
          ),
        ],
      ),
    );
  }
}

void _unawaited(Future<void> f) {}

class _AtmosphericParticles extends StatelessWidget {
  final double progress;
  final Size screenSize;
  const _AtmosphericParticles({required this.progress, required this.screenSize});
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(size: screenSize, painter: _ParticlesPainter(progress: progress)));
  }
}

class _ParticlesPainter extends CustomPainter {
  final double progress;
  _ParticlesPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.1);
    final rng = math.Random(42);
    for (int i = 0; i < 36; i++) {
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
  const _RealisticCloudShadow({required this.progress, required this.topFraction, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    final travelLeft = lerpDouble(-0.8 * screenSize.width, 1.3 * screenSize.width, progress)!;
    final width = math.max(screenSize.width * 1.8, 1600.0);
    final height = screenSize.height * 1.6;
    final top = screenSize.height * topFraction - height * 0.35;

    return Positioned(
      top: top,
      left: travelLeft - width / 2,
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
    final w = size.width;
    final h = size.height;

    final shadowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45)
      ..color = Colors.black.withOpacity(0.35);

    final denseShadowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30)
      ..color = Colors.black.withOpacity(0.28);

    void blob(double x, double y, double bw, double bh, Paint p) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, bw, bh), Radius.circular(bh * 0.4)),
        p,
      );
    }

    blob(w * 0.05, h * 0.15, w * 0.40, h * 0.40, shadowPaint);    
    blob(w * 0.55, h * 0.20, w * 0.48, h * 0.48, denseShadowPaint); 
    blob(w * 1.05, h * 0.18, w * 0.50, h * 0.50, shadowPaint);     


    blob(w * 0.20, h * 0.55, w * 0.30, h * 0.24, Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50)
      ..color = Colors.black.withOpacity(0.15));
    blob(w * 0.70, h * 0.60, w * 0.32, h * 0.24, Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50)
      ..color = Colors.black.withOpacity(0.15));
  }

  @override
  bool shouldRepaint(covariant _RealisticCloudShadowPainter oldDelegate) => false;
}


class _RealisticGrassPainter extends CustomPainter {
  final double windPhase;
  final double screenWidth;
  final double densityBoost;
  static const Color _grassBack = Color(0xFF1A1A1A);
  static const Color _grassMid = Color(0xFF0F0F0F);
  static const Color _grassFront = Color(0xFF000000);
  _RealisticGrassPainter({required this.windPhase, required this.screenWidth, this.densityBoost = 1.0});
  @override
  void paint(Canvas canvas, Size size) {
    _paintGrassLayer(canvas, size, 0, _grassBack, 1.05, 2.8 * densityBoost);
    _paintGrassLayer(canvas, size, 1, _grassMid, 1.25, 2.4 * densityBoost);
    _paintGrassLayer(canvas, size, 2, _grassFront, 1.45, 2.2 * densityBoost);
  }

  void _paintGrassLayer(Canvas canvas, Size size, int layerIndex, Color baseColor, double heightMultiplier, double densityMultiplier) {
    final rng = math.Random(layerIndex * 23 + 17);
    final baseY = size.height;
    final step = 5.0 / densityMultiplier;
    for (double x = -60; x < size.width + 60; x += step + rng.nextDouble() * 2.4) {
      if (rng.nextDouble() < 0.12) continue;
      final clumpSize = 2 + rng.nextInt(5);
      for (int blade = 0; blade < clumpSize; blade++) {
        final bladeX = x + (blade - clumpSize / 2) * (1.2 + rng.nextDouble() * 1.8);
        _paintGrassBlade(canvas, size, rng, bladeX, baseY, baseColor, heightMultiplier, layerIndex);
      }
    }
  }

  void _paintGrassBlade(Canvas canvas, Size size, math.Random rng, double x, double baseY, Color baseColor, double heightMultiplier, int layerIndex) {
    final height = (28 + rng.nextDouble() * 52) * heightMultiplier;
    final width = 1.8 + rng.nextDouble() * 2.6;
    final windStrength = 0.45 + layerIndex * 0.28;
    final windOffset = math.sin(windPhase + x * 0.008) * windStrength * (height / 35);
    final colorVariation = rng.nextDouble() * 0.2 - 0.1;
    final grassColor = Color.lerp(baseColor, colorVariation > 0 ? const Color(0xFF2A2A2A) : const Color(0xFF000000), colorVariation.abs())!;
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

    if (rng.nextDouble() < 0.18 && layerIndex == 2) {
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
  bool shouldRepaint(covariant _RealisticGrassPainter oldDelegate) =>
      oldDelegate.windPhase != windPhase || oldDelegate.densityBoost != densityBoost;
}

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

class _EnhancedPillButtonState extends State<_EnhancedPillButton> with TickerProviderStateMixin {
  bool _hover = false;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    _shimmerAnimation = Tween(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
      if (mounted) _shimmerController.repeat(period: const Duration(seconds: 6));
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
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
            builder: (_, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              decoration: AppDecorations.pill(
                hover: _hover,
                shimmerStop: _shimmerAnimation.value,
                base: widget.base,
                glow: widget.glow,
              ),
              child: Text(widget.label, style: AppTextStyles.pillButton(_hover, width)),
            ),
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
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.volume_up_rounded, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
