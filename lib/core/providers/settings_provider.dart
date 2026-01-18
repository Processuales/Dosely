import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings provider for app-wide state
/// Manages: locale, text size, voice settings, onboarding status
class SettingsProvider extends ChangeNotifier {
  final SharedPreferences prefs;

  SettingsProvider(this.prefs) {
    _loadSettings();
  }

  void _loadSettings() {
    // Locale
    final languageCode = prefs.getString('locale_code') ?? 'en';
    _locale = Locale(languageCode);

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
