import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabidos2app/core/theme/theme_extensions.dart';
import '../controllers/notification_controller.dart';

class SuccessOverlay extends StatefulWidget {
  final Function(int, {int profileTab})? onNavigate;
  const SuccessOverlay({super.key, this.onNavigate});

  @override
  State<SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<SuccessOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  
  // Memória de exibição para evitar flicker na saída
  AchievementNotification? _lastNotification;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notification = context.watch<NotificationController>().currentNotification;
    
    if (notification != null) {
      _lastNotification = notification;
      _controller.forward();
    } else {
      _controller.reverse();
    }

    if (notification == null && _controller.isDismissed) return const SizedBox.shrink();

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
                    border: Border.all(color: colors.accentBlue, width: 2),
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
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: colors.sabidosGradient,
                        ),
                        child: Icon(_lastNotification?.icon ?? Icons.emoji_events, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "CONQUISTA DESBLOQUEADA!",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              _lastNotification?.title ?? "",
                              style: TextStyle(
                                color: colors.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.onNavigate?.call(0, profileTab: 1); // Vai para Conquistas
                          context.read<NotificationController>().dismiss();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: context.colors.accentBlue,
                        ),
                        child: const Text("VER", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                        onPressed: () => context.read<NotificationController>().dismiss(),
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
