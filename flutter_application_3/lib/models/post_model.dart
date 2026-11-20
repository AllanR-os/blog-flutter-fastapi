class PostModel {
  final int id;
  final String titulo;
  final String descripcion;
  final String imagen;
  final String tags;
  final int usuarioId;
  final String autor;

  const PostModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.imagen,
    required this.tags,
    required this.usuarioId,
    required this.autor,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: (json['id_blog'] as num).toInt(),
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      imagen: json['img']?.toString() ?? '',
      tags: json['tags']?.toString() ?? '',
      usuarioId: (json['usr_id'] as num?)?.toInt() ?? 0,
      autor: json['autor']?.toString() ?? 'Jugador',
    );
  }
}
