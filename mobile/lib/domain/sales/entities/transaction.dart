import 'transaction_item.dart';

enum PaymentMethod { cash, qris, debt }

class Transaction {
  final int? id;
  final String tenantId;
  final List<TransactionItem> items;
  final double total;
  final PaymentMethod paymentMethod;
  final int? customerId;
  final DateTime createdAt;
  final bool isSynced;

  const Transaction({
    this.id,
    required this.tenantId,
    required this.items,
    required this.total,
    required this.paymentMethod,
    this.customerId,
    required this.createdAt,
    this.isSynced = false,
  });

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return total;
  }

  Transaction copyWith({
    int? id,
    String? tenantId,
    List<TransactionItem>? items,
    double? total,
    PaymentMethod? paymentMethod,
    int? customerId,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return Transaction(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      items: items ?? this.items,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerId: customerId ?? this.customerId,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.tenantId == tenantId &&
        other.total == total &&
        other.paymentMethod == paymentMethod &&
        other.customerId == customerId &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tenantId.hashCode ^
        total.hashCode ^
        paymentMethod.hashCode ^
        customerId.hashCode ^
        isSynced.hashCode;
  }
}
