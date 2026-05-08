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
