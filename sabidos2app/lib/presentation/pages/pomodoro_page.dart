import 'dart:async';
import 'package:flutter/material.dart';

class ProgressoCircular extends StatefulWidget {
  const ProgressoCircular({super.key});

  @override
  State<ProgressoCircular> createState() => _ProgressoCircularState();
}

class _ProgressoCircularState extends State<ProgressoCircular> {
  // Timer
  int tempo = 0;
  int tempoMaximo = 0;
  bool ativo = false;
  bool pausado = false;
  bool modoDescanso = false;

  int entrada = 25;

  // Ciclos
  int ciclos = 3;
  int cicloAtual = 0;
  int descansoCurto = 5;
  int descansoLongo = 15;

  List<int> temposTrabalho = [];
  List<int> temposDescanso = [];

  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // 🔁 LOOP PRINCIPAL (equivalente ao useEffect)
  void iniciarTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!ativo || pausado) return;

      if (tempo > 0) {
        setState(() => tempo--);
      } else {
        tratarFim();
      }
    });
  }

  void tratarFim() {
    if (!modoDescanso) {
      // terminou foco
      temposTrabalho.add(tempoMaximo);
      iniciarDescanso();
    } else {
      temposDescanso.add(tempoMaximo);

      if (cicloAtual < ciclos - 1) {
        cicloAtual++;
        iniciarFoco();
      } else {
        // descanso longo ou fim
        if (tempoMaximo != descansoLongo * 60) {
          iniciarDescansoLongo();
        } else {
          resetar();
        }
      }
    }
  }

  // 🎯 AÇÕES
  void iniciarFoco() {
    setState(() {
      tempo = entrada * 60;
      tempoMaximo = tempo;
      modoDescanso = false;
      ativo = true;
      pausado = false;
    });

    iniciarTimer();
  }

  void iniciarDescanso() {
    setState(() {
      tempo = descansoCurto * 60;
      tempoMaximo = tempo;
      modoDescanso = true;
    });
  }

  void iniciarDescansoLongo() {
    setState(() {
      tempo = descansoLongo * 60;
      tempoMaximo = tempo;
      modoDescanso = true;
    });
  }

  void resetar() {
    timer?.cancel();
    setState(() {
      ativo = false;
      pausado = false;
      tempo = 0;
      tempoMaximo = 0;
      cicloAtual = 0;
      modoDescanso = false;
    });
  }

  String formatarTempo(int segundos) {
    final min = segundos ~/ 60;
    final sec = segundos % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  double get progresso => tempoMaximo > 0 ? tempo / tempoMaximo : 0;
  // ============================
  // 🔧 CONFIGURAÇÕES
  // ============================

  Widget buildConfiguracoes() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        // 🔥 Trabalho Focado
        buildConfigCard(
          titulo: "Trabalho Focado",
          valor: entrada,
          ativo: ativo,
          min: 1,
          max: 60,
          onChanged: (value) {
            setState(() => entrada = value);
          },
        ),

        // 🔄 Ciclos
        buildConfigCard(
          titulo: "Nº de Ciclos",
          valor: ciclos,
          ativo: ativo,
          min: 1,
          max: 10,
          mostrarTempo: false,
          onChanged: (value) {
            setState(() => ciclos = value);
          },
        ),

        // 😌 Descanso Curto
        buildConfigCard(
          titulo: "Descanso Curto",
          valor: descansoCurto,
          ativo: ativo,
          min: 1,
          max: 10,
          onChanged: (value) {
            setState(() => descansoCurto = value);
          },
        ),

        // 🛌 Descanso Longo
        buildConfigCard(
          titulo: "Descanso Longo",
          valor: descansoLongo,
          ativo: ativo,
          min: 1,
          max: 30,
          onChanged: (value) {
            setState(() => descansoLongo = value);
          },
        ),
      ],
    );
  }

  // ============================
  // 🎴 CARD DE CONFIGURAÇÃO
  // ============================

  Widget buildConfigCard({
    required String titulo,
    required int valor,
    required bool ativo,
    required Function(int) onChanged,
    required int min,
    required int max,
    bool mostrarTempo = true,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF292535), Color(0xFF3B2868)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          // 📝 Título
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 10),

          // 🔘 Controles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ➖ Diminuir
              buildControlButton(
                icon: Icons.remove,
                onTap: ativo
                    ? null
                    : () {
                        if (valor > min) {
                          onChanged(valor - 1);
                        }
                      },
              ),

              const SizedBox(width: 8),

              // 🔢 Valor
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF7763B3), width: 2),
                ),
                child: Text(
                  mostrarTempo ? "$valor:00" : "$valor",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ativo ? Colors.white54 : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ➕ Aumentar
              buildControlButton(
                icon: Icons.add,
                onTap: ativo
                    ? null
                    : () {
                        if (valor < max) {
                          onChanged(valor + 1);
                        }
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================
  // 🔘 BOTÃO PEQUENO
  // ============================

  Widget buildControlButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey : const Color(0xFF7763B3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cor = modoDescanso ? Colors.blue : Colors.red;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              modoDescanso ? "Descanso" : "Foco",
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),

            const SizedBox(height: 10),

            Text(
              "Ciclo ${cicloAtual + 1} de $ciclos",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // ⭕ CÍRCULO
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progresso,
                    strokeWidth: 8,
                  ),
                ),
                Text(
                  formatarTempo(tempo),
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 🎮 BOTÕES
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!ativo)
                  ElevatedButton(
                    onPressed: iniciarFoco,
                    child: const Icon(Icons.play_arrow),
                  )
                else ...[
                  ElevatedButton(
                    onPressed: () {
                      setState(() => pausado = !pausado);
                    },
                    child: Icon(pausado ? Icons.play_arrow : Icons.pause),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: resetar,
                    child: const Icon(Icons.stop),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
