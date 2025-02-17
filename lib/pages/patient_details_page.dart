import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:surgery_doc/models/patient_model.dart';
import 'package:surgery_doc/pages/anxiety_questionnaire_page.dart';
import 'package:surgery_doc/pages/edit_patient_page.dart';
import 'package:surgery_doc/pages/quality_score_quistionnaire_page.dart';

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

  // Function to handle the Next button logic
  void _handleNextButton(BuildContext context) {
    if (patient.currentStage > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All stages have been completed.')),
      );
    } else if (patient.currentStage == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              QualityScoreQuestionnairePage(patientId: patient.id),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnxietyQuestionnairePage(
            patientId: patient.id,
          ),
        ),
      );
    }
  }

  Future<void> _refreshPatientData() async {
    try {
      // Fetch the patient data from Firestore
      DocumentSnapshot patientDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patient.id)
          .get();

      if (patientDoc.exists) {
        // Use the Patient.fromFirestore method to map the data
        setState(() {
          patient = Patient.fromFirestore(patientDoc);
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient data refreshed successfully.')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No patient found with this ID.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error refreshing data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentStage = patient.currentStage;

    return Scaffold(
      appBar: AppBar(
        title: Text('${patient.name} Details'),
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPatientPage(
                    patientId: patient.id,
                    name: patient.name,
                    age: patient.age,
                    phoneNumber: patient.phoneNumber,
                    illness: patient.illness,
                    address: patient.address,
                    surgeryDueDate: patient.surgeryDueDate,
                    sex: patient.sex,
                    byStanderName: patient.bystanderName,
                    relationToPatient: patient.relationToPatient,
                  ),
                ),
              );
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPatientData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: ${patient.name}', style: const TextStyle(fontSize: 18)),
            Text('Sex: ${patient.sex}', style: const TextStyle(fontSize: 18)),
            Text('Age: ${patient.age}'),
            Text('Phone Number: ${patient.phoneNumber}',
                style: const TextStyle(fontSize: 18)),
            Text('Illness: ${patient.illness}',
                style: const TextStyle(fontSize: 18)),
            Text('Address: ${patient.address}',
                style: const TextStyle(fontSize: 18)),
            Text('Surgery Due Date: ${patient.surgeryDueDate}',
                style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 20),

            // Show Stage 1 Data if the patient is in Stage 1 or later
            if (currentStage >= 1) ...[
              const Text('Stage 1: Pre-Surgery',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                  'Anxiety Score Before Surgery: ${patient.anxietyScoreBeforeSurgery ?? "Not Provided"}',
                  style: const TextStyle(fontSize: 18)),
              Text(
                  'Status: ${patient.currentStage == 1 ? 'Pending' : 'Completed'}',
                  style:
                      const TextStyle(fontSize: 18)), // Show Status for Stage 1
            ],

            const SizedBox(height: 20),
            // Show Stage 2 Data if the patient is in Stage 2 or later
            if (currentStage >= 2) ...[
              const Text('Stage 2: Post-Surgery',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                  'Anxiety Score After Surgery: ${patient.anxietyScoreAfterSurgery ?? "Not Provided"}',
                  style: const TextStyle(fontSize: 18)),
              Text(
                  'Status: ${patient.currentStage == 2 ? 'Pending' : 'Completed'}',
                  style:
                      const TextStyle(fontSize: 18)), // Show Status for Stage 2
            ],

            const SizedBox(height: 20),
            // Show Stage 3 Data if the patient is in Stage 3
            if (currentStage >= 3) ...[
              const Text('Stage 3: Quality of Life Assessment',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                  'Quality of Life Score: ${patient.qualityOfLifeScore ?? "Not Provided"}',
                  style: const TextStyle(fontSize: 18)),
              Text(
                  'Status: ${patient.currentStage == 3 ? 'Pending' : 'Completed'}',
                  style:
                      const TextStyle(fontSize: 18)), // Show Status for Stage 3
            ],

            const SizedBox(height: 20),

            // show the "Next" button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleNextButton(context),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Text(
                        'Next',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
