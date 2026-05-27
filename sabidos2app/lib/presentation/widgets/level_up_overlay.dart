import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabidos2app/core/theme/theme_extensions.dart';
import 'package:sabidos2app/core/theme/app_colors.dart';
import '../controllers/notification_controller.dart';

class LevelUpOverlay extends StatefulWidget {
  const LevelUpOverlay({super.key});

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _firstBarAnimation;
  late Animation<double> _secondBarAnimation;
  
  bool _showNewLevel = false;
  LevelUpNotification? _lastNotification;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.1), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 5),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 80),
    ]).animate(_controller);

    // 1. Barra antiga completando (0.2 a 0.5 do tempo total)
    _firstBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );

    // 2. Barra nova subindo (0.6 a 0.9 do tempo total)
    _secondBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
      ),
    );

    _controller.addListener(() {
      if (_controller.value >= 0.55 && !_showNewLevel) {
        setState(() => _showNewLevel = true);
      }
      // Força o redesenho durante a animação
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final levelNotification = context.watch<NotificationController>().currentLevelUp;
    
    // DISPARADOR DA ANIMAÇÃO: Se a notificação mudou, resetamos e iniciamos
    if (levelNotification != null && levelNotification != _lastNotification) {
      _lastNotification = levelNotification;
      _showNewLevel = false;
      _controller.reset();
      _controller.forward();
    } else if (levelNotification == null) {
      _lastNotification = null;
    }

    if (levelNotification == null) return const SizedBox.shrink();

    final colors = context.colors;
    
    // Lógica de progresso refinada para garantir animação visível:
    // Fase 1: Do progresso antigo até 100%
    // Fase 2: De 0% até o novo progresso
    final double currentProgressValue = !_showNewLevel 
        ? (levelNotification.oldProgress + (1.0 - levelNotification.oldProgress) * _firstBarAnimation.value)
        : (levelNotification.newProgress * _secondBarAnimation.value);

    return Material(
      color: Colors.black87,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 320,
            constraints: const BoxConstraints(minHeight: 480),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: colors.boxBackground,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: _showNewLevel ? colors.accentYellow : colors.accentBlue, width: 3),
              boxShadow: [
                BoxShadow(
                  color: (_showNewLevel ? colors.accentYellow : colors.accentBlue).withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 40,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _showNewLevel ? "NOVO NÍVEL ALCANÇADO!" : "SUBINDO DE NÍVEL...",
                        key: ValueKey(_showNewLevel),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _showNewLevel ? colors.accentYellow : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 180,
                            height: 180,
                            child: CircularProgressIndicator(
                              value: currentProgressValue.clamp(0.0, 1.0),
                              strokeWidth: 14,
                              backgroundColor: Colors.white10,
                              color: _showNewLevel ? colors.accentYellow : colors.accentBlue,
                            ),
                          ),
                          // Usando escala fixa no estilo para evitar que o layout se mova
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.elasticOut,
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 64, // Aumentei um pouco para combinar com o novo tamanho
                              fontWeight: FontWeight.bold,
                            ),
                            child: Text("${_showNewLevel ? levelNotification.newLevel : levelNotification.oldLevel}"),
                          ),
                        ],
                      ),
                    ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 80,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _showNewLevel ? 1.0 : 0.0,
                    child: Column(
                      children: [
                        const Text(
                          "PARABÉNS!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Você agora é nível ${levelNotification.newLevel}!",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Opacity(
                  opacity: _showNewLevel ? 1.0 : 0.3,
                  child: ElevatedButton(
                    onPressed: _showNewLevel ? () => context.read<NotificationController>().dismissLevelUp() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.accentBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("CONTINUAR", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
