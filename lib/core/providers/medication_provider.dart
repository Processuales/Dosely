import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../models/drug_info.dart';
import '../services/storage_service.dart';

class MedicationProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<Medication> _medications = [];
  Map<String, DrugInfo> _drugLibrary = {}; // Cache of persistent drug info
  bool _isLoading = false;

  MedicationProvider(this._storageService);

  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading;

  Future<void> loadMedications() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load library first
      final libraryList = _storageService.loadDrugLibrary();
      _drugLibrary = {for (var d in libraryList) d.id: d};

      // Then load user medications
      _medications = _storageService.loadMedications();

      // OPTIONAL: Re-link medications to library instances to ensure object identity?
      // For now, relying on value equality of DrugInfo is fine, but if we updated the library,
      // we might want to refresh the user's meds with the latest info.
      // Let's do a pass to update user meds with library versions if available.
      bool structureUpdated = false;
      for (int i = 0; i < _medications.length; i++) {
        final med = _medications[i];
        if (_drugLibrary.containsKey(med.drugInfo.id)) {
          final libInfo = _drugLibrary[med.drugInfo.id]!;
          if (med.drugInfo != libInfo) {
            // Update med to use library version
            _medications[i] = Medication(
              id: med.id,
              drugInfo: libInfo, // Use library version
              dosage: med.dosage,
              frequency: med.frequency,
              instructions: med.instructions,
              status: med.status,
              dateScanned: med.dateScanned,
              userRisks: med.userRisks,
              isEstimatedDosage: med.isEstimatedDosage,
              isEstimatedFrequency: med.isEstimatedFrequency,
            );
            structureUpdated = true;
          }
        } else {
          // Med exists in user list but not library (shouldn't happen, but add it back)
          _drugLibrary[med.drugInfo.id] = med.drugInfo;
          await _saveDrugLibrary();
        }
      }

      if (structureUpdated) {
        await _saveMedications();
      }
    } catch (e) {
      debugPrint('Error loading medications: $e');
      _medications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a medication.
  /// If the drug info already exists in the library, we reuse it (or update it?).
  /// The requirement says "if the same medicine it doesn't break it... stays consistent".
  Future<void> addMedication(Medication medication) async {
    final drugId = medication.drugInfo.id;

    DrugInfo effectiveDrugInfo = medication.drugInfo;

    // Check if we already know this drug
    if (_drugLibrary.containsKey(drugId)) {
      final existing = _drugLibrary[drugId]!;

      // Merge logic: prefer existing immutable data, but UPDATE preferences (frequency/instructions)
      // If the user provided new frequency/instructions in this 'add', treat them as the new default.
      effectiveDrugInfo = DrugInfo(
        id: existing.id,
        name: existing.name,
        type: existing.type,
        shortDescription: existing.shortDescription,
        longDescription: existing.longDescription,
        conflictDescription: existing.conflictDescription,
        commonSideEffects: existing.commonSideEffects,
        defaultDosage: existing.defaultDosage,
        // Update last known preferences
        lastKnownFrequency: medication.frequency,
        lastKnownInstructions: medication.instructions,
      );

      // Update the library with these new preferences
      _drugLibrary[drugId] = effectiveDrugInfo;
      await _saveDrugLibrary();
    } else {
      // New drug. Add to library with current freq/inst as defaults
      effectiveDrugInfo = DrugInfo(
        id: medication.drugInfo.id,
        name: medication.drugInfo.name,
        type: medication.drugInfo.type,
        shortDescription: medication.drugInfo.shortDescription,
        longDescription: medication.drugInfo.longDescription,
        conflictDescription: medication.drugInfo.conflictDescription,
        commonSideEffects: medication.drugInfo.commonSideEffects,
        defaultDosage: medication.drugInfo.defaultDosage,
        lastKnownFrequency: medication.frequency,
        lastKnownInstructions: medication.instructions,
      );

      _drugLibrary[drugId] = effectiveDrugInfo;
      await _saveDrugLibrary();
    }

    final newMedication = Medication(
      id: medication.id,
      drugInfo: effectiveDrugInfo, // Ensure we use the consistent one
      dosage: medication.dosage,
      frequency: medication.frequency,
      instructions: medication.instructions,
      status: medication.status,
      dateScanned: medication.dateScanned,
      userRisks: medication.userRisks,
      isEstimatedDosage: medication.isEstimatedDosage,
      isEstimatedFrequency: medication.isEstimatedFrequency,
    );

    _medications.add(newMedication);
    await _saveMedications();
  }

  Future<void> removeMedication(String id) async {
    // Only remove from user list. The DrugInfo remains in _drugLibrary and Storage.
    _medications.removeWhere((m) => m.id == id);
    await _saveMedications();
  }

  /// Clears all medications (used for "Clear Scan History")
  Future<void> clearAll() async {
    _medications.clear();
    await _saveMedications();
  }

  /// Helper to find existing drug info if any
  DrugInfo? getDrugInfo(String id) {
    return _drugLibrary[id];
  }

  Future<void> _saveMedications() async {
    try {
      await _storageService.saveMedications(_medications);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving medications: $e');
    }
  }

  Future<void> _saveDrugLibrary() async {
    try {
      await _storageService.saveDrugLibrary(_drugLibrary.values.toList());
    } catch (e) {
      debugPrint('Error saving drug library: $e');
    }
  }

  /// Simplifies all medication info for "Explain Like I'm 12" mode
  /// Returns true if any medications were updated
  Future<bool> simplifyAllMedications(
    Future<Map<String, dynamic>> Function({
      required String shortDescription,
      required String longDescription,
      required List<String> commonSideEffects,
      List<String>? userRisks,
      String? statusReason,
      String? conflictDescription,
      String languageCode,
    })
    simplifyFunction, {
    String languageCode = 'en',
  }) async {
    bool anyUpdated = false;

    for (final drugId in _drugLibrary.keys.toList()) {
      final drug = _drugLibrary[drugId]!;

      // Skip if already has simplified versions
      if (drug.shortDescriptionSimplified != null) continue;

      // Skip if no descriptions to simplify
      if (drug.shortDescription == null && drug.longDescription == null)
        continue;

      try {
        final simplified = await simplifyFunction(
          shortDescription: drug.shortDescription ?? '',
          longDescription: drug.longDescription ?? '',
          commonSideEffects: drug.commonSideEffects,
          statusReason: drug.statusReason,
          conflictDescription: drug.conflictDescription,
          languageCode: languageCode,
        );

        if (simplified.isNotEmpty) {
          _drugLibrary[drugId] = DrugInfo(
            id: drug.id,
            name: drug.name,
            type: drug.type,
            shortDescription: drug.shortDescription,
            longDescription: drug.longDescription,
            conflictDescription: drug.conflictDescription,
            statusReason: drug.statusReason,
            commonSideEffects: drug.commonSideEffects,
            shortDescriptionSimplified:
                simplified['shortDescriptionSimplified'] as String?,
            longDescriptionSimplified:
                simplified['longDescriptionSimplified'] as String?,
            commonSideEffectsSimplified:
                (simplified['commonSideEffectsSimplified'] as List?)
                    ?.map((e) => e.toString())
                    .toList(),
            statusReasonSimplified:
                simplified['statusReasonSimplified'] as String?,
            conflictDescriptionSimplified:
                simplified['conflictDescriptionSimplified'] as String?,
            defaultDosage: drug.defaultDosage,
            lastKnownFrequency: drug.lastKnownFrequency,
            lastKnownInstructions: drug.lastKnownInstructions,
          );
          anyUpdated = true;
        }
      } catch (e) {
        debugPrint('Error simplifying ${drug.name}: $e');
      }
    }

    if (anyUpdated) {
      await _saveDrugLibrary();

      // Update medications to use new drug info
      for (int i = 0; i < _medications.length; i++) {
        final med = _medications[i];
        if (_drugLibrary.containsKey(med.drugInfo.id)) {
          _medications[i] = Medication(
            id: med.id,
            drugInfo: _drugLibrary[med.drugInfo.id]!,
            dosage: med.dosage,
            frequency: med.frequency,
            instructions: med.instructions,
            status: med.status,
            dateScanned: med.dateScanned,
            userRisks: med.userRisks,
            isEstimatedDosage: med.isEstimatedDosage,
            isEstimatedFrequency: med.isEstimatedFrequency,
          );
        }
      }
      await _saveMedications();
      notifyListeners();
    }

    return anyUpdated;
  }

  /// Translates all medication info to the target language
  Future<bool> translateAllMedications(
    Future<List<String>> Function(List<String>, String) translateFunction,
    String targetLanguage,
  ) async {
    if (_drugLibrary.isEmpty) return false;

    bool anyUpdated = false;

    for (final drugId in _drugLibrary.keys) {
      final drug = _drugLibrary[drugId]!;
      try {
        // Collect all translatable strings
        final textsToTranslate = <String>[
          drug.name,
          drug.shortDescription ?? '',
          drug.longDescription ?? '',
          ...drug.commonSideEffects,
        ];

        // Translate
        final translated = await translateFunction(
          textsToTranslate.where((s) => s.isNotEmpty).toList(),
          targetLanguage,
        );

        if (translated.isNotEmpty) {
          int idx = 0;
          final translatedName =
              idx < translated.length ? translated[idx++] : drug.name;
          final translatedShort =
              drug.shortDescription != null && idx < translated.length
                  ? translated[idx++]
                  : drug.shortDescription;
          final translatedLong =
              drug.longDescription != null && idx < translated.length
                  ? translated[idx++]
                  : drug.longDescription;
          final translatedSideEffects = <String>[];
          for (
            var i = 0;
            i < drug.commonSideEffects.length && idx < translated.length;
            i++
          ) {
            translatedSideEffects.add(translated[idx++]);
          }

          _drugLibrary[drugId] = DrugInfo(
            id: drug.id,
            name: translatedName,
            type: drug.type,
            shortDescription: translatedShort,
            longDescription: translatedLong,
            conflictDescription: drug.conflictDescription,
            commonSideEffects:
                translatedSideEffects.isNotEmpty
                    ? translatedSideEffects
                    : drug.commonSideEffects,
            defaultDosage: drug.defaultDosage,
            lastKnownFrequency: drug.lastKnownFrequency,
            lastKnownInstructions: drug.lastKnownInstructions,
          );
          anyUpdated = true;
        }
      } catch (e) {
        debugPrint('Error translating ${drug.name}: $e');
      }
    }

    if (anyUpdated) {
      await _saveDrugLibrary();

      // Update medications to use new drug info
      for (int i = 0; i < _medications.length; i++) {
        final med = _medications[i];
        if (_drugLibrary.containsKey(med.drugInfo.id)) {
          _medications[i] = Medication(
            id: med.id,
            drugInfo: _drugLibrary[med.drugInfo.id]!,
            dosage: med.dosage,
            frequency: med.frequency,
            instructions: med.instructions,
            status: med.status,
            dateScanned: med.dateScanned,
            userRisks: med.userRisks,
            isEstimatedDosage: med.isEstimatedDosage,
            isEstimatedFrequency: med.isEstimatedFrequency,
          );
        }
      }
      await _saveMedications();
      notifyListeners();
    }

    return anyUpdated;
  }
}
