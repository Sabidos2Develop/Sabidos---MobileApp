import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabidos2app/presentation/pages/widgets/inputDecoration.dart';
import 'package:sabidos2app/presentation/pages/widgets/gradientBorderButton.dart';
import 'package:sabidos2app/presentation/controllers/authController.dart';



class CadastroTab extends StatefulWidget {
  const CadastroTab({super.key});

  @override
  State<CadastroTab> createState() => _CadastroTabState();
}

class _CadastroTabState extends State<CadastroTab> {
  
    final nomeController = TextEditingController();
    final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final auth = context.read<AuthController>();

    try {
      await auth.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao fazer Register")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
     final auth = context.watch<AuthController>(); // ✅ corrigido

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

            customInput("Nome" , nomeController ),
            const SizedBox(height: 16),

            customInput("Email", emailController),
            const SizedBox(height: 16),

            customInput("Senha", passwordController , obscure: true),
            const SizedBox(height: 16),

            customInput("Confirmar Senha", confirmpasswordController , obscure: true),
            const SizedBox(height: 24),

           GradientBorderButton(
                  text: auth.isLoading ? "Entrando..." : "Login",
                  onPressed: auth.isLoading ? () {} : _handleRegister,
                ),

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