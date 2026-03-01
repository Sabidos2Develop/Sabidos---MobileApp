import 'package:flutter/material.dart';
import 'package:sabidos2app/core/app_colors.dart';

class StudyTimeCard extends StatelessWidget {
  final int seconds;

  const StudyTimeCard({super.key, required this.seconds});

  String formatTime(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    if (h > 0) return "${h} H";
    return "${m} min";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: const Icon(Icons.timer, color: Colors.white),
          ),
          const SizedBox(height: 12),

          const Text("Você estudou por:",
              style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),

          Text(
            formatTime(seconds),
            style: const TextStyle(
                fontSize: 40,
                color: AppColors.text,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}