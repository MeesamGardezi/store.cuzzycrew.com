enum OrderStatus {
  pending,
  paid,
  processing,
  shipped,
  delivered,
  canceled,
  failed,
}

class Order {
  final String id;
  final String orderNumber;
  final OrderStatus status;
  final String? userId;
  final String? orderToken;
  final bool processed;
  final DateTime? processedAt;
  final String? processedBy;
  final String? paymentProvider;
  final String? paymentStatus;
  final Map<String, dynamic>? shippingAddress;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double discountTotal;
  final double total;
  final String currency;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.userId,
    required this.orderToken,
    required this.processed,
    required this.processedAt,
    required this.processedBy,
    required this.paymentProvider,
    required this.paymentStatus,
    required this.shippingAddress,
    required this.items,
    required this.subtotal,
    required this.discountTotal,
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
      userId: json['userId'] as String?,
      orderToken: json['orderToken'] as String?,
      processed: (json['processed'] as bool?) ?? false,
      processedAt: DateTime.tryParse(json['processedAt'] as String? ?? ''),
      processedBy: json['processedBy'] as String?,
      paymentProvider: json['paymentProvider'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      shippingAddress: _asMap(json['shippingAddress']),
      items: _asMapList(json['items']),
      subtotal: _toDisplayAmount(json['subtotal']),
      discountTotal: _toDisplayAmount(json['discountTotal']),
      total: _toDisplayAmount(json['total']),
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
      case 'PAID':
        return OrderStatus.paid;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'SHIPPED':
        return OrderStatus.shipped;
      case 'CANCELED':
      case 'CANCELLED':
        return OrderStatus.canceled;
      case 'FAILED':
        return OrderStatus.failed;
      default:
        return OrderStatus.pending;
    }
  }

  static double _toDisplayAmount(dynamic value) {
    return ((value as num?)?.toDouble() ?? 0.0) / 100.0;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.paid:
        return 'Paid';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.canceled:
        return 'Canceled';
      case OrderStatus.failed:
        return 'Failed';
    }
  }

  bool get isProcessed => processed;
}
