import '../../domain/inventory/entities/product.dart';

class InventoryState {
  final List<Product> products;
  final bool isLoading;
  final String? errorMessage;

  const InventoryState({
    this.products = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  InventoryState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? errorMessage,
  }) {
    return InventoryState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
