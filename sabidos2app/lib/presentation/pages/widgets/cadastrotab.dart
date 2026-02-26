import 'package:flutter/material.dart';
import 'package:sabidos2app/presentation/pages/widgets/inputDecoration.dart';
import 'package:sabidos2app/presentation/pages/widgets/gradientBorderButton.dart';
class CadastroTab extends StatelessWidget {
  const CadastroTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
  builder: (context, constraints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            const Text(
              "Cadastro",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            customInput("Nome"),
            const SizedBox(height: 16),

            customInput("Email"),
            const SizedBox(height: 16),

            customInput("Senha", obscure: true),
            const SizedBox(height: 16),

            customInput("Confirmar Senha", obscure: true),
            const SizedBox(height: 24),

            gradientBorderButton("Entrar"),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: const Color(0xFF3F3C4E),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF3F3C4E)),
                  ),
                  child: const Text(
                    "ou",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: const Color(0xFF3F3C4E),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
                      Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1F1C2C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3F3C4E)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              // child: Image.network(
              //   "https://www.svgrepo.com/show/355037/google.png",
              // ),
            ),
          ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  },
);
  }
}