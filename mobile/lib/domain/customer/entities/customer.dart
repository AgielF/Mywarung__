class Customer {
  final int? id;
  final String tenantId;
  final String name;
  final String? phone;
  final DateTime createdAt;

  const Customer({
    this.id,
    required this.tenantId,
    required this.name,
    this.phone,
    required this.createdAt,
  });

  Customer copyWith({
    int? id,
    String? tenantId,
    String? name,
    String? phone,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer &&
        other.id == id &&
        other.tenantId == tenantId &&
        other.name == name &&
        other.phone == phone &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tenantId.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'Customer(id: $id, tenantId: $tenantId, name: $name, phone: $phone, createdAt: $createdAt)';
  }
}
