import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/producto_model.dart';
import '../services/tienda_service.dart';

/// Pantalla del administrador para dar de alta o editar productos en la tienda.
class AgregarProductoPage extends StatefulWidget {
  final ProductoModel? producto;

  const AgregarProductoPage({super.key, this.producto});

  @override
  State<AgregarProductoPage> createState() => _AgregarProductoPageState();
}

class _AgregarProductoPageState extends State<AgregarProductoPage> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final precioController = TextEditingController();
  final stockController = TextEditingController();
  final imagenController = TextEditingController();

  final TiendaService tiendaService = TiendaService();
  bool guardando = false;

  bool get _esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();
    final prod = widget.producto;
    if (prod != null) {
      nombreController.text = prod.nombre;
      descripcionController.text = prod.descripcion ?? '';
      precioController.text = prod.precio.toStringAsFixed(2);
      stockController.text = '${prod.stock}';
      imagenController.text = prod.img ?? '';
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    precioController.dispose();
    stockController.dispose();
    imagenController.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => guardando = true);

    try {
      final descripcion = descripcionController.text.trim();
      final imagen = imagenController.text.trim();
      final modelo = ProductoModel(
        id: widget.producto?.id ?? 0,
        nombre: nombreController.text.trim(),
        descripcion: descripcion.isEmpty ? null : descripcion,
        precio: double.parse(precioController.text.trim()),
        stock: int.parse(stockController.text.trim()),
        img: imagen.isEmpty ? null : imagen,
      );

      final producto = _esEdicion
          ? await tiendaService.actualizarProducto(modelo)
          : await tiendaService.crearProducto(modelo);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion
                ? 'Producto "${producto.nombre}" actualizado'
                : 'Producto "${producto.nombre}" agregado',
          ),
        ),
      );

      if (_esEdicion) {
        Navigator.pop(context, true);
        return;
      }

      nombreController.clear();
      descripcionController.clear();
      precioController.clear();
      stockController.clear();
      imagenController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo guardar: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar producto' : 'Agregar producto'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _esEdicion ? 'Editar producto' : 'Nuevo producto',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().length < 2
                            ? 'Ingresa el nombre del producto'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: descripcionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Descripción (opcional)',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: precioController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Precio',
                                prefixText: '\$ ',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                final precio = double.tryParse(v ?? '');
                                return precio == null || precio <= 0
                                    ? 'Precio mayor a 0'
                                    : null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: stockController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Stock',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => int.tryParse(v ?? '') == null
                                  ? 'Ingresa el stock'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: imagenController,
                        decoration: const InputDecoration(
                          labelText: 'URL de imagen (opcional)',
                          hintText: 'https://picsum.photos/400/300',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: guardando ? null : guardar,
                        icon: const Icon(Icons.save),
                        label: Text(
                          guardando
                              ? 'Guardando...'
                              : (_esEdicion
                                  ? 'Actualizar producto'
                                  : 'Guardar producto'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
