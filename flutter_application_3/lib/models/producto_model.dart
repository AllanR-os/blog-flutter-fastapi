/// Da formato de dinero: 349.5 -> "$349.50"
String precioTexto(double valor) => '\$${valor.toStringAsFixed(2)}';

class ProductoModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final int stock;
  final String? img;

  ProductoModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    required this.stock,
    this.img,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id_prod'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      precio: (json['precio'] as num).toDouble(),
      stock: (json['stock'] as num).toInt(),
      img: json['img'] as String?,
    );
  }

  Map<String, dynamic> toJsonCrear() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'img': img,
    };
  }
}
