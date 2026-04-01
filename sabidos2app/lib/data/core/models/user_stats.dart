class UserStats {
  final int resumosCriados;
  final int pomodorosConcluidos;
  final int flashcardsCriados;
  final int eventosCriados;
  final int diasSequencia;
  final int totalAcoes;

  const UserStats({
    required this.resumosCriados,
    required this.pomodorosConcluidos,
    required this.flashcardsCriados,
    required this.eventosCriados,
    required this.diasSequencia,
    required this.totalAcoes,
  });

  factory UserStats.empty() {
    return const UserStats(
      resumosCriados: 0,
      pomodorosConcluidos: 0,
      flashcardsCriados: 0,
      eventosCriados: 0,
      diasSequencia: 0,
      totalAcoes: 0,
    );
  }

  factory UserStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) return UserStats.empty();

    return UserStats(
      resumosCriados: (map['resumosCriados'] ?? 0) as int,
      pomodorosConcluidos: (map['pomodorosConcluidos'] ?? 0) as int,
      flashcardsCriados: (map['flashcardsCriados'] ?? 0) as int,
      eventosCriados: (map['eventosCriados'] ?? 0) as int,
      diasSequencia: (map['diasSequencia'] ?? 0) as int,
      totalAcoes: (map['totalAcoes'] ?? 0) as int,
    );
  }
}