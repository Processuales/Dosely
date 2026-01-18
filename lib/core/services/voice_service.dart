import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Service to handle ElevenLabs Text-to-Speech API
class VoiceService {
  static String get _apiKey => dotenv.env['ELEVENLABS_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.elevenlabs.io';

  // Voice options - 3 distinct voices for user selection
  static const Map<String, String> voices = {
    'aria': 'JBFqnCBsd6RMkjVDRZzb', // Friendly female
    'marcus': 'IKne3meq5aSn9XLyUdCD', // Calm male
    'sophia': '9BWtsMINqrJLrRacOk9x', // Warm female
  };

  static const List<String> voiceNames = ['Aria', 'Marcus', 'Sophia'];

  /// Generate speech from text using ElevenLabs Text-to-Dialogue API
  /// Returns audio bytes (MP3 format)
  Future<Uint8List?> generateSpeech(
    String text, {
    String voiceKey = 'aria',
  }) async {
    final voiceId = voices[voiceKey] ?? voices['aria']!;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/text-to-dialogue?output_format=mp3_44100_128'),
        headers: {'xi-api-key': _apiKey, 'Content-Type': 'application/json'},
        body: jsonEncode({
          'inputs': [
            {'text': text, 'voice_id': voiceId},
          ],
          'model_id': 'eleven_v3',
        }),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print(
          'ElevenLabs API Error: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('ElevenLabs Error: $e');
      return null;
    }
  }

  /// Fetch available voices from ElevenLabs (for future use)
  Future<List<Map<String, dynamic>>> fetchVoices() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v2/voices?page_size=20&voice_type=default'),
        headers: {'xi-api-key': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final voices = data['voices'] as List;
        return voices
            .map(
              (v) => {
                'id': v['voice_id'],
                'name': v['name'],
                'description': v['description'],
              },
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching voices: $e');
      return [];
    }
  }
}
