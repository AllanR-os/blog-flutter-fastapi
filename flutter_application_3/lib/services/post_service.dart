import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';
import 'sesion.dart';

class PostService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<PostModel> agregarPost({
    required String titulo,
    required String descripcion,
    String? imagen,
    String? tags,
  }) async {
    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/blog'),
          headers: Sesion.headersJson,
          body: jsonEncode({
            'titulo': titulo.trim(),
            'descripcion': descripcion.trim(),
            'img': (imagen ?? '').trim().isEmpty ? null : imagen!.trim(),
            'tags': (tags ?? '').trim().isEmpty ? null : tags!.trim(),
          }),
        )
        .timeout(const Duration(seconds: 10));

    final dynamic resultado = respuesta.body.isNotEmpty
        ? jsonDecode(respuesta.body)
        : null;

    if ((respuesta.statusCode == 200 || respuesta.statusCode == 201) &&
        resultado is Map<String, dynamic>) {
      return PostModel.fromJson(resultado);
    }

    if (resultado is Map && resultado['detail'] != null) {
      throw Exception(resultado['detail'].toString());
    }
    throw Exception(
      'No se pudo guardar la publicación (HTTP ${respuesta.statusCode})',
    );
  }

  Future<List<PostModel>> obtenerPosts({bool soloMios = false}) async {
    final uri = Uri.parse('$baseUrl/blog').replace(
      queryParameters: soloMios ? {'solo_mios': 'true'} : null,
    );
    final respuesta = await http
        .get(uri, headers: Sesion.headersAuth)
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode != 200) {
      throw Exception('Error al consultar publicaciones (HTTP ${respuesta.statusCode})');
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);

    return datos
        .map(
          (json) => PostModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
