import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_warung_ai/domain/customer/entities/customer.dart';
import 'package:pos_warung_ai/domain/customer/repositories/customer_repository.dart';
import 'package:pos_warung_ai/ui/customer/customer_form_screen.dart';

class FakeCustomerRepository implements CustomerRepository {
  @override
  Future<int> create({
    required String name,
    String? phone,
    String tenantId = 'tenant-1',
  }) async {
    return 1;
  }

  @override
  Future<void> update(
    Customer customer, {
    String tenantId = 'tenant-1',
  }) async {}

  @override
  Future<void> delete(int id, {String tenantId = 'tenant-1'}) async {}

  @override
  Future<List<Customer>> getAll({String tenantId = 'tenant-1'}) async {
    return [];
  }

  @override
  Future<Customer?> getById(int id, {String tenantId = 'tenant-1'}) async {
    return null;
  }

  @override
  Stream<List<Customer>> watchAll({String tenantId = 'tenant-1'}) async* {}
}

void main() {
  testWidgets('CustomerFormScreen validasi phone format (invalid & valid)', (
    tester,
  ) async {
    final repo = FakeCustomerRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CustomerFormScreen(customerRepository: repo)),
      ),
    );

    // Input nama valid
    await tester.enterText(find.byType(TextFormField).first, 'Budi Baik');

    // Input phone invalid (huruf)
    await tester.enterText(find.byType(TextFormField).last, 'abcde123');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // Harus error
    expect(find.textContaining('Format nomor telepon tidak valid'), findsOneWidget);

    // Input phone invalid (terlalu pendek)
    await tester.enterText(find.byType(TextFormField).last, '1234');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // Harus error
    expect(find.textContaining('Format nomor telepon tidak valid'), findsOneWidget);

    // Input phone valid
    await tester.enterText(find.byType(TextFormField).last, '08123456789');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // Tidak ada error, dialog pop
    expect(find.textContaining('Format nomor telepon tidak valid'), findsNothing);
  });
}
