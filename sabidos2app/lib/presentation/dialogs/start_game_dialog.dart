import 'package:flutter/material.dart';

class StartGameConfig {
  final int quantidade;

  StartGameConfig({
    required this.quantidade,
  });
}

class StartGameDialog extends StatefulWidget {
  final int maxCards;

  const StartGameDialog({
    super.key,
    required this.maxCards,
  });

  @override
  State<StartGameDialog> createState() => _StartGameDialogState();
}

class _StartGameDialogState extends State<StartGameDialog> {
  late int _selectedAmount;

  @override
  void initState() {
    super.initState();
    _selectedAmount = widget.maxCards;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF292535),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Configurar partida',
                style: TextStyle(
                  color: Color(0xFFFBCB4E),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Escolha quantos cards deseja jogar nesta rodada.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    '$_selectedAmount card(s)',
                    style: const TextStyle(
                      color: Color(0xFFFBCB4E),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value: _selectedAmount.toDouble(),
                    min: 1,
                    max: widget.maxCards.toDouble(),
                    divisions: widget.maxCards == 1 ? 1 : widget.maxCards - 1,
                    activeColor: const Color(0xFFFBCB4E),
                    inactiveColor: Colors.white24,
                    label: '$_selectedAmount',
                    onChanged: (value) {
                      setState(() {
                        _selectedAmount = value.round();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        StartGameConfig(quantidade: _selectedAmount),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBCB4E),
                      foregroundColor: const Color(0xFF292535),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Jogar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}