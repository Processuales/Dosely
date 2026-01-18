import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/ai_prompts.dart';

class AIService {
  static const String _apiKey =
      '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';
  static const String _modelName = 'google/gemini-3-flash-preview';
  static const String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

  /// Analyzes a medication label image and returns structured data.
  Future<Map<String, dynamic>> analyzeMedicationLabel(
    Uint8List imageBytes,
    Map<String, dynamic> userProfileJson,
    List<Map<String, dynamic>> currentMedications, {
    String languageCode = 'en',
  }) async {
    try {
      if (imageBytes.isEmpty) return {};

      final base64Image = base64Encode(imageBytes);
      final profileJsonString = jsonEncode(userProfileJson);
      final currentMedsJsonString = jsonEncode(currentMedications);

      final prompt = AIPrompts.analyzeMedicationLabel(
        profileJsonString,
        currentMedsJsonString,
      );

      // Construct message with image
      final content = [
        {'type': 'text', 'text': prompt},
        {
          'type': 'image_url',
          'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
        },
      ];

      final responseBody = await _sendOpenRouterRequest(content);
      if (responseBody == null) return {};

      final cleanJson = _cleanJsonString(responseBody);
      return jsonDecode(cleanJson) as Map<String, dynamic>;
    } catch (e) {
      // ignore: avoid_print
      print('AI Analysis Error: $e');
      return {};
    }
  }

  /// Parses natural language medical notes into structured tags.
  Future<Map<String, List<String>>> parseMedicalProfile(
    String notes, {
    String languageCode = 'en',
  }) async {
    if (notes.trim().isEmpty) {
      return {'allergies': [], 'conditions': []};
    }

    try {
      final languageName = languageCode == 'fr' ? 'French' : 'English';
      final prompt = AIPrompts.parseMedicalProfile(notes, languageName);

      final responseBody = await _sendOpenRouterRequest([
        {'type': 'text', 'text': prompt},
      ]);

      if (responseBody == null) return {'allergies': [], 'conditions': []};

      // Extract JSON from response (OpenRouter/Gemini might wrap in backticks)
      final cleanJson = _cleanJsonString(responseBody);
      final Map<String, dynamic> jsonResponse = jsonDecode(cleanJson);

      final allergies =
          (jsonResponse['allergies'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      final conditions =
          (jsonResponse['conditions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      return {'allergies': allergies, 'conditions': conditions};
    } catch (e) {
      // ignore: avoid_print
      print('AI Parse Error: $e');
      return {'allergies': [], 'conditions': []};
    }
  }

  /// Transcribes audio data to text using the AI model.
  Future<String?> transcribeMedicalNotes(
    Uint8List audioBytes, {
    String languageCode = 'en',
    String audioFormat = 'aac',
  }) async {
    try {
      if (audioBytes.isEmpty) {
        return null;
      }

      final base64Audio = base64Encode(audioBytes);

      final languageName = languageCode == 'fr' ? 'French' : 'English';
      final prompt = AIPrompts.transcribeMedicalNotes(languageName);

      final responseBody = await _sendOpenRouterRequest([
        {'type': 'text', 'text': prompt},
        {
          'type': 'input_audio',
          'input_audio': {'data': base64Audio, 'format': audioFormat},
        },
      ]);

      return responseBody?.trim();
    } catch (e) {
      // ignore: avoid_print
      print('AI Transcription Error: $e');
      return null;
    }
  }

  /// Helper to send requests to OpenRouter
  Future<String?> _sendOpenRouterRequest(
    List<Map<String, dynamic>> content,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer':
              'https://cleardose.app', // Optional, for OpenRouter rankings
          'X-Title': 'Dosely', // Optional
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _modelName,
          'messages': [
            {'role': 'user', 'content': content},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        return content?.toString();
      } else {
        // ignore: avoid_print
        print('OpenRouter Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('HTTP Error: $e');
      return null;
    }
  }

  String _cleanJsonString(String raw) {
    String result = raw;
    if (result.startsWith('```json')) {
      result = result.substring(7);
    } else if (result.startsWith('```')) {
      result = result.substring(3);
    }
    if (result.endsWith('```')) {
      result = result.substring(0, result.length - 3);
    }
    return result.trim();
  }
}
