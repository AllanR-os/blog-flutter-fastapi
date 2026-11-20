import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder borde(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color),
        );

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColores.texto),
      cursorColor: AppColores.acento,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColores.textoSuave),
        floatingLabelStyle: const TextStyle(color: AppColores.acento),
        prefixIcon: Icon(prefixIcon, color: AppColores.textoSuave),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColores.fondo,
        enabledBorder: borde(AppColores.borde),
        focusedBorder: borde(AppColores.acento),
        border: borde(AppColores.borde),
      ),
    );
  }
}
