import 'package:drift/drift.dart';
import '../converters/datetime_converter.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tenantId => text().named('tenant_id')();
  TextColumn get name => text()();
  RealColumn get price => real()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  TextColumn get category => text().nullable()();
  TextColumn get barcode => text().nullable()();
  
  Column<int> get createdAt => integer().named('created_at').map(const DateTimeConverter())();
  Column<int> get updatedAt => integer().named('updated_at').nullable().map(const DateTimeConverter())();
  BoolColumn get isDeleted => boolean().named('is_deleted').withDefault(const Constant(false))();
}
