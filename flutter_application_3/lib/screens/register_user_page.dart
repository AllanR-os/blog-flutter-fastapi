import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService();
  final UserService userService = UserService();

  Map<String, dynamic> usuarioActual = {};
  bool esAdmin = false;
  bool argumentoLeido = false;
  int tipoUsuario = 2; // 1 = Administrador, 2 = General
  bool guardando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (argumentoLeido) return;

    final argumento = ModalRoute.of(context)?.settings.arguments;
    if (argumento is Map<String, dynamic>) {
      usuarioActual = Map<String, dynamic>.from(argumento);
      esAdmin = (usuarioActual['tip_usu'] as num? ?? 2).toInt() == 1;
    }
    argumentoLeido = true;
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    direccionController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  void regresar() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else if (esAdmin) {
      Navigator.pushReplacementNamed(context, '/users', arguments: usuarioActual);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> registrarUsuario() async {
    final mensaje = authService.validarRegistro(
      nombre: nombreController.text.trim(),
      correo: correoController.text.trim(),
      password: passwordController.text,
      confirmarpassword: passwordController.text,
    );

    if (mensaje != null) {
      mostrarMensaje(mensaje);
      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      final direccion = direccionController.text.trim();

      final nuevo = await userService.agregarUsuario(
        UserModel(
          id: 0,
          nombre: nombreController.text.trim(),
          correo: correoController.text.trim().toLowerCase(),
          password: passwordController.text,
          direccion: direccion.isEmpty ? null : direccion,
          tipoUsuario: esAdmin ? tipoUsuario : 2,
        ),
      );

      if (!mounted) return;

      if (esAdmin) {
        mostrarMensaje('Usuario ${nuevo.nombre} registrado correctamente');
        nombreController.clear();
        correoController.clear();
        direccionController.clear();
        passwordController.clear();
        setState(() {
          tipoUsuario = 2;
        });
      } else {
        mostrarMensaje('Cuenta creada. Ahora inicia sesión.');
        regresar();
      }
    } catch (e) {
      if (!mounted) return;
      mostrarMensaje(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            child: AuthCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_add,
                    size: 65,
                    color: Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    esAdmin ? 'REGISTRAR USUARIO' : 'CREAR CUENTA',
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF08245C),
                    ),
                  ),
                  const SizedBox(height: 25),
                  CustomTextField(
                    controller: nombreController,
                    label: 'Nombre completo',
                    prefixIcon: Icons.person,
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    controller: correoController,
                    label: 'Correo electrónico',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    controller: direccionController,
                    label: 'Dirección (opcional)',
                    prefixIcon: Icons.home,
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    controller: passwordController,
                    label: 'Contraseña',
                    prefixIcon: Icons.lock,
                    obscureText: true,
                  ),
                  if (esAdmin) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Tipo de usuario',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF08245C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(
                          value: 1,
                          label: Text('Administrador'),
                          icon: Icon(Icons.admin_panel_settings),
                        ),
                        ButtonSegment(
                          value: 2,
                          label: Text('General'),
                          icon: Icon(Icons.person_outline),
                        ),
                      ],
                      selected: {tipoUsuario},
                      onSelectionChanged: (seleccion) {
                        setState(() {
                          tipoUsuario = seleccion.first;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 25),
                  PrimaryButton(
                    text: guardando
                        ? 'GUARDANDO...'
                        : (esAdmin ? 'REGISTRAR' : 'REGISTRARME'),
                    onPressed: guardando
                        ? () {}
                        : () {
                            registrarUsuario();
                          },
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: regresar,
                    child: Text(
                      esAdmin ? 'Regresar al panel' : 'Ya tengo una cuenta',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}