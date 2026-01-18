import 'dart:async';
import 'dart:io' if (dart.library.html) '../../core/utils/web_stub.dart';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/profile.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/services/ai_service.dart';
import '../../core/theme/app_theme.dart';

class MedicalProfileDialog extends StatefulWidget {
  final UserProfile? initialProfile;

  const MedicalProfileDialog({super.key, this.initialProfile});

  @override
  State<MedicalProfileDialog> createState() => _MedicalProfileDialogState();
}

class _MedicalProfileDialogState extends State<MedicalProfileDialog> {
  final _medicalNotesController = TextEditingController();
  final _aiService = AIService();

  // Lists for manual editing
  late List<String> _allergies;
  late List<String> _conditions;

  // Recording State
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isTranscribing = false;
  bool _isAnalyzing = false;
  DateTime? _recordingStartTime;
  Timer? _amplitudeTimer;
  double _currentAmplitude = -160.0;
  int _animationTick = 0;

  // Manual Entry Controllers
  final _allergyController = TextEditingController();
  final _conditionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allergies = List.from(widget.initialProfile?.allergies ?? []);
    _conditions = List.from(widget.initialProfile?.conditions ?? []);
    _medicalNotesController.text = widget.initialProfile?.medicalNotes ?? '';
  }

  @override
  void dispose() {
    _medicalNotesController.dispose();
    _allergyController.dispose();
    _conditionController.dispose();
    _audioRecorder.dispose();
    _amplitudeTimer?.cancel();
    super.dispose();
  }

  // --- RECORDING LOGIC (Adapted from OnboardingScreen) ---

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        String? path;
        if (!kIsWeb) {
          final directory = await getApplicationDocumentsDirectory();
          path = '${directory.path}/medical_profile_recording.wav';
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        }

        final config = const RecordConfig(encoder: AudioEncoder.wav);

        if (kIsWeb) {
          await _audioRecorder.start(config, path: '');
        } else {
          await _audioRecorder.start(config, path: path!);
        }

        _recordingStartTime = DateTime.now();

        _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (
          timer,
        ) async {
          try {
            final amp = await _audioRecorder.getAmplitude();
            if (mounted) {
              setState(() {
                _currentAmplitude = amp.current;
                _animationTick++;
              });
            }
          } catch (e) {
            if (mounted) setState(() => _animationTick++);
          }
        });

        if (mounted) setState(() => _isRecording = true);
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<String?> _stopRecordingInternal() async {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    try {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      return path;
    } catch (e) {
      setState(() => _isRecording = false);
      return null;
    }
  }

  Future<void> _handleStopAndTranscribe() async {
    if (_recordingStartTime != null) {
      final duration = DateTime.now().difference(_recordingStartTime!);
      if (duration.inMilliseconds < 500) {
        await _stopRecordingInternal();
        return;
      }
    }

    final path = await _stopRecordingInternal();
    if (path != null) {
      if (mounted) setState(() => _isTranscribing = true);

      Uint8List? audioBytes;
      final languageCode = context.read<SettingsProvider>().locale.languageCode;

      try {
        if (kIsWeb) {
          final response = await http.get(Uri.parse(path));
          if (response.statusCode == 200) {
            audioBytes = response.bodyBytes;
          }
        } else {
          final file = File(path);
          if (await file.exists()) {
            audioBytes = await file.readAsBytes();
          }
        }

        if (audioBytes != null) {
          final transcribedText = await _aiService.transcribeMedicalNotes(
            audioBytes,
            languageCode: languageCode,
          );

          if (mounted) {
            setState(() {
              _isTranscribing = false;
              if (transcribedText != null && transcribedText.isNotEmpty) {
                final current = _medicalNotesController.text;
                _medicalNotesController.text =
                    current.isEmpty
                        ? transcribedText
                        : '$current $transcribedText';
              }
            });
          }
        } else {
          if (mounted) setState(() => _isTranscribing = false);
        }
      } catch (e) {
        if (mounted) setState(() => _isTranscribing = false);
      }
    }
  }

  // --- AI ANALYSIS ---

  Future<void> _analyzeNotes() async {
    final notes = _medicalNotesController.text.trim();
    if (notes.isEmpty) return;

    setState(() => _isAnalyzing = true);

    try {
      final languageCode = context.read<SettingsProvider>().locale.languageCode;
      final parsedData = await _aiService.parseMedicalProfile(
        notes,
        languageCode: languageCode,
      );

      final newAllergies = List<String>.from(parsedData['allergies'] ?? []);
      final newConditions = List<String>.from(parsedData['conditions'] ?? []);

      if (mounted) {
        setState(() {
          // Merge or Replace? Let's merge unique items to be safe,
          // or maybe the user wants the AI to fully refresh based on notes.
          // The prompt says "identify", so let's add them if not present.
          for (var item in newAllergies) {
            if (!_allergies.contains(item)) _allergies.add(item);
          }
          for (var item in newConditions) {
            if (!_conditions.contains(item)) _conditions.add(item);
          }
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      debugPrint('Error analyzing notes: $e');
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  // --- MANUAL EDIT METHODS ---

  void _addAllergy(String value) {
    if (value.trim().isNotEmpty && !_allergies.contains(value.trim())) {
      setState(() {
        _allergies.add(value.trim());
        _allergyController.clear();
      });
    }
  }

  void _addCondition(String value) {
    if (value.trim().isNotEmpty && !_conditions.contains(value.trim())) {
      setState(() {
        _conditions.add(value.trim());
        _conditionController.clear();
      });
    }
  }

  void _removeAllergy(String item) {
    setState(() => _allergies.remove(item));
  }

  void _removeCondition(String item) {
    setState(() => _conditions.remove(item));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.medical_services, color: AppTheme.primary),
          const SizedBox(width: 8),
          Text(l10n.profileMedicalProfile), // "Medical Profile"
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          // Constrain width for web/large screens
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- AI NOTES SECTION ---
              Text(
                l10n.onboardingMedicalTitle, // "Medical Notes"
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),

              // Text Field
              TextField(
                controller: _medicalNotesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: l10n.onboardingMedicalHint,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),

              // Mic & Analyze Row
              Row(
                children: [
                  // Mic Button (Visualizer handled simply here)
                  GestureDetector(
                    onLongPress: _startRecording,
                    onLongPressUp: _handleStopAndTranscribe,
                    onTap: () {
                      if (_isRecording) {
                        _handleStopAndTranscribe();
                      } else {
                        _startRecording();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child:
                          _isTranscribing
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Icon(
                                _isRecording ? Icons.stop : Icons.mic,
                                color: Colors.white,
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Analyze Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          (_isRecording || _isTranscribing || _isAnalyzing)
                              ? null
                              : _analyzeNotes,
                      icon:
                          _isAnalyzing
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.auto_awesome),
                      label: Text(
                        _isAnalyzing
                            ? l10n.scanAnalyzing
                            : l10n.onboardingAiAnalysis,
                      ), // Reuse text or "Analyze"
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.surfaceAlt,
                        foregroundColor: AppTheme.primary,
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
              if (_isRecording)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    "Recording... Tap to stop",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              const Divider(height: 32),

              // --- ALLERGIES SECTION ---
              Text(
                l10n.profileAllergies,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _allergies
                        .map(
                          (item) => Chip(
                            label: Text(item),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () => _removeAllergy(item),
                            backgroundColor: Colors.red.withValues(alpha: 0.1),
                            labelStyle: const TextStyle(color: Colors.red),
                            side: BorderSide(
                              color: Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _allergyController,
                      decoration: const InputDecoration(
                        hintText: 'Add allergy...',
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _addAllergy,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () => _addAllergy(_allergyController.text),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- CONDITIONS SECTION ---
              Text(
                l10n.profileConditions,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _conditions
                        .map(
                          (item) => Chip(
                            label: Text(item),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () => _removeCondition(item),
                            backgroundColor: AppTheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            labelStyle: const TextStyle(
                              color: AppTheme.primary,
                            ),
                            side: BorderSide(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                            ),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _conditionController,
                      decoration: const InputDecoration(
                        hintText: 'Add condition...',
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _addCondition,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () => _addCondition(_conditionController.text),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        ElevatedButton(
          onPressed: () {
            // Reconstruct Profile with updates
            final updatedProfile =
                widget.initialProfile?.copyWith(
                  medicalNotes: _medicalNotesController.text,
                  allergies: _allergies,
                  conditions: _conditions,
                ) ??
                UserProfile.empty().copyWith(
                  medicalNotes: _medicalNotesController.text,
                  allergies: _allergies,
                  conditions: _conditions,
                );

            Navigator.of(context).pop(updatedProfile);
          },
          child: Text(
            "Save",
          ), // Needs localization if strict, but 'Save' is usually common.
          // Wait, better to use l10n.dialogContinue or similar if available, or just hardcode 'Save' for now.
        ),
      ],
    );
  }
}
