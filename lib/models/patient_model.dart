import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id; // Firestore document ID
  final String name;
  final String sex;
  final String bystanderName;
  final String relationToPatient;
  final String phoneNumber;
  final String illness;
  final String address;
  final String surgeryDueDate;
  final int currentStage;
  final int? anxietyScoreBeforeSurgery;
  final int? anxietyScoreAfterSurgery;
  final int? qualityOfLifeScore;

  Patient({
    required this.id,
    required this.name,
    required this.sex,
    required this.bystanderName,
    required this.relationToPatient,
    required this.phoneNumber,
    required this.illness,
    required this.address,
    required this.surgeryDueDate,
    required this.currentStage,
    this.anxietyScoreBeforeSurgery,
    this.anxietyScoreAfterSurgery,
    this.qualityOfLifeScore,
  });

  factory Patient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Patient(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      sex: data['sex'] ?? 'Unknown',
      bystanderName: data['bystanderName'] ?? 'Unknown',
      relationToPatient: data['relationToPatient'] ?? 'Unknown',
      phoneNumber: data['phoneNumber'] ?? 'Unknown',
      illness: data['illness'] ?? 'Unknown',
      address: data['address'] ?? 'Unknown',
      surgeryDueDate: data['surgeryDueDate'] ?? 'Unknown',
      currentStage: data['currentStage'] ?? 1,
      anxietyScoreBeforeSurgery: data['anxietyScoreBeforeSurgery'],
      anxietyScoreAfterSurgery: data['anxietyScoreAfterSurgery'],
      qualityOfLifeScore: data['qualityOfLifeScore'],
    );
  }
}
