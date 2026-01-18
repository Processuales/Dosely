import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/ai_service.dart';
import '../../../core/services/gumloop_service.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/localization/app_localizations.dart';

import 'medication_details_screen.dart';

class ScanLoadingScreen extends StatefulWidget {
  final XFile? imageFile;
  final String? searchQuery;
  final String? userFrequency;
  final String? userInstructions;

  const ScanLoadingScreen({
    super.key,
    this.imageFile,
    this.searchQuery,
    this.userFrequency,
    this.userInstructions,
  });

  @override
  State<ScanLoadingScreen> createState() => _ScanLoadingScreenState();
}

class _ScanLoadingScreenState extends State<ScanLoadingScreen> {
  final _aiService = AIService();
  final _gumloopService = GumloopService();
  String _statusMessage = 'Analyzing Medicine...';

  @override
  void initState() {
    super.initState();
    // Defer analysis to allow context access for l10n
    Future.microtask(() => _analyzeImage());
  }

  Future<void> _analyzeImage() async {
    // Get current data
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final medicationProvider = Provider.of<MedicationProvider>(
      context,
      listen: false,
    );
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    final profile = profileProvider.profile;
    final medications = medicationProvider.medications;
    final isSimpleMode = settingsProvider.simpleMode;
    // Resolve language for AI
    final languageCode =
        settingsProvider.locale.languageCode == 'x'
            ? (settingsProvider.customLanguageName ?? 'en')
            : settingsProvider.locale.languageCode;

    if (mounted) {
      setState(() {
        _statusMessage = AppLocalizations.of(context)!.scanAnalyzing;
      });
    }

    try {
      // 3. Analyze
      Map<String, dynamic> result;

      if (widget.imageFile != null) {
        // Step 1: OCR - Extract text from image
        if (mounted) {
          setState(() {
            _statusMessage = 'Step 1/3: Reading label (OCR)...';
          });
        }

        final bytes = await widget.imageFile!.readAsBytes();
        final extractedText = await _aiService.extractTextFromImage(bytes);

        if (extractedText == null || extractedText.isEmpty) {
          throw Exception('Could not read medication label');
        }

        // Step 2: Gumloop verification (web search to verify)
        if (mounted) {
          setState(() {
            _statusMessage = 'Step 2/3: Verifying via Gumloop...';
          });
        }

        String verifiedText = extractedText;
        try {
          final gumloopResult = await _gumloopService.verifyMedicationData(
            extractedText,
          );
          if (gumloopResult != null && gumloopResult.isNotEmpty) {
            verifiedText = gumloopResult;
          }
        } catch (e) {
          // If Gumloop fails, continue with original text
          debugPrint('Gumloop verification skipped: $e');
        }

        // Step 3: Deep Analysis with verified text
        if (mounted) {
          setState(() {
            _statusMessage = 'Step 3/3: Analyzing medication...';
          });
        }

        result = await _aiService.analyzeMedicationText(
          query: verifiedText,
          userProfile: jsonEncode(profile.toJson()),
          currentMedications: medications.map((m) => m.toJson()).toList(),
          userFrequency: widget.userFrequency,
          userInstructions: widget.userInstructions,
          simpleMode: isSimpleMode,
          languageCode: languageCode,
        );
      } else if (widget.searchQuery != null) {
        // Text Search - skip OCR, but still use Gumloop
        if (mounted) {
          setState(() {
            _statusMessage = 'Verifying medication...';
          });
        }

        String verifiedQuery = widget.searchQuery!;
        try {
          final gumloopResult = await _gumloopService.verifyMedicationData(
            widget.searchQuery!,
          );
          if (gumloopResult != null && gumloopResult.isNotEmpty) {
            verifiedQuery = gumloopResult;
          }
        } catch (e) {
          debugPrint('Gumloop verification skipped: $e');
        }

        if (mounted) {
          setState(() {
            _statusMessage = 'Analyzing medication...';
          });
        }

        result = await _aiService.analyzeMedicationText(
          query: verifiedQuery,
          userProfile: jsonEncode(profile.toJson()),
          currentMedications: medications.map((m) => m.toJson()).toList(),
          simpleMode: isSimpleMode,
          languageCode: languageCode,
        );
      } else {
        throw Exception('No image or query provided');
      }

      if (result.isEmpty) {
        throw Exception('AI returned empty result');
      }

      // Check for existing drug info and override frequency/instructions if available
      final String rawName = result['name'] ?? '';
      final String drugId = rawName.toLowerCase().replaceAll(
        RegExp(r'\s+'),
        '_',
      );

      final existingDrugInfo = medicationProvider.getDrugInfo(drugId);

      if (existingDrugInfo != null) {
        // We have knowledge about this drug!

        // If user didn't override frequency, and we have a saved preference, use it.
        if (widget.userFrequency == null &&
            existingDrugInfo.lastKnownFrequency != null) {
          result['frequency'] = existingDrugInfo.lastKnownFrequency;
          // Keep isEstimatedFrequency as-is from AI response - don't reset it
        }

        // If user didn't override instructions, and we have a saved preference, use it.
        if (widget.userInstructions == null &&
            existingDrugInfo.lastKnownInstructions != null) {
          result['instructions'] = existingDrugInfo.lastKnownInstructions;
        }
      }

      if (!mounted) return;

      // 4. Navigate to Details
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => MedicationDetailsScreen(
                scanData: result,
                imageFile: widget.imageFile,
              ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.scanError}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.scanAnalyzingWait,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
