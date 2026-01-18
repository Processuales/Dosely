import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/profile.dart';
import '../../core/theme/app_theme.dart';

/// Simplified Medical Profile Dialog - Manual add/remove only
class MedicalProfileDialog extends StatefulWidget {
  final UserProfile? initialProfile;

  const MedicalProfileDialog({super.key, this.initialProfile});

  @override
  State<MedicalProfileDialog> createState() => _MedicalProfileDialogState();
}

class _MedicalProfileDialogState extends State<MedicalProfileDialog> {
  late List<String> _allergies;
  late List<String> _conditions;

  final _allergyController = TextEditingController();
  final _conditionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allergies = List.from(widget.initialProfile?.allergies ?? []);
    _conditions = List.from(widget.initialProfile?.conditions ?? []);
  }

  @override
  void dispose() {
    _allergyController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

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
          Text(l10n.profileMedicalProfile),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            final updatedProfile =
                widget.initialProfile?.copyWith(
                  allergies: _allergies,
                  conditions: _conditions,
                ) ??
                UserProfile.empty().copyWith(
                  allergies: _allergies,
                  conditions: _conditions,
                );

            Navigator.of(context).pop(updatedProfile);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
