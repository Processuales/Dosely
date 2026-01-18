import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/models/medication.dart';
import '../../../core/models/drug_info.dart';
import '../../widgets/read_aloud_button.dart';

import '../../../core/localization/app_localizations.dart';

class MedicationDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> scanData;
  final XFile? imageFile;

  const MedicationDetailsScreen({
    super.key,
    required this.scanData,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    // Parse data safely
    final name = scanData['name'] ?? 'Unknown Medication';
    final dosage = scanData['dosage'] ?? 'Unknown Dosage';
    final frequency = scanData['frequency'] ?? 'As directed';
    final instructions = scanData['instructions'] ?? '';
    final typeStr = scanData['type'] ?? 'tablet';
    final isEstimated = scanData['isEstimatedDosage'] == true;
    final isEstimatedFreq = scanData['isEstimatedFrequency'] == true;
    final userRisks = (scanData['userRisks'] as List?)?.cast<String>() ?? [];
    final conflictDesc = scanData['conflictDescription'];
    final statusReason = scanData['statusReason'];
    final shortDesc = scanData['shortDescription'];
    final longDesc = scanData['longDescription'];
    final commonSideEffects =
        (scanData['commonSideEffects'] as List?)?.cast<String>() ?? [];

    // Simplified fields
    final shortDescSimple = scanData['shortDescriptionSimplified'];
    final longDescSimple = scanData['longDescriptionSimplified'];
    final commonSideEffectsSimple =
        (scanData['commonSideEffectsSimplified'] as List?)?.cast<String>();
    final statusReasonSimple = scanData['statusReasonSimplified'];
    final conflictDescSimple = scanData['conflictDescriptionSimplified'];
    final statusStr = scanData['status'] ?? 'safe';

    // Get Settings
    final settings = context.watch<SettingsProvider>();
    final isSimpleMode = settings.simpleMode;
    final l10n = AppLocalizations.of(context)!;

    // Determine display values
    final displayShortDesc =
        isSimpleMode && shortDescSimple != null ? shortDescSimple : shortDesc;

    final displayLongDesc =
        isSimpleMode && longDescSimple != null ? longDescSimple : longDesc;

    final displayStatusReason =
        isSimpleMode && statusReasonSimple != null
            ? statusReasonSimple
            : statusReason;

    final displayConflictDesc =
        isSimpleMode && conflictDescSimple != null
            ? conflictDescSimple
            : conflictDesc;

    // Map status string to enum
    final status = MedicationStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => MedicationStatus.safe,
    );

    // Map type string to enum
    final type = MedicationType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => MedicationType.tablet,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanResultTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed:
              () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: ReadAloudButton(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isEstimated
                                      ? Colors.orange.withOpacity(0.1)
                                      : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    isEstimated ? Colors.orange : Colors.blue,
                              ),
                            ),
                            child: Text(
                              dosage,
                              style: TextStyle(
                                color:
                                    isEstimated
                                        ? Colors.orange[800]
                                        : Colors.blue[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isEstimated) ...[
                            const SizedBox(width: 8),
                            Text(
                              l10n.scanEstimated,
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (displayShortDesc != null) ...[
              const SizedBox(height: 16),
              Text(
                displayShortDesc,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            // Risks Section
            if (userRisks.isNotEmpty ||
                status == MedicationStatus.conflict) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50, // Very light red
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.red.shade900, // Dark red
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.scanRisksConflicts,
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    if (displayStatusReason != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        displayStatusReason,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ],
                    if (displayConflictDesc != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        displayConflictDesc,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ],
                    if (userRisks.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...userRisks.map(
                        (risk) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: TextStyle(color: Colors.red.shade900),
                              ),
                              Expanded(
                                child: Text(
                                  risk,
                                  style: TextStyle(color: Colors.red.shade900),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Details Section
            Text(
              l10n.scanDetails,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              l10n,
              l10n.dialogFrequency,
              frequency,
              isEstimated: isEstimatedFreq,
            ),
            _buildDetailRow(
              l10n,
              l10n.dialogInstructions,
              instructions.isEmpty ? 'See label' : instructions,
            ),
            if (displayLongDesc != null) ...[
              const SizedBox(height: 12),
              Text(
                l10n.scanAbout,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                displayLongDesc,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Add to My Meds

                // Create DrugInfo first
                final drugInfo = DrugInfo(
                  id: name.toLowerCase().replaceAll(RegExp(r'\s+'), '_'),
                  name: name,
                  type: type,
                  shortDescription: shortDesc,
                  longDescription: longDesc,
                  conflictDescription: conflictDesc,
                  statusReason: statusReason,
                  commonSideEffects: commonSideEffects,
                  shortDescriptionSimplified: shortDescSimple,
                  longDescriptionSimplified:
                      longDescSimple, // Ensure simple texts are saved
                  commonSideEffectsSimplified: commonSideEffectsSimple,
                  statusReasonSimplified: statusReasonSimple,
                  conflictDescriptionSimplified: conflictDescSimple,
                );

                final newMedication = Medication(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  drugInfo: drugInfo,
                  dosage: dosage,
                  frequency: frequency,
                  instructions: instructions,
                  status: status,
                  dateScanned: DateTime.now(),
                  userRisks: userRisks,
                  isEstimatedDosage: isEstimated,
                  isEstimatedFrequency: isEstimatedFreq, // Pass new field
                );

                context.read<MedicationProvider>().addMedication(newMedication);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.scanAddedToMeds)));

                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(l10n.scanAddToMeds),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    AppLocalizations l10n,
    String label,
    String value, {
    bool isEstimated = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isEstimated ? Colors.orange[800] : null,
                    ),
                  ),
                ),
                if (isEstimated) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.scanEstimated,
                    style: const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
