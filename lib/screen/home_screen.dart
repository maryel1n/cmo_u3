import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/products_provider.dart';
import '../services/cart_provider.dart';
import '../models/product.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  List<Product> _filtered(List<Product> items) {
    if (_query.trim().isEmpty) return items;
    final q = _query.toLowerCase();
    return items.where((p) => p.productName.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProductsProvider>();
    final cart = context.watch<CartProvider>();
    final scheme = Theme.of(context).colorScheme;

    Widget body;
    if (p.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (p.error != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                p.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.read<ProductsProvider>().fetch(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    } else {
      final items = _filtered(p.items);

      body = RefreshIndicator(
        onRefresh: () => context.read<ProductsProvider>().refresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: _SearchField(
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ),
            if (items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No hay productos')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _ProductCard(item: items[i]),
                    childCount: items.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.74,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => context.read<ProductsProvider>().refresh(),
          ),

          // Ícono de carrito con badge (se mantiene tal cual)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  tooltip: 'Carrito',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                ),
                if (cart.totalItems > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${cart.totalItems}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ⬇️ Nuevo: Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              // 1) cerrar sesión
              await FirebaseAuth.instance.signOut();
              // 2) limpiar carrito (no rompe nada y evita “basura” de la sesión anterior)
              if (!context.mounted) return;
              context.read<CartProvider>().clear();
              // AuthGate redirige solo al Login automáticamente.
            },
          ),
        ],
      ),
      body: body,

      // ⬇️ Botón inferior para revisar carrito (actualizado para navegar)
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, _) {
          final hasItems = cart.totalItems > 0;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: hasItems
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CartScreen(),
                            ),
                          );
                        }
                      : null, // deshabilitado si está vacío
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: Text(
                    hasItems
                        ? 'Revisar carrito • ${cart.totalItems} ítems • \$${cart.totalPrice}'
                        : 'Carrito vacío',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar productos',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: scheme.surface.withOpacity(0.6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: scheme.primary.withOpacity(0.45)),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product item;
  const _ProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final outOfStock = (item.stock <= 0);

    return Card(
      elevation: 1.5,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Vista: ${item.productName}')));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen y botones superpuestos
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            scheme.surfaceVariant.withOpacity(0.45),
                            scheme.surfaceVariant.withOpacity(0.2),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.image_outlined, size: 44),
                      ),
                    ),
                  ),
                  if (outOfStock)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Agotado',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: _CircleIcon(
                      icon: Icons.add_shopping_cart_outlined,
                      onTap: () {
                        if (outOfStock) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Producto sin stock')),
                          );
                          return;
                        }
                        // agrega 1 unidad del producto al carrito
                        context.read<CartProvider>().add(item, qty: 1);

                        // feedback breve
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Agregado: ${item.productName}'),
                            duration: const Duration(milliseconds: 900),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Nombre, precio y stock
            Padding(
              padding: const EdgeInsets.only(
                left: 14,
                right: 14,
                top: 10,
                bottom: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${item.price}',
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '· Stock: ${item.stock}',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: scheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: scheme.onSurfaceVariant),
      ),
    );
  }
}
