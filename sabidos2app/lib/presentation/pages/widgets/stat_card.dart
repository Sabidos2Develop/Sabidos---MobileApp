import 'package:flutter/material.dart';
import 'package:sabidos2app/core/theme/app_colors.dart';

class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<AppColors>()!.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).extension<AppColors>()!.primary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).extension<AppColors>()!.border,
                width: 2,
              ),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).extension<AppColors>()!.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              color: Theme.of(context).extension<AppColors>()!.text,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
