import 'package:flutter/material.dart';

import '../models/comentario_model.dart';
import '../models/post_model.dart';
import '../services/comentario_service.dart';
import '../services/sesion.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/portada.dart';
import '../widgets/post_card.dart';

/// Comentario listo para mostrarse, con el nombre de su autor.
class _ComentarioVista {
  final ComentarioModel datos;
  final String autor;

  _ComentarioVista(this.datos, this.autor);
}

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
  final UserService userService = UserService();
  final TextEditingController comentarioController = TextEditingController();

  late Future<List<_ComentarioVista>> futuroComentarios;
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

  /// Lee los comentarios de esta publicación y les pone el nombre del autor.
  Future<List<_ComentarioVista>> _cargarComentarios() async {
    final comentarios = await comentarioService.obtenerComentarios();
    final usuarios = await userService.obtenerUsuarios();
    final nombres = {for (final u in usuarios) u.id: u.nombre};

    final deEstePost = comentarios
        .where((c) => c.blogId == widget.post.id && c.estatus == 1)
        .toList()
      ..sort((a, b) => b.id.compareTo(a.id)); // más recientes primero

    return deEstePost
        .map((c) => _ComentarioVista(c, nombres[c.usuarioId] ?? 'Jugador'))
        .toList();
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
    if (usuarioId == null) {
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
    return FutureBuilder<List<_ComentarioVista>>(
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

  Widget _tarjetaComentario(_ComentarioVista c) {
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
                      _fechaLegible(c.datos.fecha),
                      style: const TextStyle(
                        color: AppColores.textoSuave,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(c.datos.comentario, style: const TextStyle(height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
