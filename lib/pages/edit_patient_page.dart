import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:surgery_doc/components/textfeild.dart';

class EditPatientPage extends StatefulWidget {
  final String patientId;
  final String name;
  final String age;
  final String byStanderName;
  final String relationToPatient;
  final String phoneNumber;
  final String illness;
  final String address;
  final String surgeryDueDate;
  final String sex;

  const EditPatientPage({
    Key? key,
    required this.patientId,
    required this.name,
    required this.age,
    required this.phoneNumber,
    required this.illness,
    required this.address,
    required this.surgeryDueDate,
    required this.sex,
    required this.byStanderName,
    required this.relationToPatient,
  }) : super(key: key);

  @override
  State<EditPatientPage> createState() => _EditPatientPageState();
}

class _EditPatientPageState extends State<EditPatientPage> {
  final _formKey = GlobalKey<FormState>();

  // Declare TextEditingControllers for each input field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _relationToPatient = TextEditingController();
  final TextEditingController _bystanderName = TextEditingController();
  final TextEditingController _illnessController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _surgeryDateController = TextEditingController();

  String selectedGender = 'Male'; // Default gender

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with existing data
    _nameController.text = widget.name;
    _phoneNumberController.text = widget.phoneNumber;
    _illnessController.text = widget.illness;
    _addressController.text = widget.address;
    _surgeryDateController.text = widget.surgeryDueDate;
    selectedGender = widget.sex;
  }

  // Function to update the patient data in Firestore
  Future<void> _updatePatient() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(widget.patientId)
            .update({
          'name': _nameController.text,
          'sex': selectedGender,
          'age': int.parse(_ageController.text),
          'bystanderName': _bystanderName.text,
          'relationshipToPatient': _relationToPatient.text,
          'phoneNumber': _phoneNumberController.text,
          'illness': _illnessController.text,
          'address': _addressController.text,
          'surgeryDueDate': _surgeryDateController.text,
        });
        if (!mounted) return;
        Navigator.pop(context); // Go back after updating
      } catch (e) {
        // print('Error updating patient: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update patient. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Patient'),
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
                    controller: _relationToPatient,
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
                  labelText: 'address',
                ),
                Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: TextFormField(
                    controller: _surgeryDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      labelText: 'Surgery Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        _surgeryDateController.text =
                            "${pickedDate.toLocal()}".split(' ')[0];
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: _updatePatient,
                    child: const Text('Update Patient'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
    _nameController.dispose();
    _ageController.dispose();
    _phoneNumberController.dispose();
    _illnessController.dispose();
    _addressController.dispose();
    _surgeryDateController.dispose();
    super.dispose();
  }
}
