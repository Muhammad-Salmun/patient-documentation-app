import 'package:flutter/material.dart';
import 'package:surgery_doc/pages/anxiety_questionnaire_page.dart';
import 'package:surgery_doc/pages/edit_patient_page.dart';

class PatientDetailsPage extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientDetailsPage({Key? key, required this.patient}) : super(key: key);

  // Function to handle the Next button logic
  void _handleNextButton(BuildContext context) {
    // Navigate to the next questionnaire or stage if applicable
    if (patient['currentStage'] == 3 && patient['status'] == 'Completed') {
      // If it's Stage 3 and not completed, we do nothing or show a message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All stages has been completed.')),
      );
    } else {
      // Otherwise, move to the next stage or questionnaire
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnxietyQuestionnairePage(patient: patient),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current stage of the patient
    int currentStage = patient['currentStage'];

    return Scaffold(
      appBar: AppBar(
        title: Text('${patient['name']} Details'),
        actions: [
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPatientPage(patient: patient),
                  ),
                );
              } // Navigate to the edit page
              ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: ${patient['name']}', style: TextStyle(fontSize: 18)),
            Text('Sex: ${patient['sex']}', style: TextStyle(fontSize: 18)),
            Text('Phone Number: ${patient['phoneNumber']}',
                style: TextStyle(fontSize: 18)),
            Text('Illness: ${patient['illness']}',
                style: TextStyle(fontSize: 18)),
            Text('Description: ${patient['description']}',
                style: TextStyle(fontSize: 18)),
            Text('Surgery Due Date: ${patient['surgeryDueDate']}',
                style: TextStyle(fontSize: 18)),

            SizedBox(height: 20),

            // Show Stage 1 Data if the patient is in Stage 1 or later
            if (currentStage >= 1) ...[
              Text('Stage 1: Pre-Surgery',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                  'Anxiety Score Before Surgery: ${patient['anxietyScoreBeforeSurgery'] ?? "Not Provided"}',
                  style: TextStyle(fontSize: 18)),
              Text('Status: ${patient['status']}',
                  style: TextStyle(fontSize: 18)), // Show Status for Stage 1
            ],

            SizedBox(height: 20),
            // Show Stage 2 Data if the patient is in Stage 2 or later
            if (currentStage >= 2) ...[
              Text('Stage 2: Post-Surgery',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                  'Anxiety Score After Surgery: ${patient['anxietyScoreAfterSurgery'] ?? "Not Provided"}',
                  style: TextStyle(fontSize: 18)),
              Text('Status: ${patient['status']}',
                  style: TextStyle(fontSize: 18)), // Show Status for Stage 2
            ],

            SizedBox(height: 20),
            // Show Stage 3 Data if the patient is in Stage 3
            if (currentStage == 3) ...[
              Text('Stage 3: Quality of Life Assessment',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                  'Quality of Life Score: ${patient['qualityOfLifeScore'] ?? "Not Provided"}',
                  style: TextStyle(fontSize: 18)),
              Text('Status: ${patient['status']}',
                  style: TextStyle(fontSize: 18)), // Show Status for Stage 3
            ],

            SizedBox(height: 20),

            // show the "Next" button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleNextButton(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
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
