enum DebtStatus {
  unpaid,
  paid;

  String toDbString() => name;

  static DebtStatus fromString(String status) {
    return DebtStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => DebtStatus.unpaid,
    );
  }
}

class Debt {
  final int? id;
  final String tenantId;
  final int customerId;
  final double amount;
  final double paid;
  final DebtStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Debt({
    this.id,
    required this.tenantId,
    required this.customerId,
    required this.amount,
    required this.paid,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  double get remainingAmount => amount - paid;
  bool get isPaid => status == DebtStatus.paid;

  Debt copyWith({
    int? id,
    String? tenantId,
    int? customerId,
    double? amount,
    double? paid,
    DebtStatus? status,
    DateTime? createdAt,
    DateTime? Function()? updatedAt,
  }) {
    return Debt(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      paid: paid ?? this.paid,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Debt &&
        other.id == id &&
        other.tenantId == tenantId &&
        other.customerId == customerId &&
        other.amount == amount &&
        other.paid == paid &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tenantId.hashCode ^
        customerId.hashCode ^
        amount.hashCode ^
        paid.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'Debt(id: $id, tenantId: $tenantId, customerId: $customerId, amount: $amount, paid: $paid, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
