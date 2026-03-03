enum OrderStatus { pending, processing, delivered, cancelled }

class Order {
  final String id;
  final String orderNumber;
  final OrderStatus status;
  final double total;
  final String currency;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    required this.currency,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawStatus =
        (json['status'] as String? ?? 'PENDING_PAYMENT').toUpperCase();
    final status = _parseStatus(rawStatus);

    return Order(
      id: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      status: status,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static OrderStatus _parseStatus(String status) {
    switch (status) {
      case 'PROCESSING':
        return OrderStatus.processing;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
