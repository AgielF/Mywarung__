class Product {
  final int? id;
  final String tenantId;
  final String name;
  final double price;
  final int stock;
  final String? category;
  final String? barcode;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  const Product({
    this.id,
    required this.tenantId,
    required this.name,
    required this.price,
    required this.stock,
    this.category,
    this.barcode,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  Product copyWith({
    int? id,
    String? tenantId,
    String? name,
    double? price,
    int? stock,
    String? category,
    String? barcode,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Product(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
