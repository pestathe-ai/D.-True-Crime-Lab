import 'package:flutter/material.dart';

/// Palette: nero e giallo da scena del crimine, struttura Dom.
class Pal {
  static const bg = Color(0xFF0E0F14);
  static const surface = Color(0xFF17191F);
  static const surface2 = Color(0xFF20232B);
  static const line = Color(0xFF2E323C);
  static const text = Color(0xFFECE6DA);
  static const muted = Color(0xFF8C94AA);
  static const accent = Color(0xFFFFD21F);
  static const blue = Color(0xFF1D3A8A);
  static const blueLight = Color(0xFF4F6FD6);
  static const paper = Color(0xFFFFF8F0);
  static const inkDark = Color(0xFF111114);
}

TextStyle sora(double size, {double weight = 600, Color? color}) {
  return TextStyle(
    fontFamily: 'Sora',
    fontSize: size,
    fontWeight: weight >= 700
        ? FontWeight.w800
        : (weight >= 500 ? FontWeight.w600 : FontWeight.w400),
    fontVariations: [FontVariation('wght', weight)],
    color: color ?? Pal.text,
    height: 1.2,
  );
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Pal.blue,
    brightness: Brightness.dark,
  ).copyWith(
    primary: Pal.accent,
    onPrimary: Pal.inkDark,
    secondary: Pal.blueLight,
    surface: Pal.surface,
    onSurface: Pal.text,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Pal.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Pal.bg,
      foregroundColor: Pal.text,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Pal.surface,
      indicatorColor: Pal.accent.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, color: Pal.text),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? Pal.accent : Pal.muted,
        ),
      ),
    ),
    dividerColor: Pal.line,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Pal.surface2,
      contentTextStyle: TextStyle(color: Pal.text),
      behavior: SnackBarBehavior.floating,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Pal.accent : Pal.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? Pal.accent.withValues(alpha: 0.35)
            : Pal.surface2,
      ),
    ),
  );
}

/// Firma del marchio, in fondo alle schermate principali.
class DomSignature extends StatelessWidget {
  const DomSignature({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          'un\'app Dom Studio',
          style: sora(11, weight: 400, color: Pal.muted),
        ),
      ),
    );
  }
}
