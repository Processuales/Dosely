import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/medication.dart';
import '../../widgets/read_aloud_button.dart';

/// Screen showing medication information and side effects
class MedicationInformationScreen extends StatefulWidget {
  final Medication medication;

  const MedicationInformationScreen({super.key, required this.medication});

  @override
  State<MedicationInformationScreen> createState() =>
      _MedicationInformationScreenState();
}

class _MedicationInformationScreenState
    extends State<MedicationInformationScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final m = widget.medication;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: const Border(
                  bottom: BorderSide(color: AppTheme.border, width: 1),
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Information',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: ReadAloudButton(),
                  ),
                ],
              ),
            ),

            // Medication Info Summary
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.name,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  if (m.shortDescription != null)
                    Text(
                      m.shortDescription!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Icon(
                          Icons.schedule,
                          size: 18,
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${m.frequency} • ${m.instructions}'.replaceAll(
                            '. ',
                            '.\n',
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  _buildTabButton(0, l10n.sideEffectsCommon),
                  _buildTabButton(1, l10n.sideEffectsSerious),
                  _buildTabButton(2, l10n.sideEffectsHelp),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildTabContent(l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(AppLocalizations l10n) {
    switch (_selectedTab) {
      case 0: // Common
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.sideEffectsCommon.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.medication.commonSideEffects.isEmpty)
              const Text('No common side effects listed.')
            else
              ...widget.medication.commonSideEffects.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildSideEffectCard(
                    context,
                    Icons.sentiment_neutral,
                    e,
                    '', // Frequency unknown usually from general list
                    '', // Description unknown
                  ),
                ),
              ),
            _buildSourceLink(context),
            const SizedBox(height: 32),
          ],
        );

      case 1: // Serious
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.statusConflictBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.statusConflict),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: AppTheme.statusConflict,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'If you experience these symptoms, seek medical help immediately.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.statusConflict,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // User Risks
            if (widget.medication.userRisks.isNotEmpty) ...[
              Text(
                'Specific Risks for You',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.statusConflict,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.medication.userRisks.map(
                (risk) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSideEffectCard(
                    context,
                    Icons.warning_amber,
                    'Risk Alert',
                    'Specific to you',
                    risk,
                    isSerious: true,
                  ),
                ),
              ),
            ],
            // Generic Serious (Static for now as model doesn't have list)
            // Or maybe we treat conflictDescription as serious
            if (widget.medication.conflictDescription != null)
              _buildSideEffectCard(
                context,
                Icons.block,
                'Conflict Detected',
                'Serious',
                widget.medication.conflictDescription!,
                isSerious: true,
              ),

            _buildSourceLink(context),
            const SizedBox(height: 32),
          ],
        );

      case 2: // Help
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get Professional Advice',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'If you are concerned about any side effects, contact your healthcare provider.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.call),
              label: Text(l10n.sideEffectsCallPharmacist),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.emergency),
              label: Text(l10n.sideEffectsEmergency),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusConflict,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            _buildSourceLink(context),
            const SizedBox(height: 32),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSourceLink(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Source: AI Analysis & General Medical Data',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.open_in_new, size: 14, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
            border: isSelected ? Border.all(color: AppTheme.border) : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isSelected ? AppTheme.primary : AppTheme.textLight,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSideEffectCard(
    BuildContext context,
    IconData icon,
    String title,
    String frequency,
    String description, {
    bool isSerious = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    if (frequency.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceAlt,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(
                          frequency,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
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
