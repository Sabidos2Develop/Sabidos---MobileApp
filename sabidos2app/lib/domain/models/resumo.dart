class Resumo {
  final String id;
  final String titulo;
  final String descricao;
  final String data;
  final String userId;
  final String createdAt;

  Resumo({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.userId,
    required this.createdAt,
  });

  factory Resumo.fromMap(String id, Map<String, dynamic> map) {
    return Resumo(
      id: id,
      titulo: map['titulo'],
      descricao: map['descricao'],
      data: map['data'],
      userId: map['userId'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "titulo": titulo,
      "descricao": descricao,
      "data": data,
      "userId": userId,
      "createdAt": createdAt,
    };
  }
}
