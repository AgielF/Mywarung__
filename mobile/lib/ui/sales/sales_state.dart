import '../../domain/inventory/entities/product.dart';
import '../../domain/sales/entities/transaction_item.dart';

class SalesState {
  final List<Product> products;
  final List<TransactionItem> cart;
  final bool isLoading;
  final String? errorMessage;

  const SalesState({
    this.products = const [],
    this.cart = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  double get totalAmount {
    return cart.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  int get totalItems {
    return cart.fold(0, (sum, item) => sum + item.quantity);
  }

  SalesState addToCart(Product product) {
    final existingIndex = cart.indexWhere((item) => item.productId == product.id);
    if (existingIndex >= 0) {
      final existingItem = cart[existingIndex];
      if (existingItem.quantity >= product.stock) {
        return copyWith(errorMessage: 'Stok tidak cukup untuk ${product.name}');
      }
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
        subtotal: (existingItem.quantity + 1) * existingItem.price,
      );
      final newCart = List<TransactionItem>.from(cart)..[existingIndex] = updatedItem;
      return copyWith(cart: newCart, clearError: true);
    } else {
      if (product.stock < 1) {
        return copyWith(errorMessage: 'Stok habis untuk ${product.name}');
      }
      final newItem = TransactionItem(
        productId: product.id!,
        productName: product.name,
        quantity: 1,
        price: product.price,
        subtotal: product.price,
      );
      return copyWith(cart: [...cart, newItem], clearError: true);
    }
  }

  SalesState removeFromCart(int productId) {
    final newCart = cart.where((item) => item.productId != productId).toList();
    return copyWith(cart: newCart, clearError: true);
  }

  SalesState updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      return removeFromCart(productId);
    }
    
    final product = products.firstWhere((p) => p.id == productId);
    if (quantity > product.stock) {
      return copyWith(errorMessage: 'Stok tidak cukup untuk ${product.name}');
    }

    final existingIndex = cart.indexWhere((item) => item.productId == productId);
    if (existingIndex >= 0) {
      final existingItem = cart[existingIndex];
      final updatedItem = existingItem.copyWith(
        quantity: quantity,
        subtotal: quantity * existingItem.price,
      );
      final newCart = List<TransactionItem>.from(cart)..[existingIndex] = updatedItem;
      return copyWith(cart: newCart, clearError: true);
    }
    return this;
  }

  SalesState clearCart() {
    return copyWith(cart: const [], clearError: true);
  }

  SalesState copyWith({
    List<Product>? products,
    List<TransactionItem>? cart,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SalesState(
      products: products ?? this.products,
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
