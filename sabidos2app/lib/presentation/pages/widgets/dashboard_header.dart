import 'package:flutter/material.dart';
import 'package:sabidos2app/core/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;

  const DashboardHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset("assets/images/sabidosDash.svg", width: 120),
        const SizedBox(width: 10),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              "Opa $userName! Já checou suas notas hoje?\n"
              "Bons estudos, mantenha o foco.",
              style: const TextStyle(color: AppColors.text),
            ),
          ),
        )
      ],
    );
  }
}