import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../services/storage_service.dart';

class MedicationProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<Medication> _medications = [];
  bool _isLoading = false;

  MedicationProvider(this._storageService);

  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading;

  Future<void> loadMedications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _medications = _storageService.loadMedications();
    } catch (e) {
      debugPrint('Error loading medications: $e');
      _medications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMedication(Medication medication) async {
    _medications.add(medication);
    await _saveMedications();
  }

  Future<void> removeMedication(String id) async {
    _medications.removeWhere((m) => m.id == id);
    await _saveMedications();
  }

  Future<void> _saveMedications() async {
    try {
      await _storageService.saveMedications(_medications);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving medications: $e');
    }
  }
}
