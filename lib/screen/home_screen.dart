// lib/screen/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product.dart';
import '../services/env.dart';
import '../services/products_provider.dart';
import '../services/products_service.dart';
import '../services/cart_provider.dart';

import 'cart_screen.dart';
import 'product_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Productos y carrito
    final p = context.watch<ProductsProvider>();
    final cart = context.watch<CartProvider>();
    final items = p.items;

    // Admin según env
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final isAdmin = Env.adminEmails.contains(email);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => context.read<ProductsProvider>().refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Salir',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          // Carrito con badge
          Padding(
            padding: const EdgeInsets.only(right: 8),
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
        ],
      ),

      // Grid de productos
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : p.error != null
          ? Center(
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
                      onPressed: () =>
                          context.read<ProductsProvider>().refresh(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : CustomScrollView(
              slivers: [
                if (items.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('No hay productos')),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 80),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) =>
                            _ProductCard(item: items[i], isAdmin: isAdmin),
                        childCount: items.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.74,
                          ),
                    ),
                  ),
              ],
            ),

      // Botón inferior para revisar carrito
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: cart.totalItems > 0
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    }
                  : null,
              icon: const Icon(Icons.shopping_cart_outlined),
              label: Text(
                cart.totalItems > 0
                    ? 'Revisar carrito • ${cart.totalItems} ítems • \$${cart.totalPrice}'
                    : 'Carrito vacío',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),

      // FAB solo para admin → Crear producto
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProductFormScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ---------- CARD DE PRODUCTO + MENÚ ADMIN (Editar / Eliminar) ----------
class _ProductCard extends StatelessWidget {
  final Product item;
  final bool isAdmin;
  const _ProductCard({required this.item, required this.isAdmin});

  Future<void> _showAdminMenu(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductFormScreen(initial: item),
                  ),
                );
              },
            ),
            // ⬇️ Eliminación (la modificación que pediste)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Eliminar'),
              textColor: Colors.redAccent,
              iconColor: Colors.redAccent,
              onTap: () async {
                Navigator.of(context).pop();
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Eliminar producto'),
                    content: Text('¿Eliminar "${item.productName}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  try {
                    await ProductsService().delete(item.id!);
                    if (context.mounted) {
                      await context.read<ProductsProvider>().refresh();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Producto eliminado')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al eliminar: $e')),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1.5,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () {},
        onLongPress: isAdmin ? () => _showAdminMenu(context) : null,
        child: Stack(
          children: [
            // Cuerpo
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // “Imagen”
                Expanded(
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
                // Nombre + precio
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
                      Text(
                        '\$${item.price}',
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (item.stock != null)
                        Text(
                          'Stock: ${item.stock}',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Acciones arriba a la derecha
            Positioned(
              right: 10,
              top: 10,
              child: Row(
                children: [
                  _CircleIcon(
                    icon: Icons.add_shopping_cart_outlined,
                    onTap: () {
                      context.read<CartProvider>().add(item, qty: 1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Agregado: ${item.productName}'),
                          duration: const Duration(milliseconds: 900),
                        ),
                      );
                    },
                  ),
                  if (isAdmin) const SizedBox(width: 8),
                  if (isAdmin)
                    _CircleIcon(
                      icon: Icons.more_horiz,
                      onTap: () => _showAdminMenu(context),
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
