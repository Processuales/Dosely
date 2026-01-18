import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/medication_provider.dart';
import '../../widgets/dosely_header.dart';
import '../../widgets/primary_action_card.dart';
import '../../widgets/secondary_action_button.dart';
import '../../widgets/medication_card.dart';
import '../../../core/models/medication.dart';
import '../../../core/services/camera_service.dart';
import '../scan/scan_loading_screen.dart';
import '../side_effects/medication_information_screen.dart';
import '../../../core/theme/app_theme.dart';

/// Home screen - main entry point after onboarding
class HomeScreen extends StatelessWidget {
  final VoidCallback? onViewAll;

  const HomeScreen({super.key, this.onViewAll});

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final medicationProvider = context.watch<MedicationProvider>();
    final recentMedications = List<Medication>.from(
      medicationProvider.medications,
    )..sort((a, b) => b.dateScanned.compareTo(a.dateScanned));

    // Take top 3
    final displayMedications = recentMedications.take(3).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const DoselyHeader(),

              // New Entry Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text(
                  l10n.homeTitle,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),

              // Primary Scan Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: PrimaryActionCard(
                  icon: Icons.photo_camera,
                  title: l10n.homeScanLabel,
                  subtitle: l10n.homeScanSubtitle,
                  onTap: () async {
                    final camera = CameraService();
                    final file = await camera.takePicture();
                    if (file != null && context.mounted) {
                      // Initial file to use (works for web directly)
                      XFile fileToUse = file;

                      // On mobile/desktop, we save it locally first
                      // On web, saveImage returns null, so we skip this
                      final savedPath = await camera.saveImage(file);
                      if (savedPath != null) {
                        fileToUse = XFile(savedPath);
                      }

                      // Ask for prescription details
                      Map<String, String?>? details;
                      if (context.mounted) {
                        details = await _showPrescriptionDetailsDialog(context);
                      }

                      if (context.mounted && details != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ScanLoadingScreen(
                                  imageFile: fileToUse,
                                  userFrequency: details?['frequency'],
                                  userInstructions: details?['instructions'],
                                ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),

              // Secondary Actions Row
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: SecondaryActionButton(
                        icon: Icons.search,
                        label: l10n.homeSearchWithAI,
                        onTap: () async {
                          final query = await _showSearchDialog(context);
                          if (query != null &&
                              query.isNotEmpty &&
                              context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        ScanLoadingScreen(searchQuery: query),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Recent Scans Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.homeRecentScans,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        onViewAll?.call();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.homeViewAll),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Recent Medication Cards
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child:
                    displayMedications.isEmpty
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              l10n.homeNoRecentScans,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                        : Column(
                          children:
                              displayMedications
                                  .map(
                                    (medication) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12.0,
                                      ),
                                      child: MedicationCard(
                                        name: medication.name,
                                        dosage: medication.dosage,
                                        timeAgo: _getTimeAgo(
                                          medication.dateScanned,
                                        ),
                                        status: medication.status,
                                        onTap:
                                            () => _navigateToInformation(
                                              context,
                                              medication,
                                            ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
              ),
              const SizedBox(height: 80), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToInformation(BuildContext context, Medication medication) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MedicationInformationScreen(medication: medication),
      ),
    );
  }

  Future<Map<String, String?>?> _showPrescriptionDetailsDialog(
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final frequencyController = TextEditingController();
    final instructionsController = TextEditingController();

    return showDialog<Map<String, String?>>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(
              l10n.dialogPrescriptionDetails,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.dialogPrescriptionQuestion,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: frequencyController,
                  decoration: InputDecoration(
                    labelText: l10n.dialogFrequency,
                    hintText: 'e.g. Daily, Twice a day',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: instructionsController,
                  decoration: InputDecoration(
                    labelText: l10n.dialogInstructions,
                    hintText: 'e.g. With food',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.dialogAutoDetectHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.statusCaution,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'frequency':
                        frequencyController.text.isEmpty
                            ? null
                            : frequencyController.text,
                    'instructions':
                        instructionsController.text.isEmpty
                            ? null
                            : instructionsController.text,
                  });
                },
                child: Text(l10n.dialogContinue),
              ),
            ],
          ),
    );
  }

  Future<String?> _showSearchDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              l10n.dialogSearchMedication,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.dialogSearchHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: l10n.dialogSearchMedication,
                    hintText: 'e.g. Small blue pill for headache',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.dialogCancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text(l10n.dialogSearch),
              ),
            ],
          ),
    );
  }
}
