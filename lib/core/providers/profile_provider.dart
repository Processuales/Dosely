import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  final StorageService _storageService;
  UserProfile _profile = UserProfile.empty();
  bool _isLoading = false;

  ProfileProvider(this._storageService);

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = _storageService.loadProfile();
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    _profile = newProfile;
    await _saveProfile();
  }

  Future<void> _saveProfile() async {
    try {
      await _storageService.saveProfile(_profile);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }

  Future<void> translateProfileData(
    Future<List<String>> Function(List<String>) translator,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool changed = false;
      if (_profile.allergies.isNotEmpty) {
        final translatedAllergies = await translator(_profile.allergies);
        _profile = _profile.copyWith(allergies: translatedAllergies);
        changed = true;
      }
      if (_profile.conditions.isNotEmpty) {
        final translatedConditions = await translator(_profile.conditions);
        _profile = _profile.copyWith(conditions: translatedConditions);
        changed = true;
      }

      if (changed) {
        await _saveProfile();
      }
    } catch (e) {
      debugPrint('Error translating profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
