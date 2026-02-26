import 'package:flutter/material.dart';

Widget gradientBorderButton(String text) {
  return Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF1499E2),
          Color(0xFFD6343B),
        ],
      ),
      borderRadius: BorderRadius.circular(14),
    ),
    padding: const EdgeInsets.all(1.5), // espessura da borda
    child: Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}