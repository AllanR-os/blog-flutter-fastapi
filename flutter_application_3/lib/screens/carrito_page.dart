import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../services/carrito.dart';

class CarritoPage extends StatelessWidget {
  const CarritoPage({super.key});

  Future<void> irAPagar(BuildContext context) async {
    final pagado = await Navigator.pushNamed(context, '/pago');
    // Si el pago se completó, regresa a la tienda avisando que hubo compra.
    if (pagado == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final carrito = Carrito.instancia;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi carrito')),
      body: AnimatedBuilder(
        animation: carrito,
        builder: (context, _) {
          if (carrito.estaVacio) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.remove_shopping_cart,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Tu carrito está vacío'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Seguir comprando'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: carrito.items.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = carrito.items[index];
                    return ListTile(
                      title: Text(item.producto.nombre),
                      subtitle: Text(
                        '${precioTexto(item.producto.precio)} c/u  ·  '
                        'Subtotal: ${precioTexto(item.subtotal)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Quitar uno',
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () =>
                                carrito.quitarUno(item.producto.id),
                          ),
                          Text(
                            '${item.cantidad}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            tooltip: 'Agregar uno',
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              if (!carrito.agregar(item.producto)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No hay más stock disponible'),
                                  ),
                                );
                              }
                            },
                          ),
                          IconButton(
                            tooltip: 'Eliminar',
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () =>
                                carrito.eliminar(item.producto.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Material(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${carrito.totalArticulos} artículo(s)'),
                            Text(
                              'Total: ${precioTexto(carrito.total)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF08245C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => irAPagar(context),
                        icon: const Icon(Icons.payment),
                        label: const Text('Proceder al pago'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
