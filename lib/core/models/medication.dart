import 'package:equatable/equatable.dart';

enum MedicationStatus { safe, caution, conflict }

enum MedicationType { tablet, liquid, injection, inhaler, other }

class Medication extends Equatable {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String instructions;
  final MedicationStatus status;
  final DateTime dateScanned;
  final MedicationType type;

  // New AI analysis fields
  final String? shortDescription;
  final String? longDescription;
  final List<String> userRisks;
  final String? conflictDescription;
  final bool isEstimatedDosage;

  final List<String> commonSideEffects; // New field

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.instructions,
    required this.status,
    required this.dateScanned,
    this.type = MedicationType.tablet,
    this.userRisks = const [],
    this.shortDescription,
    this.longDescription,
    this.conflictDescription,
    this.isEstimatedDosage = false,
    this.commonSideEffects = const [], // Default empty
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      instructions: json['instructions'] as String,
      status: MedicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MedicationStatus.safe,
      ),
      dateScanned: DateTime.parse(json['dateScanned'] as String),
      type: MedicationType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'tablet'),
        orElse: () => MedicationType.tablet,
      ),
      userRisks:
          (json['userRisks'] as List?)?.map((e) => e.toString()).toList() ?? [],
      shortDescription: json['shortDescription'] as String?,
      longDescription: json['longDescription'] as String?,
      conflictDescription: json['conflictDescription'] as String?,
      isEstimatedDosage: json['isEstimatedDosage'] == true,
      commonSideEffects:
          (json['commonSideEffects'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'instructions': instructions,
      'status': status.name,
      'dateScanned': dateScanned.toIso8601String(),
      'type': type.name,
      'userRisks': userRisks,
      'shortDescription': shortDescription,
      'longDescription': longDescription,
      'conflictDescription': conflictDescription,
      'isEstimatedDosage': isEstimatedDosage,
      'commonSideEffects': commonSideEffects,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    dosage,
    frequency,
    instructions,
    status,
    dateScanned,
    type,
    userRisks,
    shortDescription,
    longDescription,
    conflictDescription,
    isEstimatedDosage,
    commonSideEffects,
  ];
}
