import 'package:flutter/material.dart';
Widget customInput(String hint, controller , {bool obscure = false}  ) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    style: const TextStyle(
      color: Colors.white70, // semelhante ao text-gray-300
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.white38,
      ),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF3F3C4E), // borda solicitada
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF1499E2),
        ),
      ),
    ),
  );
}