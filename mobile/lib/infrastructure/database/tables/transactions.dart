import 'package:drift/drift.dart';
import '../converters/datetime_converter.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tenantId => text().named('tenant_id')();
  RealColumn get total => real()();
  TextColumn get paymentMethod => text().named('payment_method')();
  IntColumn get customerId => integer().named('customer_id').nullable()();
  Column<int> get createdAt => integer().named('created_at').map(const DateTimeConverter())();
  BoolColumn get isSynced => boolean().named('is_synced').withDefault(const Constant(false))();
}
