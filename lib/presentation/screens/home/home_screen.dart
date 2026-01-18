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
import '../../widgets/add_medication_dialog.dart';
import '../../../core/services/camera_service.dart';
import '../scan/scan_loading_screen.dart';
import '../side_effects/medication_information_screen.dart';

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

                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ScanLoadingScreen(imageFile: fileToUse),
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
                        icon: Icons.qr_code_scanner,
                        label: l10n.homeScanIngredients,
                        onTap: () async {
                          final camera = CameraService();
                          final file = await camera.takePicture();
                          if (file != null && context.mounted) {
                            final savedPath = await camera.saveImage(file);
                            if (savedPath != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Ingredients saved: $savedPath',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SecondaryActionButton(
                        icon: Icons.keyboard,
                        label: l10n.homeAddManually,
                        onTap: () async {
                          final result = await showDialog<Medication>(
                            context: context,
                            builder: (context) => const AddMedicationDialog(),
                          );
                          if (result != null && context.mounted) {
                            context.read<MedicationProvider>().addMedication(
                              result,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Medication added')),
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
                              "No recent scans",
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
}
