class AgendaEventModel {
  final String id;
  final String title;
  final DateTime date;
  final DateTime createdAt;

  AgendaEventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.createdAt,
  });

  factory AgendaEventModel.fromJson(Map<String, dynamic> json) {
    return AgendaEventModel(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
    };
  }
}
