import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication.dart';
import '../models/profile.dart';
import '../models/schedule_item.dart';

class StorageService {
  final SharedPreferences _prefs;

  static const String _keyProfile = 'user_profile';
  static const String _keyMedications = 'medications';
  static const String _keySchedule = 'schedule';

  StorageService(this._prefs);

  // --- Profile ---

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
  }

  UserProfile loadProfile() {
    final String? data = _prefs.getString(_keyProfile);
    if (data == null) {
      return UserProfile.empty();
    }
    try {
      return UserProfile.fromJson(jsonDecode(data));
    } catch (e) {
      // Return empty if parse error
      return UserProfile.empty();
    }
  }

  // --- Medications ---

  Future<void> saveMedications(List<Medication> medications) async {
    final List<Map<String, dynamic>> jsonList =
        medications.map((m) => m.toJson()).toList();
    await _prefs.setString(_keyMedications, jsonEncode(jsonList));
  }

  List<Medication> loadMedications() {
    final String? data = _prefs.getString(_keyMedications);
    if (data == null) {
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => Medication.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // --- Schedule ---

  Future<void> saveSchedule(List<ScheduleItem> schedule) async {
    final List<Map<String, dynamic>> jsonList =
        schedule.map((s) => s.toJson()).toList();
    await _prefs.setString(_keySchedule, jsonEncode(jsonList));
  }

  List<ScheduleItem> loadSchedule() {
    final String? data = _prefs.getString(_keySchedule);
    if (data == null) {
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => ScheduleItem.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
