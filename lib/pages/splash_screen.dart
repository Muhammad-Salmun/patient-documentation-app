import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:surgery_doc/models/patient_model.dart';
import 'package:surgery_doc/pages/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  bool _loading = true;
  List<Patient> _patients = [];

  @override
  void initState() {
    super.initState();

    // Start fade-in animation
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Start both loading and delay
    _initializeSplash();
  }

  Future<void> _initializeSplash() async {
    final splashDelay = Future.delayed(const Duration(seconds: 3));
    final dataLoad = _loadPatients();

    await Future.wait([splashDelay, dataLoad]);

    // Done loading
    if (!mounted) return;
    setState(() {
      _loading = false;
    });

    //auto-navigate to HomePage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => HomePage(initialPatients: _patients)),
    );
  }

  Future<void> _loadPatients() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .orderBy('name')
          .get();
      final patients =
          querySnapshot.docs.map((doc) => Patient.fromFirestore(doc)).toList();
      _patients = patients;
      print("Splash: Loaded ${patients.length} patients");
    } catch (e) {
      print("Splash error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load patient data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(62, 72, 82, 1),
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 2),
          opacity: _opacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Patient Care Tracker',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Loaded ${_patients.length} patients!',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 18,
                      ),
                    ),
              const SizedBox(height: 40),
              const Text(
                'Powered by Phiscape',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
