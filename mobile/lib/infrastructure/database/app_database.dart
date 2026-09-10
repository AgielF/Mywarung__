import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/products.dart';
import 'tables/transactions.dart';
import 'tables/transaction_items.dart';
import 'tables/customers.dart';
import 'tables/debts.dart';
import 'converters/datetime_converter.dart';


part 'app_database.g.dart';

@DriftDatabase(tables: [Products, Transactions, TransactionItems, Customers, Debts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pos_warung.db'));
    return NativeDatabase.createInBackground(file);
  });
}
