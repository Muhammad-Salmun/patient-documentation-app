import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surgery_doc/models/patient_model.dart';
import 'package:surgery_doc/pages/add_patient_page.dart';
import 'package:surgery_doc/pages/patient_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Patient> _patients;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients(); // Initial fetch
  }

  // Fetch patient data from Firestore
  Future<void> _fetchPatients() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('patients').get();
      _patients =
          querySnapshot.docs.map((doc) => Patient.fromFirestore(doc)).toList();
    } catch (e) {
      // print('Error fetching patients: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to fetch data. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient List'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPatients, // Trigger refresh on pull-down
              child: ListView.builder(
                itemCount: _patients.length,
                itemBuilder: (context, index) {
                  final patient = _patients[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(patient.name),
                      subtitle: Text(
                          'Stage: ${patient.currentStage > 3 ? 3 : patient.currentStage} - Status: ${patient.currentStage == 4 ? 'Completed' : 'Pending'}'),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PatientDetailsPage(patient: patient)));
                        // Navigate to patient details (implement PatientDetailsPage)
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddPatientPage()));
        },
        tooltip: 'Add Patient',
        child: const Icon(Icons.add),
      ),
    );
  }
}
