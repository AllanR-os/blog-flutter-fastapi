import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application_3/models/producto_model.dart';
import 'package:flutter_application_3/screens/login_user_page.dart';
import 'package:flutter_application_3/screens/register_user_page.dart';
import 'package:flutter_application_3/services/auth_service.dart';
import 'package:flutter_application_3/services/carrito.dart';
import 'package:flutter_application_3/services/sesion.dart';
import 'package:flutter_application_3/widgets/admin_drawer.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    Sesion.cerrar();
    Carrito.instancia.vaciar();
  });

  testWidgets('LoginPage muestra controles activos y oculta enlaces sin accion',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('RESPAWN'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('INGRESAR'), findsOneWidget);
    expect(find.text('Registrarse'), findsOneWidget);
    expect(find.text('¿Olvidaste tu contraseña?'), findsNothing);
  });

  testWidgets('RegisterPage publico oculta selector de rol',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    expect(find.text('Únete a Respawn'), findsOneWidget);
    expect(find.text('REGISTRARME'), findsOneWidget);
    expect(find.text('Tipo de usuario'), findsNothing);
  });

  testWidgets('RegisterPage con sesion Admin muestra selector de rol',
      (WidgetTester tester) async {
    Sesion.iniciar({
      'id_usr': 1,
      'nom_usr': 'Adriana Contreras',
      'mail': 'adriana@ejemplo.com',
      'tip_usu': 1,
      'access_token': 'token-admin-test',
    });

    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    expect(find.text('Registrar jugador'), findsOneWidget);
    expect(find.text('Tipo de usuario'), findsOneWidget);
    expect(find.text('Administrador'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('REGISTRAR'), findsOneWidget);
  });

  testWidgets('AdminDrawer incluye enlaces clave de administracion, blog y ventas',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdminDrawer(
            usuario: {
              'nom_usr': 'Adriana Contreras',
              'mail': 'adriana@ejemplo.com',
              'tip_usu': 1,
            },
            rutaActual: '/users',
          ),
        ),
      ),
    );

    expect(find.text('Gestión de usuarios'), findsOneWidget);
    expect(find.text('Blog'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Pedidos de clientes'), 100);
    expect(find.text('Tienda'), findsOneWidget);
    expect(find.text('Pedidos de clientes'), findsOneWidget);
  });

  test('Carrito respeta stock, calcula totales y limpia estado', () {
    final carrito = Carrito.instancia;
    final control = ProductoModel(
      id: 1,
      nombre: 'Control Pro',
      precio: 1299.0,
      stock: 2,
    );

    expect(carrito.agregar(control), isTrue);
    expect(carrito.agregar(control), isTrue);
    expect(carrito.agregar(control), isFalse);
    expect(carrito.totalArticulos, 2);
    expect(carrito.total, 2598.0);

    carrito.quitarUno(1);
    expect(carrito.totalArticulos, 1);
    expect(carrito.total, 1299.0);

    carrito.vaciar();
    expect(carrito.estaVacio, isTrue);
    expect(carrito.total, 0.0);
  });

  test('AuthService valida credenciales y formato de registro', () {
    final auth = AuthService();

    expect(auth.validarLogin(usuario: '', password: '123'), isNotNull);
    expect(auth.validarLogin(usuario: 'a@b.com', password: '123'), isNull);

    expect(
      auth.validarRegistro(
        nombre: 'Sofia',
        correo: 'invalido',
        password: 'password123',
        confirmarpassword: 'password123',
      ),
      'Ingresa un correo válido',
    );
    expect(
      auth.validarRegistro(
        nombre: 'Sofia',
        correo: 'sofia@ejemplo.com',
        password: '123',
        confirmarpassword: '123',
      ),
      'La contraseña debe tener al menos 8 caracteres',
    );
    expect(
      auth.validarRegistro(
        nombre: 'Sofia',
        correo: 'sofia@ejemplo.com',
        password: 'password123',
        confirmarpassword: 'password123',
      ),
      isNull,
    );
  });
}
