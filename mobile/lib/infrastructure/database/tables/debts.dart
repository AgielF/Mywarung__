import 'package:drift/drift.dart';
import '../converters/datetime_converter.dart';

class Debts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tenantId => text().named('tenant_id')();
  IntColumn get customerId => integer().named('customer_id')();
  RealColumn get amount => real()();
  RealColumn get paid => real().withDefault(const Constant(0))();
  TextColumn get status => text()();
  Column<int> get createdAt => integer().named('created_at').map(const DateTimeConverter())();
  Column<int> get updatedAt => integer().named('updated_at').nullable().map(const DateTimeConverter())();
}
