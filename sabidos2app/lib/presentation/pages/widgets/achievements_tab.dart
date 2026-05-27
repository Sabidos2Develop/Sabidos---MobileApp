import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabidos2app/core/theme/app_colors.dart';
import 'package:sabidos2app/core/theme/theme_extensions.dart';
import 'package:sabidos2app/presentation/controllers/gamification_controller.dart';
import 'package:sabidos2app/data/core/models/achievement_catalog.dart';
import 'package:sabidos2app/presentation/pages/widgets/achievement_card.dart';

class AchievementsTab extends StatefulWidget {
  const AchievementsTab({super.key});

  @override
  State<AchievementsTab> createState() => _AchievementsTabState();
}

class _AchievementsTabState extends State<AchievementsTab> {
  final List<Widget> _floatingXpTexts = [];

  void _showFloatingXp(GlobalKey key, int xp) {
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero, ancestor: context.findRenderObject());

    final id = UniqueKey();
    setState(() {
      _floatingXpTexts.add(
        _FloatingXpWidget(
          key: id,
          initialOffset: Offset(offset.dx + renderBox.size.width / 2, offset.dy),
          xp: xp,
          onComplete: () {
            setState(() {
              _floatingXpTexts.removeWhere((w) => w.key == id);
            });
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usar Consumer garante que este widget ESPECÍFICO reconstrua sempre que notifyListeners() for chamado no controller
    return Consumer<GamificationController>(
      builder: (context, gami, child) {
        final stats = gami.stats;
        final achievements = AchievementCatalog.buildFromStats(stats, gami.unlockedIds);

        // Simplificando o cálculo para ser mais robusto: XP Total / Meta do Próximo Nível
        double progressFactor = gami.xpNextLevelThreshold > 0 
            ? gami.totalXp / gami.xpNextLevelThreshold 
            : 0.0;
            
        if (progressFactor < 0) progressFactor = 0;
        if (progressFactor > 1) progressFactor = 1;

        debugPrint('--- UI CONSUMER REBUILD: XP=${gami.totalXp}, Factor=$progressFactor ---');

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Progresso de Nível",
                    style: TextStyle(
                      color: context.colors.text, 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // CARD DA BARRA DE XP
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.colors.boxBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.colors.boxBorder, width: 1),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 35,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            AnimatedFractionallySizedBox(
                              key: ValueKey('xp_bar_${gami.totalXp}'),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutBack,
                              widthFactor: progressFactor,
                              child: Container(

                                height: 35,
                                decoration: BoxDecoration(
                                  gradient: context.colors.levelGradient,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.colors.accentYellow.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("${gami.totalXp}xp", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.colors.text)),
                                    Text("${gami.xpNextLevelThreshold}xp", style: TextStyle(color: context.colors.text.withOpacity(0.5), fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Nível ${gami.userLevel}", style: TextStyle(color: context.colors.grayText, fontSize: 16, fontWeight: FontWeight.w600)),
                            Text("Nível ${gami.userLevel + 1}", style: TextStyle(color: context.colors.grayText, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Missões Diárias",
                        style: TextStyle(
                          color: context.colors.text, 
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.colors.boxBorder.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Trocas: ${gami.rerollsLeft < 0 ? '∞' : gami.rerollsLeft}/3",
                          style: TextStyle(color: context.colors.grayText, fontSize: 12),
                        ),
                        ),
                        ],
                        ),
                        const SizedBox(height: 12),

                        if (gami.dailyMissions.isEmpty)
                        const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text("Carregando missões...", style: TextStyle(color: Colors.grey))),
                        )
                        else
                        ...gami.dailyMissions.map((m) {
                        final missionKey = GlobalKey();
                        return _buildMissionTile(
                        context, 
                        missionKey,
                        m.title, 
                        m.description, 
                        m.emoji, 
                        m.progressValue,
                        xpReward: m.xpReward,
                        isClaimed: m.claimed,
                        canReroll: !m.completed, // Removida restrição de gami.rerollsLeft
                        onReroll: () => gami.rerollMission(m.id),
                        onClaim: () async {

                          await gami.claimDailyMission(m.id);
                          _showFloatingXp(missionKey, m.xpReward);
                        },
                      );
                    }),
                  
                  const SizedBox(height: 24),
                  Text(
                    "Minhas Conquistas",
                    style: TextStyle(
                      color: context.colors.text, 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // LISTA DE CONQUISTAS DINÂMICA (2 por linha)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.85, 
                    children: achievements
                        .map((a) => AchievementCard(achievement: a))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            ..._floatingXpTexts,
          ],
        );
      },
    );
  }

  Widget _buildMissionTile(
    BuildContext context, 
    GlobalKey widgetKey,
    String title, 
    String sub, 
    String emoji, 
    double progress, {
    int xpReward = 0,
    bool isClaimed = false,
    bool canReroll = false,
    VoidCallback? onReroll,
    VoidCallback? onClaim,
  }) {
    final bool isCompleted = progress >= 1.0;

    return Container(
      key: widgetKey,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isClaimed ? context.colors.boxBackground.withOpacity(0.5) : context.colors.boxBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted 
            ? Colors.green.withOpacity(0.3) 
            : Colors.transparent
        ),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Opacity(
                opacity: isClaimed ? 0.5 : 1.0,
                child: Text(emoji, style: const TextStyle(fontSize: 24))
              ),
              if (isCompleted && !isClaimed)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          title, 
                          style: TextStyle(
                            color: isClaimed ? context.colors.text.withOpacity(0.5) : context.colors.text, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                        const SizedBox(width: 8),
                        if (!isClaimed)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.colors.accentBlue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "+$xpReward XP",
                              style: TextStyle(
                                color: context.colors.accentBlue,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (canReroll && !isCompleted)
                      GestureDetector(
                        onTap: onReroll,
                        child: Icon(Icons.refresh, size: 16, color: context.colors.accentBlue),
                      ),
                  ],
                ),
                Text(
                  sub, 
                  style: TextStyle(
                    color: isClaimed ? context.colors.grayText.withOpacity(0.5) : context.colors.grayText, 
                    fontSize: 12
                  )
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.black26,
                  color: isClaimed ? Colors.green.withOpacity(0.5) : (isCompleted ? Colors.green : context.colors.accentBlue),
                  borderRadius: BorderRadius.circular(10),
                )
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isCompleted && !isClaimed)
            ElevatedButton(
              onPressed: onClaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.accentYellow,
                foregroundColor: context.colors.background,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              child: const Text("COLETAR"),
            )
          else
            Icon(
              isClaimed ? Icons.check_circle : Icons.chevron_right, 
              color: isClaimed ? Colors.green : context.colors.text.withOpacity(0.2)
            )
        ],
      ),
    );
  }
}

class _FloatingXpWidget extends StatefulWidget {
  final Offset initialOffset;
  final int xp;
  final VoidCallback onComplete;

  const _FloatingXpWidget({
    super.key, 
    required this.initialOffset, 
    required this.xp, 
    required this.onComplete
  });

  @override
  State<_FloatingXpWidget> createState() => _FloatingXpWidgetState();
}

class _FloatingXpWidgetState extends State<_FloatingXpWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _moveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _opacityAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _moveAnimation = Tween<Offset>(
      begin: widget.initialOffset,
      end: widget.initialOffset + const Offset(0, -60),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _moveAnimation.value.dx - 20,
          top: _moveAnimation.value.dy,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: Text(
                "+${widget.xp} XP",
                style: TextStyle(
                  color: Theme.of(context).extension<AppColors>()!.accentBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}