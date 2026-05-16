import 'package:flutter/material.dart';

class AppColors {
  // ── Primary Brand ─────────────────────────────────────────────────────────
  static const Color primaryGreen     = Color(0xFF2E9900); // brand utama
  static const Color primaryGreenDark = Color(0xFF1F6B00); // hover / gradient gelap
  static const Color primaryGreenMid  = Color(0xFF3DB800); // gradient tengah
  static const Color primaryGreenAcc  = Color(0xFF5CC400); // aksen cerah

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color primaryRed       = Color(0xFFD32F2F); // error / hapus
  static const Color primaryRedLight  = Color(0xFFFFEBEB); // background error
  static const Color warning          = Color(0xFFF59E0B); // stok hampir habis
  static const Color warningLight     = Color(0xFFFEF3C7);
  static const Color success          = Color(0xFF2E9900);
  static const Color successLight     = Color(0xFFE8F5E2);

  // ── Neutral ───────────────────────────────────────────────────────────────
  static const Color backgroundLight  = Color(0xFFF4FAF2); // bg hijau sangat muda
  static const Color backgroundWhite  = Color(0xFFFFFFFF);
  static const Color backgroundCard   = Color(0xFFFFFFFF);
  static const Color surfaceGrey      = Color(0xFFF7F7F7);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textDark         = Color(0xFF1A2E1A); // hampir hitam, nuansa hijau
  static const Color textMedium       = Color(0xFF3D553D);
  static const Color textLight        = Color(0xFF8A9E8A);
  static const Color textHint         = Color(0xFFB0C4B0);

  // ── Border / Divider ──────────────────────────────────────────────────────
  static const Color inputBorder      = Color(0xFFDFEFDF);
  static const Color inputBackground  = Color(0xFFFFFFFF);
  static const Color divider          = Color(0xFFF0F4F0);
  static const Color cardBorder       = Color(0xFFEEF5EE);

  // ── Shadow ────────────────────────────────────────────────────────────────
  static const Color shadowGreen      = Color(0x142E9900); // ~8% opacity green
  static const Color shadowBlack      = Color(0x0D000000); // ~5% opacity black

  // ── Gradient Presets ──────────────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primaryGreenDark, primaryGreen, primaryGreenAcc],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGreenGradient = LinearGradient(
    colors: [Color(0xFFE8F5E2), Color(0xFFF4FAF2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Helper: BoxShadow standar ─────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: shadowBlack,
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get greenShadow => [
        BoxShadow(
          color: shadowGreen,
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];
}