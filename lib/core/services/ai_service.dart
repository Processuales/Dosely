import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/ai_prompts.dart';

class AIService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _modelName = 'gemini-2.5-flash';

  late final GenerativeModel _model;

  String _getLanguageName(String code) {
    if (code == 'en') return 'English';
    if (code == 'fr') return 'French';
    if (code == 'es') return 'Spanish';
    if (code == 'de') return 'German';
    return code; // Fallback or assume it's already a name
  }

  AIService() {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  /// Step 1: Extract text from medication label image (OCR)
  /// Returns raw extracted text for verification
  Future<String?> extractTextFromImage(Uint8List imageBytes) async {
    try {
      if (imageBytes.isEmpty) return null;

      const prompt = '''
Extract ALL text visible on this medication label. Include:
- Medication name
- Dosage information
- Instructions
- Warnings
- Active ingredients
- Any other visible text

Output the extracted text as a plain text string, preserving the layout roughly.
Do not add any analysis or commentary - just extract the text.
''';

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      // Use a non-JSON model for plain text extraction
      final ocrModel = GenerativeModel(model: _modelName, apiKey: _apiKey);

      final response = await ocrModel.generateContent(content);
      return response.text;
    } catch (e) {
      print('OCR Error: $e');
      return null;
    }
  }

  /// Analyzes a medication label image and returns structured data.
  Future<Map<String, dynamic>> analyzeMedicationLabel(
    Uint8List imageBytes,
    Map<String, dynamic> userProfileJson,
    List<Map<String, dynamic>> currentMedications, {
    String languageCode = 'en',
    String? userFrequency,
    String? userInstructions,
    bool simpleMode = false,
  }) async {
    try {
      if (imageBytes.isEmpty) return {};

      final profileJsonString = jsonEncode(userProfileJson);
      final currentMedsJsonString = jsonEncode(currentMedications);

      // Determine target language name
      final languageName = _getLanguageName(languageCode);

      String prompt = AIPrompts.analyzeMedicationLabel(
        profileJsonString,
        currentMedsJsonString,
        userFrequency: userFrequency,
        userInstructions: userInstructions,
        simpleMode: simpleMode,
      );

      // Add language instruction
      prompt +=
          '\n\nIMPORTANT: Output all text fields (descriptions, warnings, etc.) in this language: $languageName';

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      final response = await _model.generateContent(content);
      return _parseJson(response.text);
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
      final languageName = _getLanguageName(languageCode);
      final prompt = AIPrompts.parseMedicalProfile(notes, languageName);

      final response = await _model.generateContent([Content.text(prompt)]);

      final jsonResponse = _parseJson(response.text);

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

  /// Transcribes audio data to text (Not fully supported by Flash 1.5 text-only, but multimodal might support audio?)
  /// Note: Gemini 1.5 Flash supports audio input.
  Future<String?> transcribeMedicalNotes(
    Uint8List audioBytes, {
    String languageCode = 'en',
  }) async {
    // Note: Implementation depends on SDK specific support for audio parts.
    // For now, we'll assume audio support via DataPart if supported, or text fallback.
    // However, google_generative_ai doesn't explicitly support 'input_audio' MIME in DataPart freely without checking docs.
    // Assuming standard usage:
    try {
      final languageName = _getLanguageName(languageCode);
      final prompt = AIPrompts.transcribeMedicalNotes(languageName);

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('audio/mp3', audioBytes), // Assuming mp3/aac
        ]),
      ];

      final response = await _model.generateContent(content);
      return response.text?.trim();
    } catch (e) {
      print(
        'Transcription not fully supported in this customized service yet: $e',
      );
      return null;
    }
  }

  /// Analyzes a medication text query and returns structured data.
  Future<Map<String, dynamic>> analyzeMedicationText({
    required String query,
    required String userProfile,
    required List<Map<String, dynamic>> currentMedications,
    String? userFrequency,
    String? userInstructions,
    bool simpleMode = false,
    String languageCode = 'en',
  }) async {
    try {
      final String profileJson = userProfile.isEmpty ? "{}" : userProfile;
      final String medsJson = jsonEncode(currentMedications);
      final languageName = _getLanguageName(languageCode);

      String prompt = AIPrompts.analyzeMedicationText(
        query,
        profileJson,
        medsJson,
        simpleMode: simpleMode,
      );

      prompt +=
          '\n\nIMPORTANT: Output all text fields in this language: $languageName';

      final response = await _model.generateContent([Content.text(prompt)]);

      return _parseJson(response.text);
    } catch (e) {
      // ignore: avoid_print
      print('Error analyzing medication text: $e');
      throw Exception('Failed to analyze medication text');
    }
  }

  /// Simplifies medication information
  Future<Map<String, dynamic>> simplifyMedicationInfo({
    required String shortDescription,
    required String longDescription,
    required List<String> commonSideEffects,
    List<String>? userRisks,
    String? statusReason,
    String? conflictDescription,
    String languageCode = 'en',
  }) async {
    final languageName = _getLanguageName(languageCode);

    final prompt = '''
You are explaining medication information to a 10-year-old child. 
Make it simple, friendly, and reassuring. Avoid scary medical terms.
Use short sentences and everyday words.
Translate the Output to: $languageName

ORIGINAL INFORMATION:
Short Description: $shortDescription
Long Description: $longDescription
Side Effects: ${commonSideEffects.join(', ')}
${userRisks != null && userRisks.isNotEmpty ? 'Personal Risks/Warnings: ${userRisks.join(', ')}' : ''}
${statusReason != null ? 'Why Caution is Needed: $statusReason' : ''}
${conflictDescription != null ? 'Conflict Warning: $conflictDescription' : ''}

Return ONLY valid JSON with simplified versions:
{
  "shortDescriptionSimplified": "Simple 1-sentence explanation",
  "longDescriptionSimplified": "Simple 2-3 sentence explanation",
  "commonSideEffectsSimplified": ["simple effect 1", "simple effect 2"],
  "userRisksSimplified": ["simple risk 1", "simple risk 2"],
  "statusReasonSimplified": "Simple explanation of why to be careful (or null if not applicable)",
  "conflictDescriptionSimplified": "Simple explanation of the conflict (or null if not applicable)"
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return _parseJson(response.text);
    } catch (e) {
      print('Simplification Error: $e');
      return {};
    }
  }

  /// Translates the app's string map to a new language
  Future<Map<String, String>> translateAppStrings(
    Map<String, String> sourceStrings,
    String targetLanguage,
  ) async {
    final prompt = '''
Translate the following JSON map of UI strings to $targetLanguage.
Keep the keys exactly the same. Only translate the values.
Preserve any variables like \$days.
Adapt the tone to be friendly and clear.

SOURCE STRINGS:
${jsonEncode(sourceStrings)}

Return ONLY valid JSON.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final result = _parseJson(response.text);
      return Map<String, String>.from(result);
    } catch (e) {
      print('Translation Error: $e');
      return {};
    }
  }

  /// Translates a list of strings to target language
  Future<List<String>> translateList(
    List<String> items,
    String targetLanguage,
  ) async {
    if (items.isEmpty) return [];

    final prompt = '''
Translate the following list of texts to $targetLanguage.
Maintain the exact meaning.
Return ONLY a JSON array of strings.

SOURCE LIST:
${jsonEncode(items)}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final result = _parseJson(response.text);
      if (result is List) {
        return result.map((e) => e.toString()).toList();
      }
      return items;
    } catch (e) {
      print('List Translation Error: $e');
      return items;
    }
  }

  /// Summarizes page content into a friendly audio script for Read Aloud
  Future<String?> summarizeForVoice(
    String pageContent,
    String languageCode,
  ) async {
    if (pageContent.trim().isEmpty) return null;

    final languageName = _getLanguageName(languageCode);

    final prompt = '''
You are narrating a mobile app screen for a visually impaired user.
Describe what's on the screen in a natural, conversational way - like you're guiding someone through it.
Focus on the main content and interactive elements. Be concise (2-4 sentences max).

Format like: "On this screen, you can see [main content]. There's a button to [action], and below that..."
Do NOT say "Welcome to..." or introduce the app. Just describe what's visible.

Output ONLY the narration text in $languageName. No JSON, no quotes, just plain text.

SCREEN CONTENT:
$pageContent
''';

    try {
      // Use a simpler model config for plain text output
      final model = GenerativeModel(model: _modelName, apiKey: _apiKey);

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text?.trim();
    } catch (e) {
      print('Summarization Error: $e');
      return null;
    }
  }

  dynamic _parseJson(String? text) {
    if (text == null) return {};
    String clean = text;
    if (clean.startsWith('```json')) {
      clean = clean.substring(7);
    } else if (clean.startsWith('```')) {
      clean = clean.substring(3);
    }
    if (clean.endsWith('```')) {
      clean = clean.substring(0, clean.length - 3);
    }
    try {
      return jsonDecode(clean.trim());
    } catch (e) {
      print("JSON Parse Error: $e\nOriginal text: $text");
      return {};
    }
  }
}
