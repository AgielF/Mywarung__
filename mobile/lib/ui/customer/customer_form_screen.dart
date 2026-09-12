import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/customer/entities/customer.dart';
import '../../domain/customer/repositories/customer_repository.dart';

class CustomerFormScreen extends StatefulWidget {
  final CustomerRepository customerRepository;
  final Customer? customer;

  const CustomerFormScreen({
    super.key,
    required this.customerRepository,
    this.customer,
  });

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.customer == null) {
        await widget.customerRepository.create(
          name: _nameController.text,
          phone: _phoneController.text.isNotEmpty
              ? _phoneController.text
              : null,
        );
      } else {
        await widget.customerRepository.update(
          widget.customer!.copyWith(
            name: _nameController.text,
            phone: () =>
                _phoneController.text.isNotEmpty ? _phoneController.text : null,
          ),
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final msg = e
          .toString()
          .replaceAll('Bad state: ', '')
          .replaceAll('Exception: ', '');
      _messengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Gagal menyimpan: $msg')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.customer == null ? 'Tambah Customer' : 'Edit Customer',
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Nama minimal 2 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon (Opsional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
                ],
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final regex =
                        RegExp(r'^(?:\+62|62|0)8[1-9][0-9]{7,11}$');
                    if (!regex.hasMatch(value.trim())) {
                      return 'Format nomor telepon tidak valid (contoh: 0812345678)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}