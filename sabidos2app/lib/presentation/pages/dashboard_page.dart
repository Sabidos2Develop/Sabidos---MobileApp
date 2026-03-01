import 'package:flutter/material.dart';
import 'package:sabidos2app/presentation/pages/widgets/dashboard_header.dart';
import 'package:sabidos2app/presentation/pages/widgets/study_time_card.dart';
import 'package:sabidos2app/presentation/pages/widgets/stat_card.dart';
import 'package:sabidos2app/core/app_colors.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔴 MOCK — depois vamos ligar API
    final studySeconds = 7200;
    final notas = 17;
    final cards = 6;
    final eventos = 20;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const DashboardHeader(userName: "Sabido"),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: BoxDecoration(
                color: const Color(0xFF2B2738), // fundo escuro do bloco
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                children: [
                  // CARD DO TEMPO
                  StudyTimeCard(seconds: studySeconds),

                  const SizedBox(height: 28),

                  // CARDS MENORES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatCard(label: "Notas", value: notas, icon: Icons.edit),
                      StatCard(label: "Cards", value: cards, icon: Icons.style),
                      StatCard(label: "Eventos", value: eventos, icon: Icons.event),
                    ],
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