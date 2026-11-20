import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/carrito.dart';
import '../services/post_service.dart';
import '../services/sesion.dart';
import '../widgets/post_card.dart';
import 'post_detail_page.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/category_chip.dart';
import '../theme/app_theme.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final PostService postService = PostService();
  late Future<List<PostModel>> futurePosts;
  String nombreUsuario = 'Usuario';
  Map<String, dynamic> usuarioActual = {'nom_usr': 'Usuario', 'mail': '', 'tip_usu': 2};
  bool argumentoLeido = false;
  String filtro = 'Todos';

  @override
  void initState() {
    super.initState();
    futurePosts = postService.obtenerPosts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!argumentoLeido) {
      final argumento = ModalRoute.of(context)?.settings.arguments;

      if (argumento is Map<String, dynamic>) {
        usuarioActual = Map<String, dynamic>.from(argumento);
        nombreUsuario = usuarioActual['nom_usr']?.toString() ?? 'Usuario';
      } else if (argumento is String && argumento.isNotEmpty) {
        nombreUsuario = argumento;
        usuarioActual = {'nom_usr': nombreUsuario, 'mail': '', 'tip_usu': 2};
      }

      argumentoLeido = true;
    }
  }

  void recargarPosts() {
    setState(() {
      futurePosts = postService.obtenerPosts();
    });
  }

  void cerrarSesion() {
    Sesion.cerrar();
    Carrito.instancia.vaciar();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final esAdmin = (usuarioActual['tip_usu'] as num? ?? 2).toInt() == 1;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppTheme.nombreApp, style: AppTheme.titulo(size: 20)),
            const Text(
              'Blog gamer',
              style: TextStyle(fontSize: 12, color: AppColores.textoSuave),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Tienda',
            icon: const Icon(Icons.storefront),
            onPressed: () => Navigator.pushNamed(context, '/tienda'),
          ),
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: recargarPosts,
          ),
          if (!esAdmin)
            IconButton(
              tooltip: 'Cerrar sesión',
              icon: const Icon(Icons.logout),
              onPressed: cerrarSesion,
            ),
        ],
      ),
      drawer: esAdmin
          ? AdminDrawer(usuario: usuarioActual, rutaActual: '/blog')
          : null,
      body: FutureBuilder<List<PostModel>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 45),
                    const SizedBox(height: 12),
                    const Text(
                      'No fue posible cargar el blog.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: recargarPosts,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final posts = snapshot.data ?? <PostModel>[];

          if (posts.isEmpty) {
            return const Center(
              child: Text('No hay publicaciones registradas.'),
            );
          }

          // Categorías a partir de las etiquetas de las publicaciones.
          final categorias = <String>{
            for (final p in posts) ...separarTags(p.tags),
          }.toList()
            ..sort();

          final visibles = filtro == 'Todos'
              ? posts
              : posts.where((p) => separarTags(p.tags).contains(filtro)).toList();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Hola, $nombreUsuario',
                    style: const TextStyle(color: AppColores.textoSuave),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lo último en videojuegos',
                    style: AppTheme.titulo(size: 30),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Reseñas, guías y noticias para la comunidad gamer.',
                    style: TextStyle(color: AppColores.textoSuave),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ['Todos', ...categorias]
                          .map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: CategoryChip(
                                text: c,
                                selected: filtro == c,
                                onTap: () => setState(() => filtro = c),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (visibles.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No hay publicaciones en esta categoría.'),
                    ),
                  ...visibles.map(
                    (post) => PostCard(
                      post: post,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => PostDetailPage(post: post),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
