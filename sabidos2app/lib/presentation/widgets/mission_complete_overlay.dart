import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabidos2app/core/theme/theme_extensions.dart';
import '../controllers/notification_controller.dart';

class MissionCompleteOverlay extends StatefulWidget {
  final Function(int, {int profileTab})? onNavigate;
  const MissionCompleteOverlay({super.key, this.onNavigate});

  @override
  State<MissionCompleteOverlay> createState() => _MissionCompleteOverlayState();
}

class _MissionCompleteOverlayState extends State<MissionCompleteOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  
  // Variáveis para guardar os dados e evitar o "flash" de texto vazio na saída
  String _displayTitle = "";
  String _displayEmoji = "🎯";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack, // Curva mais "saltitante" para o fundo
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mission = context.watch<NotificationController>().currentMission;
    
    if (mission != null) {
      _displayTitle = mission.title;
      _displayEmoji = mission.emoji;
      _controller.forward();
    } else {
      _controller.reverse();
    }

    if (mission == null && _controller.isDismissed) return const SizedBox.shrink();

    final colors = context.colors;

    return Positioned(
      bottom: 100, // Acima da bottom bar
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 100 * (1 - _slideAnimation.value)),
            child: Opacity(
              opacity: _slideAnimation.value.clamp(0.0, 1.0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.boxBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.accentYellow, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, -4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(_displayEmoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "MISSÃO CUMPRIDA!",
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              _displayTitle,
                              style: TextStyle(
                                color: colors.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.onNavigate?.call(0, profileTab: 1); // Perfil na aba Conquistas
                          context.read<NotificationController>().dismissMission();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: context.colors.accentYellow,
                        ),
                        child: const Text("VER", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                        onPressed: () => context.read<NotificationController>().dismissMission(),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
