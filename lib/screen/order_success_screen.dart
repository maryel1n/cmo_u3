import 'package:flutter/material.dart';
import 'package:cmo_u3/services/cart_provider.dart' show CartItem;

/// Pantalla de confirmación de compra.
/// Recibe el resumen para mostrarlo (no hace llamadas extra).
class CheckoutSuccessScreen extends StatelessWidget {
  final List<CartItem> items;
  final int total;
  final String paymentMethod; // 'tarjeta', 'transferencia', 'efectivo', etc.
  final String? cardLast4; // Ej: '1234' si fue tarjeta
  final String? orderId; // Opcional: id de la orden si lo tienes
  final String? shippingName;
  final String? shippingAddress;

  const CheckoutSuccessScreen({
    super.key,
    required this.items,
    required this.total,
    required this.paymentMethod,
    this.cardLast4,
    this.orderId,
    this.shippingName,
    this.shippingAddress,
  });

  String _clp(int v) {
    // Formato simple CLP: $12.345
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final left = s.length - i - 1;
      buf.write(s[i]);
      if (left > 0 && left % 3 == 0) buf.write('.');
    }
    return '\$${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago confirmado'),
        automaticallyImplyLeading: false, // no volver atrás a checkout
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado éxito
              Column(
                children: [
                  const SizedBox(height: 8),
                  Icon(
                    Icons.check_circle_outline,
                    size: 72,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¡Pago exitoso!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tu orden ha sido procesada correctamente.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  if (orderId != null && orderId!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'N° de orden: $orderId',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),

              // Resumen de compra
              const SizedBox(height: 8),
              const Text(
                'Resumen de compra',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              // Lista de items
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final it = items[i];
                  final p = it.product;
                  final subtotal = p.price * it.qty;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: scheme.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Placeholder de mini imagen
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: scheme.surfaceVariant.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.local_mall_outlined),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.productName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${it.qty} × ${_clp(p.price)}',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _clp(subtotal),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Método de pago
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.credit_card, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        cardLast4 != null && cardLast4!.isNotEmpty
                            ? 'Pago con ${paymentMethod.toUpperCase()} • **** $cardLast4'
                            : 'Método: ${paymentMethod.toUpperCase()}',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Dirección
              if ((shippingName?.isNotEmpty ?? false) ||
                  (shippingAddress?.isNotEmpty ?? false))
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: scheme.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.local_shipping_outlined, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (shippingName?.isNotEmpty ?? false)
                              Text(
                                shippingName!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            if (shippingAddress?.isNotEmpty ?? false) ...[
                              const SizedBox(height: 2),
                              Text(
                                shippingAddress!,
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
              // Total
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total pagado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    _clp(total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Botón volver
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: () {
                    // Vuelve al catálogo (pantalla raíz)
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  icon: const Icon(Icons.home_outlined),
                  label: const Text(
                    'Volver al catálogo',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
