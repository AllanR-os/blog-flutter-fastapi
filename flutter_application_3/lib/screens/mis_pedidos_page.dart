import 'package:flutter/material.dart';

import '../models/pedido_model.dart';
import '../models/producto_model.dart';
import '../services/sesion.dart';
import '../services/tienda_service.dart';
import '../theme/app_theme.dart';

class MisPedidosPage extends StatefulWidget {
  final bool todos;

  const MisPedidosPage({super.key, this.todos = false});

  @override
  State<MisPedidosPage> createState() => _MisPedidosPageState();
}

class _MisPedidosPageState extends State<MisPedidosPage> {
  final TiendaService tiendaService = TiendaService();
  late Future<List<PedidoModel>> futuroPedidos;

  @override
  void initState() {
    super.initState();
    futuroPedidos = _cargar();
  }

  Future<List<PedidoModel>> _cargar() {
    if (widget.todos) {
      return tiendaService.obtenerTodosLosPedidos();
    }
    final id = Sesion.idUsuario;
    if (id == null) {
      return Future.error('Vuelve a iniciar sesión para ver tus pedidos');
    }
    return tiendaService.obtenerMisPedidos(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.todos ? 'Pedidos de clientes' : 'Mis pedidos',
          style: AppTheme.titulo(size: 20),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => futuroPedidos = _cargar()),
          ),
        ],
      ),
      body: FutureBuilder<List<PedidoModel>>(
        future: futuroPedidos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${snapshot.error}'.replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final pedidos = snapshot.data ?? [];
          if (pedidos.isEmpty) {
            return Center(
              child: Text(
                widget.todos
                    ? 'Aún no hay pedidos registrados.'
                    : 'Aún no tienes pedidos.',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              final lineaCliente = widget.todos && pedido.cliente != null
                  ? '${pedido.cliente} (${pedido.correo ?? ''})\n'
                  : '';
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColores.superficieAlta,
                    child: Icon(Icons.receipt_long, color: AppColores.acento),
                  ),
                  title: Text('Pedido #${pedido.id}  ·  ${precioTexto(pedido.total)}'),
                  subtitle: Text(
                    '$lineaCliente${pedido.fechaLegible}  ·  ${pedido.estatus}  ·  '
                    'Tarjeta •••• ${pedido.ultimos4}',
                  ),
                  children: pedido.detalles
                      .map(
                        (d) => ListTile(
                          dense: true,
                          title: Text(d.nombre),
                          subtitle: Text(
                            '${d.cantidad} x ${precioTexto(d.precioUnitario)}',
                          ),
                          trailing: Text(precioTexto(d.subtotal)),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
