import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/sesion.dart';
import '../theme/app_theme.dart';
import 'portada.dart';

/// Separa "Guías, PC" en ["Guías", "PC"].
List<String> separarTags(String tags) => tags
    .split(',')
    .map((t) => t.trim())
    .where((t) => t.isNotEmpty)
    .toList();

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final etiquetas = separarTags(post.tags);
    final esPropia =
        Sesion.idUsuario != null && post.usuarioId == Sesion.idUsuario;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColores.superficie,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColores.borde),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: AppColores.acento.withValues(alpha: 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Portada(
                url: post.imagen,
                texto: '${post.tags} ${post.titulo}',
                semilla: post.id,
                altura: 170,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (etiquetas.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: etiquetas
                            .map((t) => _Etiqueta(texto: t))
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Text(post.titulo, style: AppTheme.titulo(size: 21)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 15,
                          color: AppColores.textoSuave,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Por ${post.autor}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColores.textoSuave,
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
                    const SizedBox(height: 8),
                    Text(
                      post.descripcion,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColores.textoSuave,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      children: [
                        Text(
                          'Leer más',
                          style: TextStyle(
                            color: AppColores.acento,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppColores.acento,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;

  const _Etiqueta({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColores.secundario.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(
          color: AppColores.secundario,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
