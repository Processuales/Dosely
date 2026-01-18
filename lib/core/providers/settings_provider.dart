import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../localization/app_localizations.dart';
import '../services/ai_service.dart';

/// Settings provider for app-wide state
/// Manages: locale, text size, voice settings, onboarding status
class SettingsProvider extends ChangeNotifier {
  final SharedPreferences prefs;

  SettingsProvider(this.prefs) {
    _loadSettings();
  }

  void _loadSettings() {
    // Locale
    // Locale
    final languageCode = prefs.getString('locale_code') ?? 'en';

    if (languageCode == 'x') {
      _locale = const Locale('x');
      final jsonString = prefs.getString('custom_lang_data');
      if (jsonString != null) {
        try {
          final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
          AppLocalizationsDynamic.currentDynamicMap = Map<String, String>.from(
            jsonMap,
          );
          _customLanguageName = prefs.getString('custom_lang_name');
        } catch (e) {
          print('Error loading custom language: $e');
        }
      }
    } else {
      _locale = Locale(languageCode);
    }

    // User Name
    _userName = prefs.getString('user_name');

    // Text Size
    _textSizeIndex = prefs.getInt('text_size') ?? 0;

    // Voice Speed
    _voiceSpeedIndex = prefs.getInt('voice_speed') ?? 1;

    // Accessibility
    _colorblindMode = prefs.getInt('colorblind_mode') ?? 0;

    // Simple Mode
    _simpleMode = prefs.getBool('simple_mode') ?? false;

    // Theme & Contrast
    _isHighContrast = prefs.getBool('high_contrast') ?? false;

    // Onboarding
    _hasCompletedOnboarding = prefs.getBool('onboarding_complete') ?? false;

    notifyListeners();
  }

  // ===================
  // LOCALE
  // ===================

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  // ===================
  // USER PROFILE
  // ===================
  String? _userName;
  String? get userName => _userName;

  Future<void> setUserName(String name) async {
    _userName = name;
    await prefs.setString('user_name', name);
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale != newLocale) {
      _locale = newLocale;
      await prefs.setString('locale_code', newLocale.languageCode);

      // If switching away from custom 'x' locale, clear the dynamic map
      // but KEEP the customLanguageName so user can switch back
      if (newLocale.languageCode != 'x') {
        AppLocalizationsDynamic.currentDynamicMap = null;
        // DO NOT clear _customLanguageName - preserve it for dropdown
      }

      notifyListeners();
    }
  }

  // ===================
  // TEXT SIZE
  // ===================

  /// 0 = Normal (1.0x), 1 = Large (1.2x), 2 = Extra Large (1.4x)
  int _textSizeIndex = 0;
  int get textSizeIndex => _textSizeIndex;

  double get textScaleFactor {
    switch (_textSizeIndex) {
      case 1:
        return 1.2;
      case 2:
        return 1.4;
      default:
        return 1.0;
    }
  }

  Future<void> setTextSize(int index) async {
    if (_textSizeIndex != index && index >= 0 && index <= 2) {
      _textSizeIndex = index;
      await prefs.setInt('text_size', index);
      notifyListeners();
    }
  }

  // ===================
  // VOICE SETTINGS
  // ===================

  /// 0 = Slow, 1 = Normal, 2 = Fast
  int _voiceSpeedIndex = 1;
  int get voiceSpeedIndex => _voiceSpeedIndex;

  double get voiceSpeed {
    switch (_voiceSpeedIndex) {
      case 0:
        return 0.7;
      case 2:
        return 1.3;
      default:
        return 1.0;
    }
  }

  Future<void> setVoiceSpeed(int index) async {
    if (_voiceSpeedIndex != index && index >= 0 && index <= 2) {
      _voiceSpeedIndex = index;
      await prefs.setInt('voice_speed', index);
      notifyListeners();
    }
  }

  // FUTURE: Helper to plug in TTS/ElevenLabs later
  // void testVoice() {
  //   // TODO: Call VoiceService.speak("This is a test.");
  // }

  // ===================
  // ACCESSIBILITY
  // ===================

  /// 0 = Normal, 1 = Protanopia (Red-Blind), 2 = Deuteranopia (Green-Blind), 3 = Tritanopia (Blue-Blind)
  int _colorblindMode = 0;
  int get colorblindMode => _colorblindMode;

  Future<void> setColorblindMode(int mode) async {
    if (_colorblindMode != mode && mode >= 0 && mode <= 3) {
      _colorblindMode = mode;
      await prefs.setInt('colorblind_mode', mode);
      notifyListeners();
    }
  }

  // ===================
  // SIMPLE MODE
  // ===================

  bool _simpleMode = false;
  bool get simpleMode => _simpleMode;

  Future<void> toggleSimpleMode() async {
    _simpleMode = !_simpleMode;
    await prefs.setBool('simple_mode', _simpleMode);
    notifyListeners();
  }

  Future<void> setSimpleMode(bool value) async {
    if (_simpleMode != value) {
      _simpleMode = value;
      await prefs.setBool('simple_mode', value);
      notifyListeners();
    }
  }

  // ===================
  // ACCESSIBILITY
  // ===================

  bool _isHighContrast = false;
  bool get isHighContrast => _isHighContrast;

  Future<void> setHighContrast(bool value) async {
    if (_isHighContrast != value) {
      _isHighContrast = value;
      await prefs.setBool('high_contrast', value);
      notifyListeners();
    }
  }

  // ===================
  // CUSTOM LANGUAGES & LOADING
  // ===================

  bool _isLanguageLoading = false;
  bool get isLanguageLoading => _isLanguageLoading;

  String? _customLanguageName;
  String? get customLanguageName => _customLanguageName;

  Future<void> addCustomLanguage(
    String languageName, {
    Future<void> Function(String)? onLanguageAdded,
  }) async {
    try {
      _isLanguageLoading = true;
      notifyListeners();

      // 1. Get Source Strings (English)
      final sourceHelper = AppLocalizations(const Locale('en'));
      final sourceMap = sourceHelper.toMap();

      // 2. Translate via AI
      // We create a temporary instance of AIService here or pass it in.
      // Since we don't have dependency injection setup for it yet in this provider:
      final aiService = AIService();
      final translatedMap = await aiService.translateAppStrings(
        sourceMap,
        languageName,
      );

      if (translatedMap.isNotEmpty) {
        // 3. Save to Prefs
        // We use a specific prefix. For simplicity, we only store ONE custom language at a time for this MVP feature,
        // or we could key it by name. The user asked to "add a +", implying multiple?
        // But the user also said "store this localization so the user can always like its this language".
        // We'll support switching.
        final jsonString = jsonEncode(translatedMap);

        // We handle language codes. If the user types "German", we can't easily guess 'de'.
        // So we use a special code 'x' (private use) and store the name.
        // Or we use 'en_DE' etc? No.
        // Simpler: We use the languageName as the key if safe, or a hash.
        // Let's use 'x_custom' as the main toggle, and store the data.

        await prefs.setString('custom_lang_data', jsonString);
        await prefs.setString('custom_lang_name', languageName);
        await prefs.setString('locale_code', 'x');

        // 4. Update Runtime
        AppLocalizationsDynamic.currentDynamicMap = translatedMap;
        _locale = const Locale('x'); // Use 'x' for custom
        _customLanguageName = languageName;

        if (onLanguageAdded != null) {
          await onLanguageAdded(languageName);
        }

        notifyListeners();
      }
    } catch (e) {
      print('Error adding language: $e');
    } finally {
      _isLanguageLoading = false;
      notifyListeners();
    }
  }

  // ===================
  // ONBOARDING
  // ===================

  bool _hasCompletedOnboarding = false;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await prefs.setBool('onboarding_complete', true);
    notifyListeners();
  }

  // For demo/testing: reset onboarding
  Future<void> resetOnboarding() async {
    _hasCompletedOnboarding = false;
    await prefs.setBool('onboarding_complete', false);
    notifyListeners();
  }
}
