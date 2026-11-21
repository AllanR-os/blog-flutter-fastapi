class DetallePedidoModel {
  final int productoId;
  final String nombre;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  DetallePedidoModel({
    required this.productoId,
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory DetallePedidoModel.fromJson(Map<String, dynamic> json) {
    return DetallePedidoModel(
      productoId: json['prod_id'] as int,
      nombre: json['nombre'] as String,
      cantidad: (json['cantidad'] as num).toInt(),
      precioUnitario: (json['precio_unit'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}

class PedidoModel {
  final int id;
  final String? cliente;
  final String? correo;
  final String fecha;
  final double total;
  final String estatus;
  final String ultimos4;
  final List<DetallePedidoModel> detalles;

  PedidoModel({
    required this.id,
    this.cliente,
    this.correo,
    required this.fecha,
    required this.total,
    required this.estatus,
    required this.ultimos4,
    required this.detalles,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    return PedidoModel(
      id: json['id_ped'] as int,
      cliente: json['cliente'] as String?,
      correo: json['correo'] as String?,
      fecha: json['fecha'] as String,
      total: (json['total'] as num).toDouble(),
      estatus: json['estatus'] as String,
      ultimos4: json['ultimos4'] as String,
      detalles: (json['detalles'] as List<dynamic>)
          .map((d) => DetallePedidoModel.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convierte "2026-11-19T18:30:00" en "19/11/2026 18:30".
  String get fechaLegible {
    final f = DateTime.tryParse(fecha);
    if (f == null) return fecha;
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(f.day)}/${dos(f.month)}/${f.year} ${dos(f.hour)}:${dos(f.minute)}';
  }
}
