class EventoModel {
  final int id;
  final String titulo;
  final DateTime data;

  EventoModel({required this.id, required this.titulo, required this.data});

  factory EventoModel.fromJson(Map<String, dynamic> json) {
    return EventoModel(
      id: json['id'],
      titulo: json['titulo'],
      data: DateTime.parse(json['data']),
    );
  }
}
