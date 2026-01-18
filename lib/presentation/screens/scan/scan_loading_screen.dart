import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/ai_service.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/medication_provider.dart';

import 'medication_details_screen.dart';

class ScanLoadingScreen extends StatefulWidget {
  final XFile imageFile;

  const ScanLoadingScreen({super.key, required this.imageFile});

  @override
  State<ScanLoadingScreen> createState() => _ScanLoadingScreenState();
}

class _ScanLoadingScreenState extends State<ScanLoadingScreen> {
  final _aiService = AIService();
  String _statusMessage = 'Reading label...';

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      // 1. Read bytes
      final bytes = await widget.imageFile.readAsBytes();

      // 2. Get Profile & Medications
      if (!mounted) return;
      final profile = context.read<ProfileProvider>().profile;
      final medications =
          context
              .read<MedicationProvider>()
              .medications
              .map((m) => m.toJson())
              .toList();

      setState(() => _statusMessage = 'Analyzing with AI...');

      // 3. Analyze
      final result = await _aiService.analyzeMedicationLabel(
        bytes,
        profile.toJson(),
        medications,
      );

      if (result.isEmpty) {
        throw Exception('AI returned empty result');
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
            content: Text('Error analyzing image: $e'),
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
              'This may take a few seconds',
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
