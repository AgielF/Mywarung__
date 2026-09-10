class TransactionItem {
  final int? id;
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;

  const TransactionItem({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  TransactionItem copyWith({
    int? id,
    int? productId,
    String? productName,
    int? quantity,
    double? price,
    double? subtotal,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionItem &&
        other.id == id &&
        other.productId == productId &&
        other.quantity == quantity &&
        other.price == price &&
        other.subtotal == subtotal;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        productId.hashCode ^
        quantity.hashCode ^
        price.hashCode ^
        subtotal.hashCode;
  }
}
