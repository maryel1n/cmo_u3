// lib/screen/product_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../services/products_provider.dart';
import '../services/products_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? initial; // si viene, estamos editando

  const ProductFormScreen({super.key, this.initial});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _categoryCtrl = TextEditingController(text: 'general');

  String _estado = 'Activo';
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    if (p != null) {
      _nameCtrl.text = p.productName;
      _priceCtrl.text = '${p.price}';
      _stockCtrl.text = '${p.stock}';
      _categoryCtrl.text = p.category ?? 'general';
      _estado = p.estado ?? 'Activo';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final price = int.tryParse(_priceCtrl.text.trim()) ?? -1;
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? -1;

    if (price < 0 || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Precio y stock deben ser números válidos'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final svc = ProductsService();

      if (_isEditing) {
        // UPDATE
        await svc.update(widget.initial!.id!, {
          'productName': _nameCtrl.text.trim(),
          'price': price,
          'stock': stock,
          'category': _categoryCtrl.text.trim().isEmpty
              ? 'general'
              : _categoryCtrl.text.trim(),
          'estado': _estado,
        });
      } else {
        // CREATE
        await svc.create(
          productName: _nameCtrl.text.trim(),
          price: price,
          stock: stock,
          category: _categoryCtrl.text.trim().isEmpty
              ? 'general'
              : _categoryCtrl.text.trim(),
          estado: _estado,
        );
      }

      if (!mounted) return;
      await context.read<ProductsProvider>().refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Producto actualizado' : 'Producto creado',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    InputDecoration deco(String label, [String? hint]) => InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: scheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary.withOpacity(0.45)),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: deco('Nombre del producto', 'Ej: Polera Básica'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: deco('Precio (CLP)', 'Ej: 9990'),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null || n < 0) return 'Precio inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: deco('Stock', 'Ej: 10'),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null || n < 0) return 'Stock inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryCtrl,
                  decoration: deco('Categoría', 'Ej: ropa, calzado, ...'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _estado,
                  decoration: deco('Estado'),
                  items: const [
                    DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                    DropdownMenuItem(
                      value: 'Inactivo',
                      child: Text('Inactivo'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _estado = v ?? 'Activo'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Guardar cambios' : 'Guardar producto'),
            ),
          ),
        ),
      ),
    );
  }
}
