import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color red = Color(0xFFFF2A2A);
  static const Color darkRed = Color(0xFF8B0000);
  static const Color nearBlack = Color(0xFF080808);
  static const Color titleMaroon = Color(0xFF2B0000);
  static const Color jpText = Color(0xFF4A0000);
}

class AppGradients {
  static LinearGradient sky() => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.red,
          AppColors.darkRed,
          Color(0xFF220000),
          AppColors.nearBlack,
        ],
        stops: [0.0, 0.40, 0.66, 1.0],
      );

  static RadialGradient groundShadowRadial() => RadialGradient(
        colors: [
          Colors.black.withOpacity(0.7),
          Colors.black.withOpacity(0.3),
          Colors.transparent,
        ],
      );

  static LinearGradient pillGradient({
    required bool hover,
    required double stopValue,
    required Color base,
    required Color glow,
  }) {
    final s1 = (stopValue - 0.3).clamp(0.0, 1.0);
    final s2 = stopValue.clamp(0.0, 1.0);
    final s3 = (stopValue + 0.3).clamp(0.0, 1.0);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: hover
          ? [base.withOpacity(0.35), base.withOpacity(0.25), glow.withOpacity(0.35)]
          : [base.withOpacity(0.28), base.withOpacity(0.18), base.withOpacity(0.28)],
      stops: [s1, s2, s3],
    );
  }
}

class AppShadows {
  static List<BoxShadow> houseImageShadow() => [
        BoxShadow(color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3), blurRadius: 30, spreadRadius: 5),
      ];

  static List<BoxShadow> pill({required bool hover, required Color glow}) => [
        BoxShadow(
          color: Colors.black.withOpacity(hover ? 0.85 : 0.65),
          blurRadius: hover ? 26 : 18,
          spreadRadius: hover ? -4 : -6,
          offset: Offset(0, hover ? 9 : 6),
        ),
        BoxShadow(
          color: glow.withOpacity(hover ? 0.20 : 0.08),
          blurRadius: hover ? 24 : 10,
          spreadRadius: hover ? 2 : 0,
        ),
      ];
}

class AppBorders {
  static Border pill({required bool hover}) => Border.all(
        color: hover ? Colors.white.withOpacity(0.65) : Colors.white.withOpacity(0.35),
        width: 1.4,
      );

  static Border authorTagBorder() => Border.all(color: const Color(0xFF5A0A0A).withOpacity(0.5), width: 1);
}

class AppDecorations {
  static BoxDecoration sky() => BoxDecoration(gradient: AppGradients.sky());

  static BoxDecoration groundShadowEllipse() => BoxDecoration(
        borderRadius: BorderRadius.circular(200),
        gradient: AppGradients.groundShadowRadial(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 60,
            spreadRadius: -10,
          ),
        ],
      );

  static BoxDecoration houseImage() => BoxDecoration(boxShadow: AppShadows.houseImageShadow());

  static BoxDecoration authorTag() => BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: AppBorders.authorTagBorder(),
      );

  static BoxDecoration pill({
    required bool hover,
    required double shimmerStop,
    required Color base,
    required Color glow,
  }) =>
      BoxDecoration(
        gradient: AppGradients.pillGradient(hover: hover, stopValue: shimmerStop, base: base, glow: glow),
        borderRadius: BorderRadius.circular(36),
        border: AppBorders.pill(hover: hover),
        boxShadow: AppShadows.pill(hover: hover, glow: glow),
      );
}

class AppTextStyles {
  static double _clamp(double v, double min, double max) => v < min ? min : (v > max ? max : v);

  static TextStyle title(double width) {
    final fs = _clamp(width * 0.14, 72, 170);
    return TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontSize: fs,
      letterSpacing: _clamp(width * 0.003, 2.0, 5.0),
      color: AppColors.titleMaroon,
      fontWeight: FontWeight.w800,
      height: 0.9,
      shadows: const [
        Shadow(color: Colors.black87, offset: Offset(3, 3), blurRadius: 8),
        Shadow(color: Color(0x33FF2A2A), offset: Offset(-2, -2), blurRadius: 12),
      ],
    );
  }

  static TextStyle subheading(double width) => GoogleFonts.poppins(
        fontSize: _clamp(width * 0.014, 12, 18),
        fontWeight: FontWeight.w500,
        letterSpacing: _clamp(width * 0.008, 4, 10),
        color: Colors.white70,
      );

  static TextStyle japanese(bool isNarrow, double opacity, double width) => GoogleFonts.poppins(
        fontSize: isNarrow ? _clamp(width * 0.036, 12, 18) : _clamp(width * 0.018, 14, 20),
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: AppColors.jpText.withOpacity(opacity),
        shadows: [
          Shadow(color: Colors.black.withOpacity(0.6), offset: const Offset(1, 1), blurRadius: 3),
        ],
      );

  static TextStyle authorTag(bool isNarrow, double width) => GoogleFonts.poppins(
        color: const Color(0xFF7A1A1A),
        fontSize: isNarrow ? _clamp(width * 0.03, 10, 14) : _clamp(width * 0.012, 12, 16),
        letterSpacing: 3,
        fontWeight: FontWeight.w700,
      );

  static TextStyle pillButton(bool hover, double width) => GoogleFonts.playfairDisplay(
        color: hover ? const Color(0xFFFFFFFF) : const Color(0xFFECECEC),
        fontSize: _clamp(width * 0.015, 14, 18),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        shadows: [
          Shadow(color: Colors.black.withOpacity(0.8), offset: const Offset(1, 1), blurRadius: 3),
        ],
      );
}
