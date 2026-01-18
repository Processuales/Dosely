import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Service to handle Gumloop API for medication verification via web search
class GumloopService {
  static String get _apiKey => dotenv.env['GUMLOOP_API_KEY'] ?? '';
  static const String _userId = 'GIkwpb9UWwe8OPfPUATcYuTSGVL2';
  static const String _savedItemId = 'wAt46kgQt9mrgQ3CKx8pXv';
  static const String _baseUrl = 'https://api.gumloop.com/api/v1';

  /// Verify medication data via Gumloop web search
  /// Takes the raw extracted text and returns verified/corrected version
  Future<String?> verifyMedicationData(String extractedText) async {
    if (extractedText.isEmpty) return null;

    try {
      // Step 1: Start the pipeline
      final startResponse = await http.post(
        Uri.parse(
          '$_baseUrl/start_pipeline?user_id=$_userId&saved_item_id=$_savedItemId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({'input': extractedText}),
      );

      if (startResponse.statusCode != 200) {
        debugPrint(
          'Gumloop start error: ${startResponse.statusCode} - ${startResponse.body}',
        );
        return null;
      }

      final startData = jsonDecode(startResponse.body);
      final runId = startData['run_id'];

      if (runId == null) {
        debugPrint('Gumloop: No run_id returned');
        return null;
      }

      // Step 2: Poll for completion (max 60 seconds)
      const maxAttempts = 30;
      const pollInterval = Duration(seconds: 2);

      for (int i = 0; i < maxAttempts; i++) {
        await Future.delayed(pollInterval);

        final statusResponse = await http.get(
          Uri.parse('$_baseUrl/get_pl_run?run_id=$runId&user_id=$_userId'),
          headers: {'Authorization': 'Bearer $_apiKey'},
        );

        if (statusResponse.statusCode != 200) {
          debugPrint('Gumloop poll error: ${statusResponse.statusCode}');
          continue;
        }

        final statusData = jsonDecode(statusResponse.body);
        final state = statusData['state'];

        if (state == 'DONE') {
          // Extract output
          final outputs = statusData['outputs'];
          if (outputs != null && outputs is Map) {
            // Return the first output value, or the whole thing as string
            if (outputs.isNotEmpty) {
              final firstOutput = outputs.values.first;
              return firstOutput?.toString();
            }
          }
          debugPrint('Gumloop completed but no outputs');
          return null;
        } else if (state == 'FAILED' || state == 'TERMINATED') {
          debugPrint('Gumloop pipeline failed: $state');
          return null;
        }
        // else RUNNING or STARTED - continue polling
      }

      debugPrint('Gumloop: Timeout waiting for completion');
      return null;
    } catch (e) {
      debugPrint('Gumloop error: $e');
      return null;
    }
  }
}
