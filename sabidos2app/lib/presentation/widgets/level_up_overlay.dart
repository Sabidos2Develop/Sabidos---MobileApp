import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabidos2app/core/theme/theme_extensions.dart';
import 'package:sabidos2app/core/theme/app_colors.dart';
import '../controllers/notification_controller.dart';

class LevelUpOverlay extends StatefulWidget {
  final LevelUpNotification notification;
  final Function(int, {int profileTab})? onNavigate;

  const LevelUpOverlay({
    super.key, 
    required this.notification,
    this.onNavigate
  });

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  late final int _oldLevel;
  late final int _newLevel;
  late final double _oldProgress;
  late final double _newProgress;

  @override
  void initState() {
    super.initState();
    
    _oldLevel = widget.notification.oldLevel;
    _newLevel = widget.notification.newLevel;
    _oldProgress = widget.notification.oldProgress;
    _newProgress = widget.notification.newProgress;

    // 50 Segundos de pura meditação e elegância visual
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50000),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;

        // Variáveis de Estado da Animação
        double cardScale = 1.0;
        double blueProgress = _oldProgress;
        double yellowProgress = 0.0;
        double blueOpacity = 1.0;
        double yellowOpacity = 0.0;
        double colorLerp = 0.0;
        double flashIntensity = 0.0;
        double numberScale = 1.0;
        double congratsOpacity = 0.0;

        // -------------------------------------------------------------------
        // LINHA DO TEMPO (0.0 a 1.0) - TOTAL 50s
        // -------------------------------------------------------------------
        
        // 1. ENTRADA (0% a 5%) -> 2.5s
        if (t <= 0.05) {
          double localT = t / 0.05;
          cardScale = Curves.easeOutBack.transform(localT);
          blueProgress = _oldProgress;
          blueOpacity = 1.0;
        } 
        // 2. ENCHENDO AZUL (5% a 45%) -> 20.0s (EXTREMAMENTE LENTO)
        else if (t > 0.05 && t <= 0.45) {
          double localT = (t - 0.05) / (0.45 - 0.05);
          double curveT = Curves.easeInOutSine.transform(localT);
          blueProgress = _oldProgress + (1.0 - _oldProgress) * curveT;
          blueOpacity = 1.0;
          colorLerp = 0.0;
        }
        // 3. O SWAP MÁGICO (45% a 55%) -> 5.0s (TRANSIÇÃO ÉPICA)
        else if (t > 0.45 && t <= 0.55) {
          double localT = (t - 0.45) / (0.55 - 0.45);
          
          blueProgress = 1.0;
          yellowProgress = 0.0;
          
          blueOpacity = (1.0 - localT * 2.0).clamp(0.0, 1.0);
          yellowOpacity = (localT * 2.0 - 1.0).clamp(0.0, 1.0);
          colorLerp = localT;
          
          flashIntensity = (1.0 - (localT - 0.5).abs() * 2.0).clamp(0.0, 1.0);
          numberScale = 1.0 + (0.3 * Curves.easeInOutBack.transform(localT));
        }
        // 4. ENCHENDO AMARELO (55% a 95%) -> 20.0s (EXTREMAMENTE LENTO)
        else if (t > 0.55 && t <= 0.95) {
          double localT = (t - 0.55) / (0.95 - 0.55);
          double curveT = Curves.easeInOutSine.transform(localT);
          yellowProgress = _newProgress * curveT;
          yellowOpacity = 1.0;
          blueOpacity = 0.0;
          colorLerp = 1.0;
          congratsOpacity = localT;
        }
        // 5. FINALIZAÇÃO
        else {
          yellowProgress = _newProgress;
          yellowOpacity = 1.0;
          blueOpacity = 0.0;
          colorLerp = 1.0;
          congratsOpacity = 1.0;
        }

        final Color currentUIThemeColor = Color.lerp(colors.accentBlue, colors.accentYellow, colorLerp)!;

        return Material(
          color: Colors.black87,
          child: Center(
            child: Transform.scale(
              scale: cardScale,
              child: Container(
                width: 320,
                constraints: const BoxConstraints(minHeight: 520),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: colors.boxBackground,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: currentUIThemeColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: currentUIThemeColor.withOpacity(0.4 + (flashIntensity * 0.4)),
                      blurRadius: 30 + (flashIntensity * 20),
                      spreadRadius: 10 + (flashIntensity * 5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          t > 0.53 ? "NOVO NÍVEL ALCANÇADO!" : "SUBINDO DE NÍVEL...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.lerp(Colors.white, colors.accentYellow, colorLerp),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // O PINTOR DE XP (DUAS BARRAS EM CROSSFADE)
                          CustomPaint(
                            size: const Size(200, 200),
                            painter: _XPDualPainter(
                              blueProgress: blueProgress,
                              yellowProgress: yellowProgress,
                              blueOpacity: blueOpacity,
                              yellowOpacity: yellowOpacity,
                              blueColor: colors.accentBlue,
                              yellowColor: colors.accentYellow,
                              strokeWidth: 16,
                              flashIntensity: flashIntensity,
                            ),
                          ),
                          // NÚMEROS EM CROSSFADE
                          Transform.scale(
                            scale: numberScale,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Opacity(
                                  opacity: blueOpacity,
                                  child: Text(
                                    "$_oldLevel",
                                    style: TextStyle(
                                      color: colors.text,
                                      fontSize: 72,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Opacity(
                                  opacity: yellowOpacity,
                                  child: Text(
                                    "$_newLevel",
                                    style: TextStyle(
                                      color: colors.text,
                                      fontSize: 82,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      height: 100,
                      child: Opacity(
                        opacity: congratsOpacity.clamp(0.0, 1.0),
                        child: Column(
                          children: [
                            Text(
                              "PARABÉNS!",
                              style: TextStyle(
                                color: colors.accentYellow,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Você evoluiu para o nível $_newLevel!",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Opacity(
                      opacity: t > 0.96 ? 1.0 : 0.3,
                      child: ElevatedButton(
                        onPressed: t > 0.96 ? () => context.read<NotificationController>().dismissLevelUp() : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.accentBlue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: const Text("CONTINUAR ESTUDANDO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _XPDualPainter extends CustomPainter {
  final double blueProgress;
  final double yellowProgress;
  final double blueOpacity;
  final double yellowOpacity;
  final Color blueColor;
  final Color yellowColor;
  final double strokeWidth;
  final double flashIntensity;

  _XPDualPainter({
    required this.blueProgress,
    required this.yellowProgress,
    required this.blueOpacity,
    required this.yellowOpacity,
    required this.blueColor,
    required this.yellowColor,
    required this.strokeWidth,
    required this.flashIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. FUNDO
    final bgPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // 2. ARCO AZUL (Antigo)
    if (blueOpacity > 0) {
      final bluePaint = Paint()
        ..color = blueColor.withOpacity(blueOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      
      if (flashIntensity > 0) {
        bluePaint.maskFilter = MaskFilter.blur(BlurStyle.normal, flashIntensity * 15);
      }

      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * blueProgress, false, bluePaint);
    }

    // 3. ARCO AMARELO (Novo)
    if (yellowOpacity > 0) {
      final yellowPaint = Paint()
        ..color = yellowColor.withOpacity(yellowOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      if (flashIntensity > 0) {
        yellowPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, flashIntensity * 15);
      }

      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * yellowProgress, false, yellowPaint);
    }

    // 4. EFEITO DE EXPLOSÃO (FLASH)
    if (flashIntensity > 0.1) {
      final flashPaint = Paint()
        ..color = Colors.white.withOpacity(flashIntensity * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + (flashIntensity * 6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, flashIntensity * 20);
      
      canvas.drawCircle(center, radius, flashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _XPDualPainter oldDelegate) {
    return oldDelegate.blueProgress != blueProgress ||
           oldDelegate.yellowProgress != yellowProgress ||
           oldDelegate.blueOpacity != blueOpacity ||
           oldDelegate.yellowOpacity != yellowOpacity ||
           oldDelegate.flashIntensity != flashIntensity;
  }
}
