import 'package:flutter/material.dart';

class CustomTextFeild extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const CustomTextFeild({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(9),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Centaur',
            fontSize: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$hintText is required';
          }
          return null;
        },
      ),
    );
  }
}
