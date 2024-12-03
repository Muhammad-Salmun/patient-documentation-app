import 'dart:async';
import 'package:flutter/material.dart';
import 'package:surgery_doc/pages/loading_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoadingPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(234, 162, 47, 1),
      ),
      home: const Scaffold(
        body: Center(
          child: Stack(
            children: [
              // Image.asset(
              //   'assets/images/splash_image.png',
              //   fit: BoxFit.cover,
              //   width: MediaQuery.of(context).size.width,
              // ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage('assets/images/splash_image.png'),
                      fit: BoxFit.contain,
                    ),
                    Text(
                      'Patient Documents',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFFFFBFB),
                        fontSize: 40,
                        fontFamily: 'Lalezar',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
