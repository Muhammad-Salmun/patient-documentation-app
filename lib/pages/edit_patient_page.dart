import 'package:flutter/material.dart';
import 'package:surgery_doc/components/textfeild.dart';

class EditPatientPage extends StatefulWidget {
  final Map<String, dynamic> patient;

  const EditPatientPage({Key? key, required this.patient}) : super(key: key);

  @override
  State<EditPatientPage> createState() => _EditPatientPageState();
}

class _EditPatientPageState extends State<EditPatientPage> {
  late TextEditingController _nameController;
  late TextEditingController _sexController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _illnessController;
  late TextEditingController _descriptionController;
  late TextEditingController _surgeryDueDateController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the current patient data
    _nameController = TextEditingController(text: widget.patient['name']);
    _sexController = TextEditingController(text: widget.patient['sex']);
    _phoneNumberController =
        TextEditingController(text: widget.patient['phoneNumber']);
    _illnessController = TextEditingController(text: widget.patient['illness']);
    _descriptionController =
        TextEditingController(text: widget.patient['description']);
    _surgeryDueDateController =
        TextEditingController(text: widget.patient['surgeryDueDate']);
  }

  // Function to save edited data back to the patient list
  Future<void> _saveEditedData() async {
    // Update patient data with the edited values
    widget.patient['name'] = _nameController.text;
    widget.patient['sex'] = _sexController.text;
    widget.patient['phoneNumber'] = _phoneNumberController.text;
    widget.patient['illness'] = _illnessController.text;
    widget.patient['description'] = _descriptionController.text;
    widget.patient['surgeryDueDate'] = _surgeryDueDateController.text;

    // Save changes to the patient data (you can implement saving to a JSON file or Firebase here)

    // Return to the PatientDetailsPage
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Patient'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveEditedData,
              child: Text('Save Changes'),
            ),
          ],
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
