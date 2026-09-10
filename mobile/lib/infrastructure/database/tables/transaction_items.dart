import 'package:drift/drift.dart';

class TransactionItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId => integer().named('transaction_id')();
  IntColumn get productId => integer().named('product_id')();
  IntColumn get quantity => integer()();
  RealColumn get price => real()();
  RealColumn get subtotal => real()();
}
