import 'package:drift/drift.dart';
import '../converters/datetime_converter.dart';

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tenantId => text().named('tenant_id')();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  Column<int> get createdAt => integer().named('created_at').map(const DateTimeConverter())();
}
