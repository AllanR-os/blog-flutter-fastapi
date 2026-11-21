import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../services/sesion.dart';
import '../theme/app_theme.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {

  final TextEditingController usuarioController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final AuthService authService =
      AuthService();
  
  bool cargando = false;

  bool ocultarPassword = true;

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();

    super.dispose();
  }
  Future<void> iniciarSesion() async {
    final mensaje = authService.validarLogin(
      usuario: usuarioController.text,
      password: passwordController.text,
    );

    if (mensaje != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      final usuario = await authService.autenticar(
        correo: usuarioController.text,
        password: passwordController.text,
      );

      if (!mounted) return;
      Sesion.iniciar(usuario);

      final int tipoUsuario = (usuario['tip_usu'] as num).toInt();

      if (tipoUsuario == 1) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/users',
          (route) => false,
          arguments: Sesion.usuario,
        );
      } else if (tipoUsuario == 2) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/blog',
          (route) => false,
          arguments: Sesion.usuario,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El tipo de usuario no tiene acceso asignado'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: AuthBackground(

        child: Center(

          child: AuthCard(

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                const _Logo(),
                const SizedBox(height: 6),
                const Text(
                  'Inicia sesión para continuar',
                  style: TextStyle(color: AppColores.textoSuave),
                ),
                const SizedBox(height: 28),

                CustomTextField(
                  controller:
                      usuarioController,
                  label: 'Correo electrónico',

                  prefixIcon:
                      Icons.person,
                  keyboardType:
                      TextInputType.emailAddress,
                ),

                const SizedBox(
                  height: 15,
                ),

                CustomTextField(
                  controller:
                      passwordController,

                  label: 'Contraseña',

                  prefixIcon:
                      Icons.lock_outline,

                  obscureText:
                      ocultarPassword,

                  suffixIcon:
                      IconButton(

                    icon: Icon(
                      ocultarPassword
                          ? Icons
                              .visibility_off_outlined
                          : Icons
                              .visibility_outlined,
                    ),

                    onPressed: () {

                      setState(() {

                        ocultarPassword =
                            !ocultarPassword;

                      });
                    },
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                PrimaryButton(
                  text: cargando ? 'VALIDANDO...' : 'INGRESAR',
                onPressed: cargando
                     ? () {}
                     : () {
                          iniciarSesion();
                        },
                  ),

                const SizedBox(
                  height: 15,
                ),

                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes cuenta?',
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/register',
                        );
                      },
                      child: const Text(
                        'Registrarse',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo de la app: control + nombre.
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColores.acento,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.sports_esports, color: AppColores.fondo, size: 28),
        ),
        const SizedBox(width: 12),
        Text(AppTheme.nombreApp, style: AppTheme.titulo(size: 32)),
      ],
    );
  }
}
