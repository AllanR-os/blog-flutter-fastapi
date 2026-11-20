/// Guarda los datos y el JWT del usuario autenticado mientras la app está abierta.
class Sesion {
  static Map<String, dynamic>? usuario;
  static String? token;

  static void iniciar(Map<String, dynamic> datos) {
    token = datos['access_token']?.toString();
    usuario = Map<String, dynamic>.from(datos)..remove('access_token')..remove('token_type');
  }

  static bool get tieneToken => token != null && token!.isNotEmpty;

  static int? get idUsuario => (usuario?['id_usr'] as num?)?.toInt();

  static String get nombre => usuario?['nom_usr']?.toString() ?? 'Usuario';

  static bool get esAdmin =>
      tieneToken && (usuario?['tip_usu'] as num?)?.toInt() == 1;

  static Map<String, String> get headersAuth => {
        'Accept': 'application/json',
        if (tieneToken) 'Authorization': 'Bearer $token',
      };

  static Map<String, String> get headersJson => {
        'Content-Type': 'application/json',
        ...headersAuth,
      };

  static void cerrar() {
    usuario = null;
    token = null;
  }
}
