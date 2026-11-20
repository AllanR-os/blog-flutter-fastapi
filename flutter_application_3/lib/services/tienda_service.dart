import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pedido_model.dart';
import '../models/producto_model.dart';
import 'carrito.dart';

class TiendaService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<List<ProductoModel>> obtenerProductos() async {
    final respuesta = await http
        .get(Uri.parse('$baseUrl/productos'))
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode != 200) {
      throw Exception(_mensajeError(respuesta));
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);
    return datos
        .map((json) => ProductoModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ProductoModel> crearProducto(ProductoModel producto) async {
    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/productos'),
          headers: _headers,
          body: jsonEncode(producto.toJsonCrear()),
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 201) {
      return ProductoModel.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }
    throw Exception(_mensajeError(respuesta));
  }

  /// Envía el carrito y los datos de la tarjeta. El pago es simulado.
  Future<PedidoModel> pagar({
    required int usuarioId,
    required List<ItemCarrito> items,
    required String titular,
    required String numeroTarjeta,
    required String vencimiento,
    required String cvv,
  }) async {
    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/pedidos'),
          headers: _headers,
          body: jsonEncode({
            'usr_id': usuarioId,
            'items': items
                .map((i) => {'prod_id': i.producto.id, 'cantidad': i.cantidad})
                .toList(),
            'pago': {
              'titular': titular.trim(),
              'numero': numeroTarjeta.trim(),
              'vencimiento': vencimiento.trim(),
              'cvv': cvv.trim(),
            },
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 201) {
      return PedidoModel.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }
    throw Exception(_mensajeError(respuesta));
  }

  Future<List<PedidoModel>> obtenerMisPedidos(int usuarioId) async {
    final respuesta = await http
        .get(Uri.parse('$baseUrl/pedidos/usuario/$usuarioId'))
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode != 200) {
      throw Exception(_mensajeError(respuesta));
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);
    return datos
        .map((json) => PedidoModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  String _mensajeError(http.Response respuesta) {
    try {
      final datos = jsonDecode(respuesta.body);
      if (datos is Map && datos['detail'] != null) {
        final detalle = datos['detail'];
        // Errores de validación de FastAPI (422) vienen como lista.
        if (detalle is List && detalle.isNotEmpty) {
          return 'Datos inválidos: ${detalle.first['msg']}';
        }
        return detalle.toString();
      }
    } catch (_) {
      // La respuesta no contiene JSON.
    }
    return 'Error HTTP ${respuesta.statusCode}';
  }
}
