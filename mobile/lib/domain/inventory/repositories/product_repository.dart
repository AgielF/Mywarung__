import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getAll();
  Future<Product?> getById(int id);
  Future<int> create(Product product);
  Future<bool> update(Product product);
  Future<bool> delete(int id);
  Stream<List<Product>> watchAll();
}
