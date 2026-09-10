import 'package:flutter/material.dart';
import '../../domain/inventory/entities/product.dart';
import '../../domain/inventory/repositories/product_repository.dart';

class InventoryFormScreen extends StatefulWidget {
  final ProductRepository repository;
  final Product? product;

  const InventoryFormScreen({super.key, required this.repository, this.product});

  @override
  State<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late String _name;
  late double _price;
  late int _stock;
  String? _category;
  String? _barcode;
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _name = widget.product?.name ?? '';
    _price = widget.product?.price ?? 0.0;
    _stock = widget.product?.stock ?? 0;
    _category = widget.product?.category;
    _barcode = widget.product?.barcode;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    
    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.product == null) {
        final newProduct = Product(
          tenantId: 'tenant-1', // Default tenant for now
          name: _name,
          price: _price,
          stock: _stock,
          category: _category,
          barcode: _barcode,
          createdAt: DateTime.now(), // Will be overwritten by repo
        );
        await widget.repository.create(newProduct);
      } else {
        final updatedProduct = widget.product!.copyWith(
          name: _name,
          price: _price,
          stock: _stock,
          category: _category,
          barcode: _barcode,
        );
        await widget.repository.update(updatedProduct);
      }
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Produk' : 'Tambah Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _price == 0.0 ? '' : _price.toStringAsFixed(0),
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  final numValue = double.tryParse(value);
                  if (numValue == null || numValue < 0) {
                    return 'Harga harus berupa angka valid >= 0';
                  }
                  return null;
                },
                onSaved: (value) => _price = double.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _stock == 0 ? '' : _stock.toString(),
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Stok tidak boleh kosong';
                  }
                  final numValue = int.tryParse(value);
                  if (numValue == null || numValue < 0) {
                    return 'Stok harus berupa angka bulat >= 0';
                  }
                  return null;
                },
                onSaved: (value) => _stock = int.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Kategori (Opsional)'),
                onSaved: (value) => _category = value?.trim().isEmpty == true ? null : value?.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _barcode,
                decoration: const InputDecoration(labelText: 'Barcode (Opsional)'),
                onSaved: (value) => _barcode = value?.trim().isEmpty == true ? null : value?.trim(),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
