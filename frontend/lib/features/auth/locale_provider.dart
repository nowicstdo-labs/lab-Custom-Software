import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _prefsKey = 'selected_language_code';

  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_prefsKey);
      if (languageCode != null) {
        state = Locale(languageCode);
      }
    } catch (_) {
      // Fallback to default English
    }
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, languageCode);
    } catch (_) {
      // Fail silently
    }
  }
}

// Helpers for mappings
String getLanguageCode(String lang) {
  if (lang.contains('Bengali') || lang.contains('বাংলা')) return 'bn';
  if (lang.contains('Hindi') || lang.contains('हिन्दी')) return 'hi';
  return 'en';
}

String getLanguageName(String code) {
  switch (code) {
    case 'bn':
      return 'বাংলা (Bengali)';
    case 'hi':
      return 'हिन्दी (Hindi)';
    default:
      return 'English';
  }
}

