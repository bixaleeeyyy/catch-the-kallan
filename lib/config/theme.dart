/*
 * Impostor MX - Juego de fiesta libre y gratuito
 * Copyright (C) 2026 Retired64 
 *
 * Este programa es software libre: puedes redistribuirlo y/o modificarlo
 * bajo los términos de la Licencia Pública General GNU publicada por
 * la Free Software Foundation, ya sea la versión 3 de la Licencia, o
 * (a tu elección) cualquier versión posterior.
 *
 * Este programa se distribuye con la esperanza de que sea útil,
 * pero SIN NINGUNA GARANTÍA; sin siquiera la garantía implícita de
 * COMERCIABILIDAD o APTITUD PARA UN PROPÓSITO PARTICULAR. Consulta la
 * Licencia Pública General GNU para más detalles.
 *
 * Deberías haber recibido una copia de la Licencia Pública General GNU
 * junto con este programa. Si no es así, consulta <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppColors {
  static const bgTop = Color(0xFF0F2027);
  static const bgBottom = Color(0xFF203A43);
  static const surface = Color(0x1FFFFFFF);
  static const accent = Color(0xFF00F5D4);
  static const error = Color(0xFFFF4B6E);
  static const text = Color(0xFFEEEEEE);
  static const textDim = Color(0xFFAAAAAA);
  static const cardHidden = Color(0xFF2C3E50);
}

class AppTheme {
  // AQUI ES EL CAMBIO PRINCIPAL:

  // Usamos 'Bungee' para títulos grandes
  static TextStyle heading(double size) => TextStyle(
    fontFamily: 'Bungee',
    fontSize: size,
    fontWeight:
        FontWeight.bold, // Bungee ya es bold por defecto, pero esto asegura
    color: AppColors.text,
  );

  // Usamos 'YoungSerif' para texto normal y descripciones
  static TextStyle body(double size) => TextStyle(
    fontFamily: 'YoungSerif',
    fontSize: size,
    color: AppColors.textDim,
  );

  static ThemeData get theme => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.bgTop,

    // Opcional: Define la fuente por defecto para toda la app (Dialogs, TextFields, etc.)
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontFamily: 'YoungSerif'), // Texto general
      titleLarge: TextStyle(fontFamily: 'Bungee'), // Títulos de AppBar, Dialogs
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
      },
    ),
  );
}
