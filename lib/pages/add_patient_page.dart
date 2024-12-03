import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:surgery_doc/components/textfeild.dart';

enum Gender { male, female, other }

class AddPatientPage extends StatefulWidget {
  final Map<String, dynamic> existingPatients;
  const AddPatientPage({Key? key, required this.existingPatients})
      : super(key: key);

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();

  // Declare TextEditingControllers for each input field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _illnessController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _surgeryDueDateController =
      TextEditingController();

  // Function to get the path to the local file
  Future<String> _getLocalFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/patients.json';
  }

  // Function to save new patient data to the JSON file

  Future<void> _savePatientData() async {
    if (_formKey.currentState!.validate()) {
      // Get data directly from the controllers
      String name = _nameController.text;
      String sex = _sexController.text;
      String phoneNumber = _phoneNumberController.text;
      String illness = _illnessController.text;
      String description = _descriptionController.text;
      String surgeryDueDate = _surgeryDueDateController.text;

      // Get the current list of patients
      List<dynamic> patients =
          List.from(widget.existingPatients['patients'] ?? []);

      // Generate new patient data
      final newPatient = {
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "name": name,
        "sex": sex,
        "phoneNumber": phoneNumber,
        "illness": illness,
        "description": description,
        "surgeryDueDate": surgeryDueDate,
        "currentStage": 1,
        "status": "Pending",
        "anxietyScoreBeforeSurgery": null,
        "anxietyScoreAfterSurgery": null,
        "qualityOfLifeScore": null
      };

      // Add the new patient to the existing list
      patients.add(newPatient);

      // Save the updated list back to the JSON file
      try {
        final filePath = await _getLocalFilePath();
        final file = File(filePath);
        final data = json.encode({"patients": patients});
        await file.writeAsString(data);
      } catch (e) {
        print("Error saving patient data: $e");
      }

      // Return to the home page after saving
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Patient'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomTextFeild(
                controller: _nameController,
                hintText: 'Name',
              ),
              _buildGenderDropdown(),
              CustomTextFeild(
                controller: _phoneNumberController,
                hintText: 'Phone Number',
              ),
              CustomTextFeild(
                controller: _illnessController,
                hintText: 'Illness',
              ),
              CustomTextFeild(
                controller: _descriptionController,
                hintText: 'Description',
              ),
              CustomTextFeild(
                  controller: _surgeryDueDateController,
                  hintText: 'Surgery Due Date'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _savePatientData,
                  child: Text('Save Patient'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String selectedGender = 'Male'; // Store the selected gender here

  Widget _buildGenderDropdown() {
    List<String> genderOptions = ['Male', 'Female', 'Other'];

    return DropdownButtonFormField<String>(
      value: selectedGender,
      onChanged: (String? newValue) {
        setState(() {
          selectedGender = newValue!;
        });
      },
      items: genderOptions.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Centaur',
              fontSize: 16,
            ),
          ),
        );
      }).toList(),
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        hintText: 'Gender',
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers when the page is closed
    _nameController.dispose();
    _sexController.dispose();
    _phoneNumberController.dispose();
    _illnessController.dispose();
    _descriptionController.dispose();
    _surgeryDueDateController.dispose();
    super.dispose();
  }
}
