import 'package:flutter/material.dart';
import 'package:sabidos2app/core/theme/app_colors.dart';
import 'package:sabidos2app/presentation/pages/widgets/dashboard_header.dart';
import 'package:sabidos2app/presentation/pages/widgets/stat_card.dart';
import 'package:sabidos2app/presentation/pages/widgets/study_time_card.dart';
import 'package:sabidos2app/data/datasources/gamefication_service.dart';
import 'package:sabidos2app/data/core/models/user_stats.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final gamefication_service _gamification = gamefication_service();
  UserStats? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final stats = await _gamification.getUserStats();

      if (!mounted) return;

      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Erro ao carregar estatísticas';
        _loading = false;
      });

      debugPrint('Erro ao carregar stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    if (_loading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadStats,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final stats = _stats ?? UserStats.empty();

    final studySeconds = stats.totalAcoes * 60;
    final notas = stats.resumosCriados;
    final cards = stats.flashcardsCriados;
    final eventos = stats.eventosCriados;

    return Scaffold(
      backgroundColor: colors.background,
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
                  color: colors.card,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFF423E51)),
                ),
                child: Column(
                  children: [
                    StudyTimeCard(seconds: studySeconds),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        StatCard(
                          label: "Notas",
                          value: notas,
                          icon: Icons.description,
                        ),
                        const SizedBox(width: 10),
                        StatCard(
                          label: "Cards",
                          value: cards,
                          icon: Icons.school,
                        ),
                        const SizedBox(width: 10),
                        StatCard(
                          label: "Eventos",
                          value: eventos,
                          icon: Icons.calendar_today,
                        ),
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
