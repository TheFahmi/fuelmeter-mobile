import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), brightness: Brightness.light),
      useMaterial3: true,
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: base.appBarTheme.copyWith(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent),
      cardTheme: base.cardTheme.copyWith(
        elevation: 0,
        surfaceTintColor: Colors.white,
        color: Colors.white.withValues(alpha: .9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        backgroundColor: Colors.white.withValues(alpha: .8),
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFEEF2FF),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), brightness: Brightness.dark),
      useMaterial3: true,
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: base.appBarTheme.copyWith(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent),
      cardTheme: base.cardTheme.copyWith(
        elevation: 0,
        surfaceTintColor: Colors.black,
        color: const Color(0xFF0B1220).withValues(alpha: .6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        backgroundColor: const Color(0xFF0B1220).withValues(alpha: .6),
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFF1F2A44),
      ),
    );
  }
}

class Glass extends StatelessWidget {
  const Glass(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: .08)),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface.withValues(alpha: .7),
            Theme.of(context).colorScheme.surface.withValues(alpha: .9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
