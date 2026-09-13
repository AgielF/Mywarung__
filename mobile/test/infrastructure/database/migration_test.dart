import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_warung_ai/infrastructure/database/app_database.dart';

void main() {
  test('migrasi v1 ke v2 menambah kolom due_date dan preserve data', () async {
    // Step 1: buat executor in-memory dengan schema v1 manual
    final executor = NativeDatabase.memory(
      setup: (db) async {
        await db.execute('''
          CREATE TABLE debts (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            customer_id INTEGER NOT NULL,
            amount REAL NOT NULL,
            paid REAL NOT NULL DEFAULT 0,
            status TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE customers (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            name TEXT NOT NULL,
            phone TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE products (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            stock INTEGER NOT NULL,
            category TEXT,
            barcode TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER,
            is_deleted INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            tenant_id TEXT NOT NULL,
            total REAL NOT NULL,
            payment_method TEXT NOT NULL,
            customer_id INTEGER,
            created_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE transaction_items (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            transaction_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL,
            subtotal REAL NOT NULL
          )
        ''');
        await db.execute('PRAGMA user_version = 1');
        await db.execute(
          'INSERT INTO debts (tenant_id, customer_id, amount, paid, status, created_at) '
          'VALUES (?, ?, ?, ?, ?, ?)',
          [
            'tenant-1',
            1,
            50000.0,
            0.0,
            'unpaid',
            DateTime.now().millisecondsSinceEpoch,
          ],
        );
      },
    );

    // Step 2: buka dengan AppDatabase v2 — migration onUpgrade akan jalan
    final db = AppDatabase.forTesting(executor);

    // Step 3: verifikasi data preserved + kolom due_date ada
    final debts = await db.select(db.debts).get();
    expect(debts.length, 1);
    expect(debts.first.amount, 50000.0);
    expect(debts.first.dueDate, isNull);

    await db.close();
  });
}
