import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de Respawn: fondo oscuro con acento verde lima.
class AppColores {
  static const fondo = Color(0xFF0E0F14);
  static const superficie = Color(0xFF171923);
  static const superficieAlta = Color(0xFF1F2230);
  static const borde = Color(0xFF2A2E3D);

  static const acento = Color(0xFFC6F135); // verde lima
  static const secundario = Color(0xFF3DD6F5); // cian

  static const texto = Color(0xFFEDEDF2);
  static const textoSuave = Color(0xFF8A8FA3);

  static const error = Color(0xFFFF5C5C);
  static const exito = Color(0xFF39D98A);
}

class AppTheme {
  static const String nombreApp = 'RESPAWN';

  /// Letra de títulos (estilo arcade / tecnológico).
  static TextStyle titulo({
    double size = 24,
    Color color = AppColores.texto,
    FontWeight weight = FontWeight.w700,
  }) {
    return GoogleFonts.chakraPetch(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: 0.4,
    );
  }

  static ThemeData get oscuro {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);

        // Se usa solo el nombre de la letra Inter, para no mezclar versiones
    // de TextTheme entre Flutter y el paquete google_fonts.
    final texto = base.textTheme.apply(
      fontFamily: GoogleFonts.inter().fontFamily,
      bodyColor: AppColores.texto,
      displayColor: AppColores.texto,
    );

    final bordeRedondo = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColores.fondo,
      colorScheme: const ColorScheme.dark(
        primary: AppColores.acento,
        onPrimary: AppColores.fondo,
        primaryContainer: Color(0xFF3A4710),
        onPrimaryContainer: AppColores.acento,
        secondary: AppColores.secundario,
        onSecondary: AppColores.fondo,
        secondaryContainer: Color(0xFF13414C),
        onSecondaryContainer: AppColores.secundario,
        surface: AppColores.fondo,
        onSurface: AppColores.texto,
        onSurfaceVariant: AppColores.textoSuave,
        surfaceContainerLowest: AppColores.fondo,
        surfaceContainerLow: AppColores.superficie,
        surfaceContainer: AppColores.superficie,
        surfaceContainerHigh: AppColores.superficieAlta,
        surfaceContainerHighest: AppColores.superficieAlta,
        outline: AppColores.borde,
        outlineVariant: AppColores.borde,
        error: AppColores.error,
        onError: AppColores.fondo,
        inverseSurface: AppColores.texto,
        onInverseSurface: AppColores.fondo,
      ),
      textTheme: texto.copyWith(
        headlineMedium: titulo(size: 28),
        headlineSmall: titulo(size: 24),
        titleLarge: titulo(size: 20),
        titleMedium: texto.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      iconTheme: const IconThemeData(color: AppColores.texto),
      dividerTheme: const DividerThemeData(color: AppColores.borde, space: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColores.acento,
          foregroundColor: AppColores.fondo,
          disabledBackgroundColor: AppColores.superficieAlta,
          disabledForegroundColor: AppColores.textoSuave,
          shape: bordeRedondo,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColores.secundario),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColores.superficieAlta,
        contentTextStyle: GoogleFonts.inter(color: AppColores.texto),
        behavior: SnackBarBehavior.floating,
        shape: bordeRedondo,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColores.superficie,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColores.textoSuave,
        selectedColor: AppColores.acento,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColores.acento,
          selectedForegroundColor: AppColores.fondo,
          foregroundColor: AppColores.texto,
          side: const BorderSide(color: AppColores.borde),
        ),
      ),
    );
  }
}
