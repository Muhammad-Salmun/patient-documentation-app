import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:surgery_doc/pages/home.dart';

class LoadingPage extends StatelessWidget {
  Future<Map<String, dynamic>> loadPatientData() async {
    // Load the JSON file from the assets folder
    final String response =
        await rootBundle.loadString('assets/data/patients.json');
    // Parse the JSON data
    return json.decode(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: loadPatientData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while data is loading
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle any errors during data loading
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // Data loaded successfully, navigate to HomePage
            final data = snapshot.data!;
            return HomePage(patientData: data);
          } else {
            // Handle unexpected cases
            return Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }
}
