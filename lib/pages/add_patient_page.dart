import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:surgery_doc/components/textfeild.dart';

enum Gender { male, female, other }

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({Key? key}) : super(key: key);

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();

  // Declare TextEditingControllers for each input field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _relationshipToPatient = TextEditingController();
  final TextEditingController _bystanderName = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _illnessController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _surgeryDateController = TextEditingController();

  // Function to add a new patient to Firestore
  Future<void> _addPatient() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('patients').add({
          'name': _nameController.text,
          'sex': selectedGender,
          'age': _ageController.text,
          'bystanderName': _bystanderName.text,
          'relationshipToPatient': _relationshipToPatient.text,
          'phoneNumber': _phoneNumberController.text,
          'illness': _illnessController.text,
          'address': _addressController.text,
          'surgeryDueDate': _surgeryDateController.text,
          'currentStage': 1, // Default to Stage 1
          'anxietyScoreBeforeSurgery': 0,
          'anxietyScoreAfterSurgery': 0,
          'qualityOfLifeScore': 0,
        });
        if (!mounted) return;
        Navigator.pop(context); // Return to HomePage after adding the patient
      } catch (e) {
        // print('Error adding patient: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to add patient. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Patient'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomTextFeild(
                  controller: _nameController,
                  labelText: 'Name',
                ),
                Padding(
                  padding: const EdgeInsets.all(9),
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number, // Numeric keyboard
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      labelText: 'Age',
                      hintStyle: TextStyle(
                        fontFamily: 'Centaur',
                        fontSize: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Age is required';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: _buildGenderDropdown(),
                ),
                CustomTextFeild(
                  controller: _bystanderName,
                  labelText: 'Bystander Name',
                ),
                CustomTextFeild(
                    controller: _relationshipToPatient,
                    labelText: 'Relationship to patient'),
                Padding(
                  padding: const EdgeInsets.all(9),
                  child: TextFormField(
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.number, // Numeric keyboard
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      labelText: 'Bystander Phone Number',
                      hintStyle: TextStyle(
                        fontFamily: 'Centaur',
                        fontSize: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bystander Phone Number is required';
                      }
                      return null;
                    },
                  ),
                ),
                CustomTextFeild(
                  controller: _illnessController,
                  labelText: 'Illness',
                ),
                CustomTextFeild(
                  controller: _addressController,
                  labelText: 'Address',
                ),
                Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: TextFormField(
                    controller: _surgeryDateController,
                    readOnly: true, // Prevent manual editing
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      labelText: 'Surgery Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      // Show the date picker
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(), // Default to today's date
                        firstDate: DateTime(2000), // Earliest selectable date
                        lastDate: DateTime(2100), // Latest selectable date
                      );

                      if (pickedDate != null) {
                        // Format the date and set it in the controller
                        _surgeryDateController.text =
                            "${pickedDate.toLocal()}".split(' ')[0];
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: _addPatient,
                    child: const Text('Save Patient'),
                  ),
                ),
              ],
            ),
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
    _ageController.dispose();
    _phoneNumberController.dispose();
    _illnessController.dispose();
    _addressController.dispose();
    _surgeryDateController.dispose();
    super.dispose();
  }
}
