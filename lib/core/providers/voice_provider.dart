import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/voice_service.dart';
import '../services/ai_service.dart';

/// Provider to manage global voice playback state
class VoiceProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  final VoiceService _voiceService = VoiceService();
  final AIService _aiService = AIService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  VoiceProvider(this.prefs) {
    _loadSettings();
    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      notifyListeners();
    });
  }

  // Voice selection (0 = Aria, 1 = Marcus, 2 = Sophia)
  int _voiceIndex = 0;
  int get voiceIndex => _voiceIndex;

  String get selectedVoiceKey {
    switch (_voiceIndex) {
      case 1:
        return 'marcus';
      case 2:
        return 'sophia';
      default:
        return 'aria';
    }
  }

  String get selectedVoiceName => VoiceService.voiceNames[_voiceIndex];

  // Playback state
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _loadSettings() {
    _voiceIndex = prefs.getInt('voice_index') ?? 0;
    notifyListeners();
  }

  Future<void> setVoice(int index) async {
    if (index >= 0 && index <= 2 && _voiceIndex != index) {
      _voiceIndex = index;
      await prefs.setInt('voice_index', index);
      notifyListeners();
    }
  }

  /// Main method: Summarize content with AI, then speak with ElevenLabs
  Future<void> readAloud(String pageContent, String languageCode) async {
    if (_isLoading || _isPlaying) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Step 1: AI Summarization
      final summary = await _aiService.summarizeForVoice(
        pageContent,
        languageCode,
      );

      if (summary == null || summary.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Step 2: Generate speech with ElevenLabs
      final audioBytes = await _voiceService.generateSpeech(
        summary,
        voiceKey: selectedVoiceKey,
      );

      if (audioBytes == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Step 3: Play audio
      _isLoading = false;
      _isPlaying = true;
      notifyListeners();

      await _audioPlayer.play(BytesSource(audioBytes));
    } catch (e) {
      debugPrint('Read Aloud Error: $e');
      _isLoading = false;
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Stop playback immediately
  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
