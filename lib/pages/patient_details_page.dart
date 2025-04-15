import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surgery_doc/models/patient_model.dart';
import 'package:surgery_doc/pages/anxiety_questionnaire_page.dart';
import 'package:surgery_doc/pages/quality_score_quistionnaire_page.dart';
import 'package:surgery_doc/pages/edit_patient_page.dart';

class PatientDetailsPage extends StatefulWidget {
  final Patient patient;

  const PatientDetailsPage({Key? key, required this.patient}) : super(key: key);

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  late Patient patient;

  @override
  void initState() {
    super.initState();
    patient = widget.patient;
  }

  Future<void> _refreshPatientData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patient.id)
          .get();
      if (doc.exists) {
        setState(() {
          patient = Patient.fromFirestore(doc);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient data refreshed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _handleNextStage() async {
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Proceed to Next Stage?'),
        content: const Text(
            'Are you sure you want to continue to the next stage? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Proceed'),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;

    // Proceed to next stage after confirmation
    if (!mounted) return;
    if (patient.currentStage > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All stages completed')),
      );
    } else if (patient.currentStage == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QualityScoreQuestionnairePage(patientId: patient.id),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnxietyQuestionnairePage(patientId: patient.id),
        ),
      );
    }
  }

  Widget _buildInfoTile(String label, String value, {IconData? icon}) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: Text(label),
      subtitle: Text(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${patient.name} Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPatientPage(
                    patientId: patient.id,
                    name: patient.name,
                    age: patient.age,
                    phoneNumber: patient.phoneNumber,
                    illness: patient.illness,
                    address: patient.address,
                    surgeryDueDate: patient.surgeryDueDate,
                    sex: patient.sex,
                    byStanderName: patient.bystanderName,
                    relationshipToPatient: patient.relationshipToPatient,
                  ),
                ),
              );
            },
          ),
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _refreshPatientData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPatientData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ExpansionTile(
              title: const Text('Personal Info'),
              initiallyExpanded: true,
              children: [
                _buildInfoTile('Name', patient.name, icon: Icons.person),
                _buildInfoTile('Sex', patient.sex,
                    icon: patient.sex == 'Male' ? Icons.male : Icons.female),
                _buildInfoTile('Age', patient.age, icon: Icons.numbers),
                _buildInfoTile('Phone Number', patient.phoneNumber,
                    icon: Icons.phone),
              ],
            ),
            ExpansionTile(
              title: const Text('Surgery Info'),
              children: [
                _buildInfoTile('Illness', patient.illness),
                _buildInfoTile('Address', patient.address),
                _buildInfoTile('Surgery Due Date', patient.surgeryDueDate),
                _buildInfoTile('Bystander Name', patient.bystanderName),
                _buildInfoTile(
                    'Relation to Patient', patient.relationshipToPatient),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Progress:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (patient.currentStage >= 1)
              Card(
                child: ListTile(
                  title: const Text('Stage 1: Pre-Surgery'),
                  subtitle: Text(
                    'Anxiety Score Before Surgery: ${patient.anxietyScoreBeforeSurgery ?? "Not Provided"}',
                  ),
                  trailing: Chip(
                      label: Text(
                          patient.currentStage == 1 ? 'Pending' : 'Completed')),
                ),
              ),
            if (patient.currentStage >= 2)
              Card(
                child: ListTile(
                  title: const Text('Stage 2: Post-Surgery'),
                  subtitle: Text(
                    'Anxiety Score After Surgery: ${patient.anxietyScoreAfterSurgery ?? "Not Provided"}',
                  ),
                  trailing: Chip(
                      label: Text(
                          patient.currentStage == 2 ? 'Pending' : 'Completed')),
                ),
              ),
            if (patient.currentStage >= 3)
              Card(
                child: ListTile(
                  title: const Text('Stage 3: Quality of Life'),
                  subtitle: Text(
                    'Quality of Life Score: ${patient.qualityOfLifeScore ?? "Not Provided"}',
                  ),
                  trailing: Chip(
                      label: Text(
                          patient.currentStage == 3 ? 'Pending' : 'Completed')),
                ),
              ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _handleNextStage,
              icon: const Icon(Icons.navigate_next),
              label: const Text('Next Stage', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            )
          ],
        ),
      ),
    );
  }
}
