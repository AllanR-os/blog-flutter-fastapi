import 'package:flutter/material.dart';
import 'screens/add_blog_page.dart';
import 'screens/agregar_producto_page.dart';
import 'screens/blog_page.dart';
import 'screens/carrito_page.dart';
import 'screens/login_user_page.dart';
import 'screens/mis_pedidos_page.dart';
import 'screens/pago_page.dart';
import 'screens/profile_page.dart';
import 'screens/register_user_page.dart';
import 'screens/tienda_page.dart';
import 'screens/users_page.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplicación móvil con FastAPI',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/users': (context) => const UsersPage(),
        '/blog': (context) => const BlogPage(),
        '/add-blog': (context) => const AddBlogPage(),
        '/profile': (context) => const ProfilePage(),
        // Módulo de venta y comercio electrónico
        '/tienda': (context) => const TiendaPage(),
        '/carrito': (context) => const CarritoPage(),
        '/pago': (context) => const PagoPage(),
        '/mis-pedidos': (context) => const MisPedidosPage(),
        '/add-producto': (context) => const AgregarProductoPage(),
      },
    );
  }
}
