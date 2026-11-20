import 'package:flutter/foundation.dart';

import '../models/producto_model.dart';

class ItemCarrito {
  final ProductoModel producto;
  int cantidad;

  ItemCarrito({required this.producto, this.cantidad = 1});

  double get subtotal => producto.precio * cantidad;
}

/// Carrito de compras compartido por todas las pantallas de la tienda.
/// Avisa a las pantallas (notifyListeners) cada vez que cambia.
class Carrito extends ChangeNotifier {
  Carrito._();

  static final Carrito instancia = Carrito._();

  final Map<int, ItemCarrito> _items = {};

  List<ItemCarrito> get items => _items.values.toList();

  bool get estaVacio => _items.isEmpty;

  int get totalArticulos =>
      _items.values.fold(0, (suma, item) => suma + item.cantidad);

  double get total =>
      _items.values.fold(0.0, (suma, item) => suma + item.subtotal);

  int cantidadDe(int productoId) => _items[productoId]?.cantidad ?? 0;

  /// Devuelve false si ya no hay stock suficiente.
  bool agregar(ProductoModel producto) {
    final item = _items[producto.id];
    final actual = item?.cantidad ?? 0;
    if (actual >= producto.stock) return false;

    if (item == null) {
      _items[producto.id] = ItemCarrito(producto: producto);
    } else {
      item.cantidad++;
    }
    notifyListeners();
    return true;
  }

  void quitarUno(int productoId) {
    final item = _items[productoId];
    if (item == null) return;
    item.cantidad--;
    if (item.cantidad <= 0) _items.remove(productoId);
    notifyListeners();
  }

  void eliminar(int productoId) {
    _items.remove(productoId);
    notifyListeners();
  }

  void vaciar() {
    _items.clear();
    notifyListeners();
  }
}
