import 'dart:async';

import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../services/carrito.dart';
import '../services/sesion.dart';
import '../services/tienda_service.dart';
import '../theme/app_theme.dart';
import '../widgets/portada.dart';
import 'agregar_producto_page.dart';

class TiendaPage extends StatefulWidget {
  const TiendaPage({super.key});

  @override
  State<TiendaPage> createState() => _TiendaPageState();
}

class _TiendaPageState extends State<TiendaPage> {
  final TiendaService tiendaService = TiendaService();
  final Carrito carrito = Carrito.instancia;
  final TextEditingController _busquedaController = TextEditingController();
  Timer? _debounce;
  bool _soloDisponibles = false;
  late Future<List<ProductoModel>> futuroProductos;

  @override
  void initState() {
    super.initState();
    futuroProductos = _consultarProductos();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _busquedaController.dispose();
    super.dispose();
  }

  Future<List<ProductoModel>> _consultarProductos() {
    return tiendaService.obtenerProductos(
      busqueda: _busquedaController.text,
      soloDisponibles: _soloDisponibles,
    );
  }

  void recargar() {
    setState(() {
      futuroProductos = _consultarProductos();
    });
  }

  void _alCambiarBusqueda(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), recargar);
    setState(() {});
  }

  Future<void> _abrirNuevoProducto() async {
    await Navigator.pushNamed(context, '/add-producto');
    if (mounted) recargar();
  }

  Future<void> _editarProducto(ProductoModel producto) async {
    final actualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AgregarProductoPage(producto: producto),
      ),
    );
    if (actualizado == true && mounted) recargar();
  }

  Future<void> _eliminarProducto(ProductoModel producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Deseas eliminar "${producto.nombre}" del catálogo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    try {
      await tiendaService.eliminarProducto(producto.id);
      carrito.eliminar(producto.id);
      if (!mounted) return;
      recargar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto "${producto.nombre}" eliminado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColores.error,
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: const TextStyle(color: AppColores.fondo),
          ),
        ),
      );
    }
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
      floatingActionButton: Sesion.esAdmin
          ? FloatingActionButton.extended(
              onPressed: _abrirNuevoProducto,
              icon: const Icon(Icons.add_business),
              label: const Text('Nuevo producto'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _busquedaController,
                    onChanged: _alCambiarBusqueda,
                    onSubmitted: (_) => recargar(),
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _busquedaController.text.isNotEmpty
                          ? IconButton(
                              tooltip: 'Limpiar búsqueda',
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _busquedaController.clear();
                                recargar();
                              },
                            )
                          : null,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilterChip(
                  label: const Text('Solo disponibles'),
                  selected: _soloDisponibles,
                  onSelected: (valor) {
                    _soloDisponibles = valor;
                    recargar();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ProductoModel>>(
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
                  return const Center(
                    child: Text('No se encontraron productos con ese filtro.'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: Sesion.esAdmin ? 0.62 : 0.68,
                  ),
                  itemCount: productos.length,
                  itemBuilder: (context, index) => _TarjetaProducto(
                    producto: productos[index],
                    carrito: carrito,
                    esAdmin: Sesion.esAdmin,
                    onAgregar: () => agregarAlCarrito(productos[index]),
                    onEditar: () => _editarProducto(productos[index]),
                    onEliminar: () => _eliminarProducto(productos[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaProducto extends StatelessWidget {
  final ProductoModel producto;
  final Carrito carrito;
  final bool esAdmin;
  final VoidCallback onAgregar;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _TarjetaProducto({
    required this.producto,
    required this.carrito,
    required this.esAdmin,
    required this.onAgregar,
    required this.onEditar,
    required this.onEliminar,
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
                if (esAdmin)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onEditar,
                            icon: const Icon(Icons.edit_outlined, size: 15),
                            label: const Text('Editar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'Eliminar ${producto.nombre}',
                          onPressed: onEliminar,
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColores.error,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
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
