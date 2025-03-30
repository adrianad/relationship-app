import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Extension on String for language code utilities
extension LanguageCodeUtils on String {
  String get nativeName {
    switch (this) {
      case 'en': return 'English';
      case 'es': return 'Español';
      case 'fr': return 'Français';
      case 'de': return 'Deutsch';
      default: return 'Unknown';
    }
  }
  
  String get flagEmoji {
    switch (this) {
      case 'en': return '🇬🇧';
      case 'es': return '🇪🇸';
      case 'fr': return '🇫🇷';
      case 'de': return '🇩🇪';
      default: return '🌐';
    }
  }
}

// Language data class to store both native and translated names
class LanguageData {
  final Locale locale;
  final String nativeName;
  final String englishName;
  final String flag;

  const LanguageData({
    required this.locale,
    required this.nativeName,
    required this.englishName,
    required this.flag,
  });
}

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  
  Locale _currentLocale = const Locale('en');
  bool _isLoading = true;
  
  LanguageProvider() {
    _loadSavedLanguage();
  }
  
  // Current locale getter
  Locale get currentLocale => _currentLocale;
  bool get isLoading => _isLoading;
  
  // Use generated localizations supported locales
  List<Locale> get supportedLocales => const [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('fr'), // French
    Locale('de'), // German
  ];

  // Get complete language data
  List<LanguageData> get availableLanguages => const [
    LanguageData(
      locale: Locale('en'),
      nativeName: 'English',
      englishName: 'English',
      flag: '🇬🇧',
    ),
    LanguageData(
      locale: Locale('es'),
      nativeName: 'Español',
      englishName: 'Spanish',
      flag: '🇪🇸',
    ),
    LanguageData(
      locale: Locale('fr'),
      nativeName: 'Français',
      englishName: 'French',
      flag: '🇫🇷',
    ),
    LanguageData(
      locale: Locale('de'),
      nativeName: 'Deutsch',
      englishName: 'German',
      flag: '🇩🇪',
    ),
  ];
  
  // Get language data for a specific locale
  LanguageData getLanguageData(Locale locale) {
    return availableLanguages.firstWhere(
      (data) => data.locale.languageCode == locale.languageCode,
      orElse: () => availableLanguages.first,
    );
  }
  
  // Get language name from locale
  String getLanguageName(Locale locale) {
    return getLanguageData(locale).nativeName;
  }
  
  // Check if text matches any language's native name or English name
  bool languageMatchesSearch(Locale locale, String searchQuery) {
    if (searchQuery.isEmpty) return true;
    
    final data = getLanguageData(locale);
    final lowercaseQuery = searchQuery.toLowerCase();
    
    return data.nativeName.toLowerCase().contains(lowercaseQuery) || 
           data.englishName.toLowerCase().contains(lowercaseQuery);
  }
  
  // Load saved language from shared preferences
  Future<void> _loadSavedLanguage() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      
      if (savedLanguage != null) {
        _currentLocale = Locale(savedLanguage);
      }
    } catch (e) {
      print('Error loading saved language: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Change language using the official Flutter approach
  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale == locale) return;
    
    // First notify about loading state
    _isLoading = true;
    notifyListeners();
    
    try {
      // Save to persistent storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
      
      // Set new locale - this will trigger UI refresh through the notifyListeners call
      _currentLocale = locale;
    } catch (e) {
      print('Error saving language: $e');
    } finally {
      // Update loading state and notify listeners
      _isLoading = false;
      notifyListeners();
    }
  }
}