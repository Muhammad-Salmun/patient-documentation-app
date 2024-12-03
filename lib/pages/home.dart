import 'package:flutter/material.dart';
import 'package:surgery_doc/pages/add_patient_page.dart';
import 'package:surgery_doc/pages/patient_details_page.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> patientData;

  const HomePage({Key? key, required this.patientData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Patient List')),
      ),
      body: ListView.builder(
        itemCount: patientData['patients']?.length ?? 0,
        itemBuilder: (context, index) {
          final patient = patientData['patients'][index];
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PatientDetailsPage(
                            patient: patient,
                          )));
            },
            child: Card(
              margin: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 10,
              ),
              child: ListTile(
                title: Text(patient['name']),
                subtitle: Text(
                    'Stage: ${patient['currentStage']} - Status: ${patient['status']}'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddPatientPage(
                        existingPatients: patientData,
                      )));
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Patient',
      ),
    );
  }
}
