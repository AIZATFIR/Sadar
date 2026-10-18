import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppPalette — Obsidian Warm Bookpaper & Apple Frosted Glass Aesthetic
class AppPalette {
  // Dark Obsidian & Warm Bookpaper Tones
  static const bg = Color(0xFF18181F);
  static const card = Color(0xFF23222B);
  static const accent = Color(0xFFF0C987); // Warm Bookpaper Amber Gold
  static const text = Color(0xFFF5EBE6); // Warm Cream Text
  static const textDim = Color(0xFFA69F95); // Muted Warm Slate
  static const stroke = Color(0xFF363340); // Soft Obsidian Border
  static const danger = Color(0xFFE5484D); // Conflict / Destructive

  // Bookpaper Journaling Environment Tokens
  static const bookpaperFieldBg = Color(0xFF2B2933);
  static const bookpaperBorder = Color(0xFF403C4B);
  static const bookpaperText = Color(0xFFF4E8D1);

  // Glassmorphism & Apple frosted design tokens
  static const glassSurface = Color(0xF21C1B24); // Frosted Warm Slate
  static const geminiGlassBg = Color(0xE6201F29); // Frosted Obsidian Container
  static const geminiGlassBorder = Color(0x33F0C987); // Soft Gold Frosted Stroke
  static const geminiGlow = Color(0x40F0C987); // Ambient warm gold glow

  // Apple Design & Frosted Glass Tokens
  static const appleGlassBg = Color(0xD91C1C22); // Apple frosted slate surface (sigma 16-24)
  static const appleGlassSurface = Color(0xBF25242E); // Elevated frosted surface
  static const appleGlassBorder = Color(0x14FFFFFF); // 0.5px ultra-delicate light-catching stroke
  static const appleGlassPillBg = Color(0xCC181820); // Translucent floating pill bar
  static const appleGlassPillActive = Color(0x29F0C987); // Warm amber active pill capsule
  static const appleSuccess = Color(0xFF22C55E); // Apple Emerald
  static const appleSuccessGlass = Color(0x1A22C55E); // Translucent emerald tint
  static const appleSuccessBorder = Color(0x4D22C55E); // Delicate emerald stroke

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  // True black (AMOLED)
  static const blackBg = Color(0xFF0C0C0F);
  static const blackCard = Color(0xFF16151A);

  // Light equivalents
  static const lightBg = Color(0xFFF7F3EB); // Soft Sepia Cream Paper
  static const lightCard = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF2B2823);
  static const lightTextDim = Color(0xFF7A746B);
  static const lightStroke = Color(0xFFE6DFC9);
  static const lightAccent = Color(0xFFD49A35);
}

class GeminiMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);

  static const Curve springCurve = Curves.easeOutCubic;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve appleSpring = Curves.easeOutCubic;
}

/// Instant touch feedback widget (scale 0.97 + tactile haptic)
class ApplePressable extends StatefulWidget {
  const ApplePressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleDown = 0.97,
    this.haptic = true,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleDown;
  final bool haptic;
  final BorderRadius? borderRadius;

  @override
  State<ApplePressable> createState() => _ApplePressableState();
}

class _ApplePressableState extends State<ApplePressable> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap != null || widget.onLongPress != null) {
      if (widget.haptic) HapticFeedback.lightImpact();
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (_isPressed) setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (_isPressed) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleDown : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Apple-grade frosted glass container with BackdropFilter & 0.5px delicate border
class AppleFrostedCard extends StatelessWidget {
  const AppleFrostedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 22,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0.5,
    this.blurSigma = 16.0,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double blurSigma;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppPalette.appleGlassBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? AppPalette.appleGlassBorder,
              width: borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return ApplePressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }
    return card;
  }
}

ThemeData buildDarkTheme([String palette = 'executive']) {
  // Default to Obsidian Warm Bookpaper Theme
  Color bg = AppPalette.bg;
  Color card = AppPalette.card;
  Color accent = AppPalette.accent;
  Color stroke = AppPalette.stroke;

  if (palette == 'sage') {
    bg = const Color(0xFF131A17);
    card = const Color(0xFF1C2723);
    accent = const Color(0xFF4EAA86);
    stroke = const Color(0xFF273831);
  } else if (palette == 'full_book' || palette == 'bookpaper' || palette == 'sepia') {
    bg = const Color(0xFF1B1916);
    card = const Color(0xFF26231E);
    accent = const Color(0xFFE2BE82);
    stroke = const Color(0xFF3B352D);
  } else if (palette == 'cream') {
    bg = const Color(0xFF17181F);
    card = const Color(0xFF222430);
    accent = const Color(0xFF8C9EFF);
    stroke = const Color(0xFF2E3244);
  }

  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    scaffoldBackgroundColor: bg,
    colorScheme: base.colorScheme.copyWith(
      surface: bg,
      primary: accent,
      secondary: accent,
      onSurface: AppPalette.text,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: AppPalette.text,
      elevation: 0,
      centerTitle: true,
    ),
    cardColor: card,
    dividerColor: stroke,
    textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
      bodyColor: AppPalette.text,
      displayColor: AppPalette.text,
    ).copyWith(
      displayLarge: const TextStyle(letterSpacing: -1.0, fontWeight: FontWeight.w800),
      displayMedium: const TextStyle(letterSpacing: -0.8, fontWeight: FontWeight.w700),
      displaySmall: const TextStyle(letterSpacing: -0.6, fontWeight: FontWeight.w700),
      headlineLarge: const TextStyle(letterSpacing: -0.6, fontWeight: FontWeight.w700),
      headlineMedium: const TextStyle(letterSpacing: -0.5, fontWeight: FontWeight.w600),
      headlineSmall: const TextStyle(letterSpacing: -0.4, fontWeight: FontWeight.w600),
      titleLarge: const TextStyle(letterSpacing: -0.4, fontWeight: FontWeight.w700),
      titleMedium: const TextStyle(letterSpacing: -0.2, fontWeight: FontWeight.w600),
      titleSmall: const TextStyle(letterSpacing: -0.1, fontWeight: FontWeight.w600),
      bodyLarge: const TextStyle(letterSpacing: -0.1, height: 1.4),
      bodyMedium: const TextStyle(letterSpacing: 0.0, height: 1.4),
      bodySmall: const TextStyle(letterSpacing: 0.1, height: 1.3),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppPalette.appleGlassBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppPalette.appleGlassBorder, width: 0.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.bookpaperFieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppPalette.bookpaperBorder, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppPalette.bookpaperBorder, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppPalette.accent, width: 1.2),
      ),
      hintStyle: const TextStyle(color: AppPalette.textDim, fontSize: 14),
      labelStyle: const TextStyle(color: AppPalette.textDim, fontSize: 13),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: card,
      selectedItemColor: accent,
      unselectedItemColor: AppPalette.textDim,
      type: BottomNavigationBarType.fixed,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: card,
      contentTextStyle: const TextStyle(color: AppPalette.text),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: card,
      indicatorColor: accent.withValues(alpha: 0.22),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
          color: states.contains(WidgetState.selected)
              ? accent
              : AppPalette.textDim,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? accent
              : AppPalette.textDim,
        ),
      ),
    ),
  );
}

/// AMOLED variant: true black background, deep cards.
ThemeData buildBlackTheme() {
  final base = buildDarkTheme();
  return base.copyWith(
    scaffoldBackgroundColor: AppPalette.blackBg,
    colorScheme: base.colorScheme.copyWith(surface: AppPalette.blackBg),
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: AppPalette.blackBg,
    ),
    cardColor: AppPalette.blackCard,
    navigationBarTheme: base.navigationBarTheme.copyWith(
      backgroundColor: AppPalette.blackCard,
    ),
  );
}

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    scaffoldBackgroundColor: AppPalette.lightBg,
    colorScheme: base.colorScheme.copyWith(
      surface: AppPalette.lightBg,
      primary: AppPalette.lightAccent,
      secondary: AppPalette.lightAccent,
      onSurface: AppPalette.lightText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.lightBg,
      foregroundColor: AppPalette.lightText,
      elevation: 0,
      centerTitle: true,
    ),
    cardColor: AppPalette.lightCard,
    dividerColor: AppPalette.lightStroke,
    textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
      bodyColor: AppPalette.lightText,
      displayColor: AppPalette.lightText,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppPalette.lightCard,
      selectedItemColor: AppPalette.lightAccent,
      unselectedItemColor: AppPalette.lightTextDim,
      type: BottomNavigationBarType.fixed,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppPalette.lightCard,
      contentTextStyle: const TextStyle(color: AppPalette.lightText),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppPalette.lightStroke),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.lightStroke),
      ),
      labelStyle: const TextStyle(color: AppPalette.lightTextDim),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppPalette.lightCard,
      indicatorColor: AppPalette.lightAccent.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
          color: states.contains(WidgetState.selected)
              ? AppPalette.lightAccent
              : AppPalette.lightTextDim,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppPalette.lightAccent
              : AppPalette.lightTextDim,
        ),
      ),
    ),
  );
}

/// Full Book / Warm Journal theme with gentle paper aesthetic
ThemeData buildFullBookTheme() {
  return buildDarkTheme('full_book');
}

/// Pastel Book Palette — Eye-Friendly & Relaxing Muted Tones
const pastelBookColors = <int>[
  0xFF8DA399, // Muted Sage Green
  0xFFC89F98, // Dusty Rose
  0xFF9CAAC6, // Soft Periwinkle
  0xFFD6BE93, // Warm Ochre
  0xFFB2A3C4, // Soft Lavender
  0xFFA8B896, // Matcha Tea
  0xFFCFA085, // Soft Terracotta
  0xFF8DB8B2, // Dusty Teal
  0xFFD4B28C, // Muted Sand
  0xFFA69C90, // Warm Slate
];

const presetColors = <int>[
  0xFFF44336, // Red
  0xFFE64A19, // Deep Orange
  0xFFFF9800, // Orange
  0xFFFFC107, // Amber
  0xFFFFEB3B, // Yellow
  0xFFCDDC39, // Lime
  0xFF8BC34A, // Light Green
  0xFF4CAF50, // Green
  0xFF009688, // Teal
  0xFF00BCD4, // Cyan
  0xFF03A9F4, // Light Blue
  0xFF2196F3, // Blue
  0xFF3F51B5, // Indigo
  0xFF673AB7, // Deep Purple
  0xFF9C27B0, // Purple
  0xFFE91E63, // Pink
  0xFF795548, // Brown
];

const presetIcons = <String>[
  '🏃', '💻', '😴', '🍽️', '📚',
  '🏋️', '🎮', '🎵', '🏠', '💆',
  '✍️', '🚗', '🤝', '📞', '🧘',
  '🎨', '🛒', '☕', '🧹', '🎯',
];
