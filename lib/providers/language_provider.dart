/*
 * Impostor MX - Juego de fiesta libre y gratuito
 * Copyright (C) 2026 Retired64
 */

import 'package:flutter/material.dart';
import '../lang/en.dart';

/// English-only version. The same functions are kept so the rest of the app works unchanged.
class LanguageProvider extends ChangeNotifier {
  String get currentLanguage => 'en';

  Future<void> setLanguage(String langCode) async {}

  String translate(String key) => en[key] ?? key;
}
