import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Paleta principal de Auto-Scan
  static const Color brand = Color(0xFFFF7A00);     // Naranja principal
  static const Color brandDark = Color(0xFFCC6200); // Naranja oscuro
  static const Color bg = Color(0xFFF8F6F4);        // Fondo claro

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      // Esquema de colores basado en nuestro naranja
      colorScheme: ColorScheme.fromSeed(seedColor: brand),
      scaffoldBackgroundColor: bg,

      // Estilo de AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),

      // Estilo de inputs
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: brand, width: 2),
        ),
      ),

      // Estilo de botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }
}
