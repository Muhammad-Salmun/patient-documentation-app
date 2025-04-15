import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surgery_doc/models/patient_model.dart';
import 'package:surgery_doc/pages/add_patient_page.dart';
import 'package:surgery_doc/pages/patient_details_page.dart';

class HomePage extends StatefulWidget {
  final List<Patient> initialPatients;

  const HomePage({
    super.key,
    required this.initialPatients,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Patient> _patients;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  String selectedStageFilter = 'All';
  String selectedSexFilter = 'All';
  String selectedStatusFilter = 'All';

  final List<String> stageOptions = ['All', '1', '2', '3', '4'];
  final List<String> sexOptions = ['All', 'Male', 'Female', 'Other'];
  final List<String> statusOptions = ['All', 'Pending', 'Completed'];

  @override
  void initState() {
    super.initState();
    _patients = widget.initialPatients;
  }

  // Fetch patient data from Firestore
  Future<void> _fetchPatients() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .orderBy('name')
          .get();
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPatients = _patients.where((patient) {
      final matchesName =
          patient.name.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesStage = selectedStageFilter == 'All' ||
          patient.currentStage.toString() == selectedStageFilter;

      final matchesSex = selectedSexFilter == 'All' ||
          patient.sex.toLowerCase() == selectedSexFilter.toLowerCase();

      final matchesStatus = selectedStatusFilter == 'All' ||
          (selectedStatusFilter == 'Completed' && patient.currentStage == 4) ||
          (selectedStatusFilter == 'Pending' && patient.currentStage < 4);

      return matchesName && matchesStage && matchesSex && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient List'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPatients,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search by name...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(18.0))),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  // filter panel
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Filters',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  selectedStageFilter = 'All';
                                  selectedSexFilter = 'All';
                                  selectedStatusFilter = 'All';
                                  searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text("Reset Filters"),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Stage Filter
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Stage",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedStageFilter,
                                    items: stageOptions.map((stage) {
                                      return DropdownMenuItem(
                                        value: stage,
                                        child: Text(stage == 'All'
                                            ? 'All'
                                            : 'Stage $stage'),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(
                                          () => selectedStageFilter = value!);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Sex Filter
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Sex",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedSexFilter,
                                    items: sexOptions.map((sex) {
                                      return DropdownMenuItem(
                                        value: sex,
                                        child: Text(sex),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(
                                          () => selectedSexFilter = value!);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Status Filter
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Status",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedStatusFilter,
                                    items: statusOptions.map((status) {
                                      return DropdownMenuItem(
                                        value: status,
                                        child: Text(status),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(
                                          () => selectedStatusFilter = value!);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // List of patients
                  Expanded(
                    child: filteredPatients.isEmpty
                        ? const Center(child: Text('No patients found.'))
                        : ListView.builder(
                            itemCount: filteredPatients.length,
                            itemBuilder: (context, index) {
                              final patient = filteredPatients[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      patient.name[0].toUpperCase(),
                                    ),
                                  ),
                                  title: Text(patient.name),
                                  subtitle: Text(
                                      'Stage: ${patient.currentStage > 3 ? 3 : patient.currentStage} - Status: ${patient.currentStage == 4 ? 'Completed' : 'Pending'}'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PatientDetailsPage(
                                                patient: patient),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
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
