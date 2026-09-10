import 'package:drift/drift.dart';
import '../../domain/inventory/entities/product.dart';
import '../../domain/inventory/repositories/product_repository.dart';
import '../database/app_database.dart' as drift;

class DriftProductRepository implements ProductRepository {
  final drift.AppDatabase _db;

  DriftProductRepository(this._db);

  @override
  Future<List<Product>> getAll() async {
    final query = _db.select(_db.products)..where((tbl) => tbl.isDeleted.equals(false));
    final result = await query.get();
    return result.map((row) => row.toDomain()).toList();
  }

  @override
  Future<Product?> getById(int id) async {
    final query = _db.select(_db.products)..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false));
    final result = await query.getSingleOrNull();
    return result?.toDomain();
  }

  @override
  Future<int> create(Product product) async {
    final companion = product.toCompanion().copyWith(
      createdAt: Value(DateTime.now()),
    );
    return await _db.into(_db.products).insert(companion);
  }

  @override
  Future<bool> update(Product product) async {
    assert(product.id != null, 'Product id cannot be null when updating');
    final companion = product.toCompanion().copyWith(
      updatedAt: Value(DateTime.now()),
    );
    return await _db.update(_db.products).replace(companion);
  }

  @override
  Future<bool> delete(int id) async {
    final companion = drift.ProductsCompanion(
      id: Value(id),
      isDeleted: const Value(true),
      updatedAt: Value(DateTime.now()),
    );
    final count = await (_db.update(_db.products)..where((tbl) => tbl.id.equals(id))).write(companion);
    return count > 0;
  }

  @override
  Stream<List<Product>> watchAll() {
    final query = _db.select(_db.products)..where((tbl) => tbl.isDeleted.equals(false));
    return query.watch().map((rows) => rows.map((row) => row.toDomain()).toList());
  }
}

extension ProductDataMapper on drift.Product {
  Product toDomain() {
    return Product(
      id: id,
      tenantId: tenantId,
      name: name,
      price: price,
      stock: stock,
      category: category,
      barcode: barcode,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }
}

extension ProductDomainMapper on Product {
  drift.ProductsCompanion toCompanion() {
    return drift.ProductsCompanion(
      id: id != null ? Value(id!) : const Value.absent(),
      tenantId: Value(tenantId),
      name: Value(name),
      price: Value(price),
      stock: Value(stock),
      category: Value(category),
      barcode: Value(barcode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }
}
