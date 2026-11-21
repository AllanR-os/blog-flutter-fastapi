import 'package:flutter/material.dart';

import '../services/carrito.dart';
import '../services/sesion.dart';
import '../theme/app_theme.dart';

class AdminDrawer extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final String rutaActual;

  const AdminDrawer({
    super.key,
    required this.usuario,
    required this.rutaActual,
  });

  /// Pantallas sin menú lateral: se abren encima para poder regresar con ←
  static const Set<String> _rutasEncima = {
    '/register',
    '/tienda',
    '/add-producto',
    '/pedidos-admin',
  };

  String get nombre => usuario['nom_usr']?.toString() ?? 'Administrador';
  String get correo => usuario['mail']?.toString() ?? '';

  void _navegar(BuildContext context, String ruta) {
    Navigator.pop(context);
    if (ruta == rutaActual) return;

    if (_rutasEncima.contains(ruta)) {
      Navigator.pushNamed(context, ruta, arguments: usuario);
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      ruta,
      arguments: usuario,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: AppColores.superficieAlta,
                border: Border(
                  bottom: BorderSide(color: AppColores.acento, width: 2),
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: AppColores.acento,
                child: Icon(Icons.admin_panel_settings,
                    color: AppColores.fondo, size: 34),
              ),
              accountName: Text(nombre, style: AppTheme.titulo(size: 18)),
              accountEmail: Text(
                correo,
                style: const TextStyle(color: AppColores.textoSuave),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _opcion(context, Icons.people_alt_outlined,
                      'Gestión de usuarios', '/users'),
                  _opcion(context, Icons.person_add_alt_1, 'Registrar usuario',
                      '/register'),
                  _opcion(context, Icons.article_outlined, 'Blog', '/blog'),
                  _opcion(context, Icons.post_add, 'Agregar blog', '/add-blog'),
                  _opcion(context, Icons.account_circle_outlined, 'Mi perfil',
                      '/profile'),
                  const Divider(),
                  _opcion(context, Icons.storefront, 'Tienda', '/tienda'),
                  _opcion(context, Icons.add_business, 'Agregar producto',
                      '/add-producto'),
                  _opcion(context, Icons.receipt_long, 'Pedidos de clientes',
                      '/pedidos-admin'),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColores.error),
              title: const Text('Cerrar sesión',
                  style: TextStyle(color: AppColores.error)),
              onTap: () {
                Sesion.cerrar();
                Carrito.instancia.vaciar();
                Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _opcion(
    BuildContext context,
    IconData icono,
    String titulo,
    String ruta,
  ) {
    final seleccionado = ruta == rutaActual;
    return ListTile(
      leading: Icon(icono,
          color: seleccionado ? AppColores.acento : null),
      title: Text(titulo),
      selected: seleccionado,
      onTap: () => _navegar(context, ruta),
    );
  }
}
