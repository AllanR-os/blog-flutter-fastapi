import 'package:flutter/material.dart';

import '../models/comentario_model.dart';
import '../models/post_model.dart';
import '../services/comentario_service.dart';
import '../services/sesion.dart';
import '../theme/app_theme.dart';
import '../widgets/portada.dart';
import '../widgets/post_card.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;

  const PostDetailPage({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final ComentarioService comentarioService = ComentarioService();
  final TextEditingController comentarioController = TextEditingController();

  late Future<List<ComentarioModel>> futuroComentarios;
  bool enviando = false;

  @override
  void initState() {
    super.initState();
    futuroComentarios = _cargarComentarios();
  }

  @override
  void dispose() {
    comentarioController.dispose();
    super.dispose();
  }

  /// Consulta los comentarios activos de esta publicación con su autor incluido.
  Future<List<ComentarioModel>> _cargarComentarios() async {
    final comentarios = await comentarioService.obtenerComentarios(
      blogId: widget.post.id,
    );
    return comentarios.where((c) => c.estatus == 1).toList();
  }

  void _recargar() {
    setState(() {
      futuroComentarios = _cargarComentarios();
    });
  }

  Future<void> _enviarComentario() async {
    final texto = comentarioController.text.trim();
    final usuarioId = Sesion.idUsuario;

    if (texto.isEmpty) return;
    if (usuarioId == null || !Sesion.tieneToken) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para comentar')),
      );
      return;
    }

    setState(() => enviando = true);

    try {
      await comentarioService.agregarComentario(
        ComentarioModel(
          id: 0,
          comentario: texto,
          fecha: '',
          estatus: 1,
          usuarioId: usuarioId,
          blogId: widget.post.id,
          autor: Sesion.nombre,
        ),
      );
      comentarioController.clear();
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      _recargar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario publicado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  String _fechaLegible(String fecha) {
    final f = DateTime.tryParse(fecha);
    if (f == null) return '';
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(f.day)}/${dos(f.month)}/${f.year} ${dos(f.hour)}:${dos(f.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final etiquetas = separarTags(post.tags);
    final esPropia =
        Sesion.idUsuario != null && post.usuarioId == Sesion.idUsuario;

    return Scaffold(
      appBar: AppBar(
        title: Text('Publicación', style: AppTheme.titulo(size: 20)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Portada(
              url: post.imagen,
              texto: '${post.tags} ${post.titulo}',
              semilla: post.id,
              altura: 240,
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (etiquetas.isNotEmpty) ...[
                        Text(
                          etiquetas.join('  ·  ').toUpperCase(),
                          style: const TextStyle(
                            color: AppColores.secundario,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Text(post.titulo, style: AppTheme.titulo(size: 30)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 16,
                            color: AppColores.textoSuave,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Por ${post.autor}',
                            style: const TextStyle(
                              color: AppColores.textoSuave,
                              fontSize: 14,
                            ),
                          ),
                          if (esPropia) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColores.acento.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'TUYA',
                                style: TextStyle(
                                  color: AppColores.acento,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        post.descripcion.isNotEmpty
                            ? post.descripcion
                            : 'Esta publicación no tiene descripción.',
                        style: const TextStyle(fontSize: 17, height: 1.7),
                      ),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 20),
                      _seccionComentarios(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccionComentarios() {
    return FutureBuilder<List<ComentarioModel>>(
      future: futuroComentarios,
      builder: (context, snapshot) {
        final comentarios = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              snapshot.hasData
                  ? 'Comentarios (${comentarios.length})'
                  : 'Comentarios',
              style: AppTheme.titulo(size: 22),
            ),
            const SizedBox(height: 14),
            _cajaComentario(),
            const SizedBox(height: 20),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (snapshot.hasError)
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'No se pudieron cargar los comentarios.',
                      style: TextStyle(color: AppColores.error),
                    ),
                  ),
                  TextButton(onPressed: _recargar, child: const Text('Reintentar')),
                ],
              )
            else if (comentarios.isEmpty)
              const Text(
                'Sé el primero en comentar.',
                style: TextStyle(color: AppColores.textoSuave),
              )
            else
              ...comentarios.map(_tarjetaComentario),
          ],
        );
      },
    );
  }

  Widget _cajaComentario() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColores.superficie,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColores.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: comentarioController,
            minLines: 2,
            maxLines: 5,
            cursorColor: AppColores.acento,
            decoration: InputDecoration(
              hintText: 'Escribe un comentario como ${Sesion.nombre}...',
              hintStyle: const TextStyle(color: AppColores.textoSuave),
              border: InputBorder.none,
            ),
          ),
          ElevatedButton.icon(
            onPressed: enviando ? null : _enviarComentario,
            icon: enviando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send, size: 18),
            label: const Text('Publicar'),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaComentario(ComentarioModel c) {
    final inicial = c.autor.isNotEmpty ? c.autor[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColores.secundario.withValues(alpha: 0.18),
            child: Text(
              inicial,
              style: const TextStyle(
                color: AppColores.secundario,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      c.autor,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _fechaLegible(c.fecha),
                      style: const TextStyle(
                        color: AppColores.textoSuave,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(c.comentario, style: const TextStyle(height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
