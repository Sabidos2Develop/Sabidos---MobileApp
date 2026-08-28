class PomodoroModel {
  final int id;
  final int tempo;

  PomodoroModel({required this.id, required this.tempo});

  factory PomodoroModel.fromJson(Map<String, dynamic> json) {
    return PomodoroModel(id: json['id'], tempo: json['tempo']);
  }
}
