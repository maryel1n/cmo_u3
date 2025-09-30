import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/products_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProductsProvider>();

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
              Text(p.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.read<ProductsProvider>().fetch(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    } else if (p.items.isEmpty) {
      body = const Center(child: Text('No hay productos'));
    } else {
      body = RefreshIndicator(
        onRefresh: () => context.read<ProductsProvider>().refresh(),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: p.items.length,
          separatorBuilder: (_, __) => const Divider(height: 0),
          itemBuilder: (_, i) {
            final it = p.items[i];
            return ListTile(
              title: Text(it.productName),
              subtitle: Text('${it.category} • Stock: ${it.stock}'),
              trailing: Text('\$${it.price}'),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: body,
    );
  }
}
