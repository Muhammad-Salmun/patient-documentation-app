import 'package:flutter/material.dart';

class CustomTextFeild extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;

  const CustomTextFeild({
    super.key,
    required this.controller,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(9),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.text, // For text input
        textCapitalization: TextCapitalization
            .words, // Automatically capitalize first letter of each word
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          labelText: labelText,
          hintStyle: const TextStyle(
            fontFamily: 'Centaur',
            fontSize: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$labelText is required';
          }
          return null;
        },
      ),
    );
  }
}
