/// Guarda los datos del usuario que inició sesión mientras la app está abierta.
class Sesion {
  static Map<String, dynamic>? usuario;

  static int? get idUsuario => (usuario?['id_usr'] as num?)?.toInt();

  static String get nombre => usuario?['nom_usr']?.toString() ?? 'Usuario';

  static bool get esAdmin => (usuario?['tip_usu'] as num?)?.toInt() == 1;

  static void cerrar() {
    usuario = null;
  }
}
