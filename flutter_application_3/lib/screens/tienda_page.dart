import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../services/carrito.dart';
import '../services/sesion.dart';
import '../services/tienda_service.dart';
import '../theme/app_theme.dart';
import '../widgets/portada.dart';

class TiendaPage extends StatefulWidget {
  const TiendaPage({super.key});

  @override
  State<TiendaPage> createState() => _TiendaPageState();
}

class _TiendaPageState extends State<TiendaPage> {
  final TiendaService tiendaService = TiendaService();
  final Carrito carrito = Carrito.instancia;
  late Future<List<ProductoModel>> futuroProductos;

  @override
  void initState() {
    super.initState();
    futuroProductos = tiendaService.obtenerProductos();
  }

  void recargar() {
    setState(() {
      futuroProductos = tiendaService.obtenerProductos();
    });
  }

  void agregarAlCarrito(ProductoModel producto) {
    final agregado = carrito.agregar(producto);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(
          agregado
              ? '${producto.nombre} agregado al carrito'
              : 'No hay más stock de ${producto.nombre}',
        ),
      ),
    );
  }

  Future<void> abrirCarrito() async {
    final compro = await Navigator.pushNamed(context, '/carrito');
    // Si se compró algo, el stock cambió: se vuelve a consultar.
    if (compro == true && mounted) recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tienda', style: AppTheme.titulo(size: 20)),
            Text(
              'Equípate, ${Sesion.nombre}',
              style: const TextStyle(fontSize: 12, color: AppColores.textoSuave),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: recargar,
          ),
          IconButton(
            tooltip: 'Mis pedidos',
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.pushNamed(context, '/mis-pedidos'),
          ),
          AnimatedBuilder(
            animation: carrito,
            builder: (context, _) => IconButton(
              tooltip: 'Carrito',
              onPressed: abrirCarrito,
              icon: Badge(
                isLabelVisible: carrito.totalArticulos > 0,
                label: Text('${carrito.totalArticulos}'),
                child: const Icon(Icons.shopping_cart),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<ProductoModel>>(
        future: futuroProductos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48),
                    const SizedBox(height: 12),
                    const Text('No se pudieron cargar los productos.'),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: recargar,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final productos = snapshot.data ?? [];
          if (productos.isEmpty) {
            return const Center(child: Text('No hay productos disponibles.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.68,
            ),
            itemCount: productos.length,
            itemBuilder: (context, index) => _TarjetaProducto(
              producto: productos[index],
              carrito: carrito,
              onAgregar: () => agregarAlCarrito(productos[index]),
            ),
          );
        },
      ),
    );
  }
}

class _TarjetaProducto extends StatelessWidget {
  final ProductoModel producto;
  final Carrito carrito;
  final VoidCallback onAgregar;

  const _TarjetaProducto({
    required this.producto,
    required this.carrito,
    required this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    final agotado = producto.stock <= 0;

    return Card(
      elevation: 0,
      color: AppColores.superficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColores.borde),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Portada(
              url: producto.img,
              texto: producto.nombre,
              semilla: producto.id,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.titulo(size: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  precioTexto(producto.precio),
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColores.acento,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  agotado ? 'Agotado' : 'Disponibles: ${producto.stock}',
                  style: TextStyle(
                    fontSize: 12,
                    color: agotado ? AppColores.error : AppColores.textoSuave,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: carrito,
                  builder: (context, _) {
                    final enCarrito = carrito.cantidadDe(producto.id);
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: agotado ? null : onAgregar,
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: Text(
                          enCarrito > 0 ? 'Agregar ($enCarrito)' : 'Agregar',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
