import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/models/medication.dart';
import '../../widgets/read_aloud_button.dart';

class MedicationDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> scanData;
  final XFile imageFile;

  const MedicationDetailsScreen({
    super.key,
    required this.scanData,
    required this.imageFile,
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
    final userRisks = (scanData['userRisks'] as List?)?.cast<String>() ?? [];
    final conflictDesc = scanData['conflictDescription'];
    final shortDesc = scanData['shortDescription'];
    final longDesc = scanData['longDescription'];
    final commonSideEffects =
        (scanData['commonSideEffects'] as List?)?.cast<String>() ?? [];
    final statusStr = scanData['status'] ?? 'safe';

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
        title: const Text('Scan Result'),
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
                            const Text(
                              '(Estimated)',
                              style: TextStyle(
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

            if (shortDesc != null) ...[
              const SizedBox(height: 16),
              Text(shortDesc, style: Theme.of(context).textTheme.bodyLarge),
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
                          'Risks & Conflicts',
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    if (conflictDesc != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        conflictDesc,
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
            Text('Details', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildDetailRow('Frequency', frequency),
            _buildDetailRow(
              'Instructions',
              instructions.isEmpty ? 'See label' : instructions,
            ),
            if (longDesc != null) ...[
              const SizedBox(height: 12),
              Text(
                'About this medication',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                longDesc,
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
                final newMedication = Medication(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  dosage: dosage,
                  frequency: frequency,
                  instructions: instructions,
                  status: status,
                  dateScanned: DateTime.now(),
                  type: type,
                  shortDescription: shortDesc,
                  longDescription: longDesc,
                  userRisks: userRisks,
                  conflictDescription: conflictDesc,
                  isEstimatedDosage: isEstimated,
                  commonSideEffects: commonSideEffects,
                );

                context.read<MedicationProvider>().addMedication(newMedication);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to My Meds')),
                );

                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Add to My Meds'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
