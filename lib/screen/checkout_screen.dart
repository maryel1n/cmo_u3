// lib/screen/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/cart_provider.dart';
import '../services/products_provider.dart';
import '../services/orders_service.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  // envío
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _comunaCtrl = TextEditingController();

  // pago
  String _method = 'tarjeta'; // 'tarjeta' | 'transferencia'
  final _cardNumberCtrl = TextEditingController();
  final _cardHolderCtrl = TextEditingController();
  final _cardExpCtrl = TextEditingController();
  final _cardCvvCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _comunaCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cardHolderCtrl.dispose();
    _cardExpCtrl.dispose();
    _cardCvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            // Resumen
            _Section(
              title: 'Resumen',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...cart.items.map(
                    (it) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${it.product.productName} x${it.qty}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('\$${it.product.price * it.qty}'),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        '\$${cart.totalPrice}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Envío
            _Section(
              title: 'Datos de envío',
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressCtrl,
                    decoration: const InputDecoration(labelText: 'Dirección'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _comunaCtrl,
                    decoration: const InputDecoration(labelText: 'Comuna'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Método de pago
            _Section(
              title: 'Pago',
              child: Column(
                children: [
                  _PayMethodTile(
                    label: 'Tarjeta de crédito / débito',
                    value: 'tarjeta',
                    groupValue: _method,
                    onChanged: (v) => setState(() => _method = v!),
                  ),
                  if (_method == 'tarjeta') ...[
                    const SizedBox(height: 8),
                    _CardBox(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _cardNumberCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Número de tarjeta',
                              hintText: '4111 1111 1111 1111',
                            ),
                            validator: (v) {
                              if (_method != 'tarjeta') return null;
                              if (v == null || v.trim().length < 12) {
                                return 'Número inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _cardHolderCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Titular',
                            ),
                            validator: (v) {
                              if (_method != 'tarjeta') return null;
                              if (v == null || v.trim().isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _cardExpCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Expiración (MM/AA)',
                                  ),
                                  validator: (v) {
                                    if (_method != 'tarjeta') return null;
                                    if (v == null ||
                                        !RegExp(r'^\d{2}/\d{2}$').hasMatch(v)) {
                                      return 'Formato MM/AA';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _cardCvvCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'CVV',
                                  ),
                                  validator: (v) {
                                    if (_method != 'tarjeta') return null;
                                    if (v == null || v.trim().length < 3) {
                                      return 'CVV inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  _PayMethodTile(
                    label: 'Transferencia',
                    value: 'transferencia',
                    groupValue: _method,
                    onChanged: (v) => setState(() => _method = v!),
                  ),
                  if (_method == 'transferencia')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _CardBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Datos para transferir',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Banco: Banco Demo'),
                            const Text('Cuenta: 12-345-6789'),
                            const Text('Rut: 11.111.111-1'),
                            const Text('Email: pagos@tienda.cl'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),

      // CTA pagar
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: FilledButton(
              onPressed: _submitting
                  ? null
                  : () async {
                      final cart = context.read<CartProvider>();

                      if (cart.totalItems == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tu carrito está vacío'),
                          ),
                        );
                        return;
                      }
                      if (!_formKey.currentState!.validate()) return;

                      setState(() => _submitting = true);
                      try {
                        // Snapshot de items antes de limpiar
                        final snapshot = cart.items
                            .map(
                              (e) => CartItem(product: e.product, qty: e.qty),
                            )
                            .toList();
                        final total = cart.totalPrice;

                        // 1) Descontar stock
                        await context.read<ProductsProvider>().applyCheckout(
                          snapshot,
                        );

                        // 2) Crear orden
                        final items = snapshot
                            .map(
                              (it) => {
                                'productId': it.product.id,
                                'name': it.product.productName,
                                'price': it.product.price,
                                'qty': it.qty,
                                'subtotal': it.product.price * it.qty,
                              },
                            )
                            .toList();

                        final orderId = await OrdersService().createOrder(
                          userId: FirebaseAuth.instance.currentUser?.uid,
                          items: items,
                          total: total,
                          paymentMethod: _method,
                          shipping: {
                            'name': _nameCtrl.text.trim(),
                            'address': _addressCtrl.text.trim(),
                            'comuna': _comunaCtrl.text.trim(),
                          },
                        );

                        // 3) Limpiar carrito
                        cart.clear();

                        if (!mounted) return;

                        // 4) Ir a “Pago confirmado” con el resumen
                        final onlyDigits = _cardNumberCtrl.text.replaceAll(
                          RegExp(r'\D'),
                          '',
                        );
                        final last4 = onlyDigits.length >= 4
                            ? onlyDigits.substring(onlyDigits.length - 4)
                            : null;

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => CheckoutSuccessScreen(
                              items: snapshot,
                              total: total,
                              paymentMethod: _method,
                              orderId: orderId,
                              shippingName: _nameCtrl.text.trim(),
                              shippingAddress: _addressCtrl.text.trim(),
                              cardLast4: _method == 'tarjeta' ? last4 : null,
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      } finally {
                        if (mounted) setState(() => _submitting = false);
                      }
                    },
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Pagar ahora • \$${cart.totalPrice}'),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w800, color: scheme.primary),
        ),
        const SizedBox(height: 10),
        _CardBox(child: child),
      ],
    );
  }
}

class _CardBox extends StatelessWidget {
  final Widget child;
  const _CardBox({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
      ),
      child: child,
    );
  }
}

class _PayMethodTile extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;
  const _PayMethodTile({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(label),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
