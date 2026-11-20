import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../services/carrito.dart';
import '../theme/app_theme.dart';
import '../widgets/portada.dart';

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
      appBar: AppBar(
        title: Text('Mi carrito', style: AppTheme.titulo(size: 20)),
      ),
      body: AnimatedBuilder(
        animation: carrito,
        builder: (context, _) {
          if (carrito.estaVacio) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.remove_shopping_cart,
                      size: 64, color: AppColores.textoSuave),
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
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 52,
                          height: 52,
                          child: Portada(
                            url: item.producto.img,
                            texto: item.producto.nombre,
                            semilla: item.producto.id,
                          ),
                        ),
                      ),
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
                                color: AppColores.error),
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
                color: AppColores.superficie,
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
                                color: AppColores.acento,
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
