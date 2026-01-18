import 'package:equatable/equatable.dart';
import 'drug_info.dart';

// Export status and type so we don't break existing imports relying on them being here
export 'drug_info.dart' show MedicationStatus, MedicationType;

class Medication extends Equatable {
  final String id; // Unique instance ID
  final DrugInfo drugInfo; // Reference to shared drug data

  // User-specific fields
  final String dosage;
  final String frequency;
  final String instructions;
  final DateTime dateScanned;
  final List<String> userRisks;

  // Estimation flags
  final bool isEstimatedDosage;
  final bool isEstimatedFrequency;

  // Status for this specific user (conflicts are user-specific)
  final MedicationStatus status;

  const Medication({
    required this.id,
    required this.drugInfo,
    required this.dosage,
    required this.frequency,
    required this.instructions,
    required this.status,
    required this.dateScanned,
    this.userRisks = const [],
    this.isEstimatedDosage = false,
    this.isEstimatedFrequency = false,
  });

  // Proxy getters for convenience
  String get name => drugInfo.name;
  MedicationType get type => drugInfo.type;
  String? get shortDescription => drugInfo.shortDescription;
  String? get longDescription => drugInfo.longDescription;
  String? get conflictDescription => drugInfo.conflictDescription;
  String? get statusReason => drugInfo.statusReason;
  List<String> get commonSideEffects => drugInfo.commonSideEffects;

  // Simplified versions for "Explain Like I'm 12" mode
  String? get shortDescriptionSimplified => drugInfo.shortDescriptionSimplified;
  String? get longDescriptionSimplified => drugInfo.longDescriptionSimplified;
  List<String>? get commonSideEffectsSimplified =>
      drugInfo.commonSideEffectsSimplified;
  String? get statusReasonSimplified => drugInfo.statusReasonSimplified;
  String? get conflictDescriptionSimplified =>
      drugInfo.conflictDescriptionSimplified;

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      drugInfo: DrugInfo.fromJson(json['drugInfo'] as Map<String, dynamic>),
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      instructions: json['instructions'] as String,
      status: MedicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MedicationStatus.safe,
      ),
      dateScanned: DateTime.parse(json['dateScanned'] as String),
      userRisks:
          (json['userRisks'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isEstimatedDosage: json['isEstimatedDosage'] == true,
      isEstimatedFrequency: json['isEstimatedFrequency'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'drugInfo': drugInfo.toJson(),
      'dosage': dosage,
      'frequency': frequency,
      'instructions': instructions,
      'status': status.name,
      'dateScanned': dateScanned.toIso8601String(),
      'userRisks': userRisks,
      'isEstimatedDosage': isEstimatedDosage,
      'isEstimatedFrequency': isEstimatedFrequency,
    };
  }

  @override
  List<Object?> get props => [
    id,
    drugInfo,
    dosage,
    frequency,
    instructions,
    status,
    dateScanned,
    userRisks,
    isEstimatedDosage,
    isEstimatedFrequency,
  ];
}
