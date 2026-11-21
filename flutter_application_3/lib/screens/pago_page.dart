import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/producto_model.dart';
import '../services/carrito.dart';
import '../services/sesion.dart';
import '../services/tienda_service.dart';
import '../theme/app_theme.dart';

/// Pantalla de pago SIMULADO: no se hace ningún cobro real.
class PagoPage extends StatefulWidget {
  const PagoPage({super.key});

  @override
  State<PagoPage> createState() => _PagoPageState();
}

class _PagoPageState extends State<PagoPage> {
  final _formKey = GlobalKey<FormState>();
  final titularController = TextEditingController();
  final numeroController = TextEditingController();
  final vencimientoController = TextEditingController();
  final cvvController = TextEditingController();

  final TiendaService tiendaService = TiendaService();
  final Carrito carrito = Carrito.instancia;
  bool pagando = false;

  @override
  void dispose() {
    titularController.dispose();
    numeroController.dispose();
    vencimientoController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  Future<void> pagar() async {
    if (!_formKey.currentState!.validate()) return;

    if (!Sesion.tieneToken) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vuelve a iniciar sesión para comprar')),
      );
      return;
    }

    setState(() => pagando = true);

    try {
      final pedido = await tiendaService.pagar(
        items: carrito.items,
        titular: titularController.text,
        numeroTarjeta: numeroController.text,
        vencimiento: vencimientoController.text,
        cvv: cvvController.text,
      );

      carrito.vaciar();
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: AppColores.exito, size: 56),
          title: const Text('¡Pago aprobado!'),
          content: Text(
            'Pedido #${pedido.id}\n'
            'Total: ${precioTexto(pedido.total)}\n'
            'Tarjeta terminación ${pedido.ultimos4}',
            textAlign: TextAlign.center,
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
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
    } finally {
      if (mounted) setState(() => pagando = false);
    }
  }

  InputDecoration _decoracion(String etiqueta, IconData icono, {String? ayuda}) {
    return InputDecoration(
      labelText: etiqueta,
      hintText: ayuda,
      prefixIcon: Icon(icono),
      border: const OutlineInputBorder(),
      counterText: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pago seguro', style: AppTheme.titulo(size: 20)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
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
                        'Total a pagar: ${precioTexto(carrito.total)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColores.secundario.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColores.secundario.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Text(
                          'Pago simulado: no se realiza ningún cobro.\n'
                          'Aprobada: 4242 4242 4242 4242\n'
                          'Rechazada: 4000 0000 0000 0002',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: AppColores.secundario,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titularController,
                        textCapitalization: TextCapitalization.words,
                        decoration:
                            _decoracion('Nombre del titular', Icons.person),
                        validator: (v) => v == null || v.trim().length < 3
                            ? 'Ingresa el nombre como aparece en la tarjeta'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: numeroController,
                        keyboardType: TextInputType.number,
                        maxLength: 19,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                        ],
                        decoration: _decoracion(
                          'Número de tarjeta',
                          Icons.credit_card,
                          ayuda: '4242 4242 4242 4242',
                        ),
                        validator: (v) {
                          final digitos = (v ?? '').replaceAll(' ', '');
                          return digitos.length < 13
                              ? 'Número de tarjeta incompleto'
                              : null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: vencimientoController,
                              keyboardType: TextInputType.datetime,
                              maxLength: 5,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9/]')),
                              ],
                              decoration: _decoracion(
                                'Vencimiento',
                                Icons.date_range,
                                ayuda: 'MM/AA',
                              ),
                              validator: (v) =>
                                  RegExp(r'^\d{2}/\d{2}$').hasMatch(v ?? '')
                                      ? null
                                      : 'Formato MM/AA',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: cvvController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              maxLength: 4,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: _decoracion('CVV', Icons.lock),
                              validator: (v) => (v ?? '').length < 3
                                  ? '3 o 4 dígitos'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: pagando || carrito.estaVacio ? null : pagar,
                        icon: pagando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.lock),
                        label: Text(
                          pagando
                              ? 'Procesando pago...'
                              : 'Pagar ${precioTexto(carrito.total)}',
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
