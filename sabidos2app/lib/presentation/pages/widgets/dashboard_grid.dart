import 'package:flutter/material.dart';
import 'package:sabidos2app/core/theme/theme_extensions.dart';
import 'package:sabidos2app/data/core/models/user_stats.dart';

class DashboardGrid extends StatelessWidget {
  final UserStats stats;
  final Function(int)? onCardTap;

  const DashboardGrid({
    super.key,
    required this.stats,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardsData = [
      {
        'title': 'Sequência',
        'val': stats.diasSequencia.toString(),
        'suffix': 'd',
        'emoji': '🔥',
        'index': -1 // Não navega
      },
      {
        'title': 'Flashcards',
        'val': stats.flashcardsCriados.toString(),
        'suffix': '',
        'emoji': '🃏',
        'index': 1
      },
      {
        'title': 'Resumos',
        'val': stats.resumosCriados.toString(),
        'suffix': '',
        'emoji': '📝',
        'index': 4
      },
      {
        'title': 'Eventos',
        'val': stats.eventosCriados.toString(),
        'suffix': '',
        'emoji': '📅',
        'index': 2
      },
      {
        'title': 'Pomodoro',
        'val': stats.pomodorosConcluidos.toString(),
        'suffix': '',
        'emoji': '🍅',
        'index': 3
      },
      {
        'title': 'Total Ações',
        'val': stats.totalAcoes.toString(),
        'suffix': '',
        'emoji': '🚀',
        'index': -1 // Não navega
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.90,
        children: List.generate(cardsData.length, (index) {
          final card = cardsData[index];
          final targetIndex = card['index'] as int;

          final corDoIcone = (index % 2 == 0)
              ? context.colors.accentBlue
              : context.colors.accentYellow;

          return InkWell(
            onTap: targetIndex != -1 ? () => onCardTap?.call(targetIndex) : null,
            borderRadius: BorderRadius.circular(12),
            child: _buildGridCard(
              context,
              card['title'] as String,
              card['val'] as String,
              card['suffix'] as String,
              card['emoji'] as String,
              corDoIcone,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context,
    String title, 
    String value, 
    String suffix, 
    String emoji, 
    Color iconColor
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.colors.boxBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.boxBorder, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.colors.grayText,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: value,
              style: TextStyle(
                color: context.colors.text,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              children: [
                if (suffix.isNotEmpty)
                  TextSpan(
                    text: suffix,
                    style: TextStyle(
                      color: context.colors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}