enum PaymentStatus { pending, paid, failed }

enum OrderStatus { pendingPayment, paid, failed, canceled, shipped, delivered }

class ShippingAddress {
  const ShippingAddress({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  final String fullName;
  final String email;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: (json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      street: (json['street'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      zipCode: (json['zipCode'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.orderToken,
    required this.orderStatus,
    required this.paymentProvider,
    required this.paymentStatus,
    required this.currency,
    required this.subtotal,
    required this.tax,
    required this.shippingCost,
    required this.total,
    required this.items,
    required this.shippingAddress,
    required this.createdAt,
    required this.processed,
    required this.processedAt,
    required this.processedBy,
  });

  final String id;
  final String? orderToken;
  final OrderStatus orderStatus;
  final String paymentProvider;
  final PaymentStatus paymentStatus;
  final String currency;
  final double subtotal;
  final double tax;
  final double shippingCost;
  final double total;
  final List<Map<String, dynamic>> items;
  final ShippingAddress shippingAddress;
  final DateTime createdAt;
  final bool processed;
  final DateTime? processedAt;
  final String? processedBy;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawPaymentStatus =
        (json['paymentStatus'] ?? '').toString().toLowerCase();
    final paymentStatus =
        rawPaymentStatus == 'succeeded' || rawPaymentStatus == 'paid'
            ? PaymentStatus.paid
            : rawPaymentStatus == 'failed'
            ? PaymentStatus.failed
            : PaymentStatus.pending;

    final rawOrderStatus =
        (json['status'] ?? json['orderStatus'] ?? 'PENDING_PAYMENT')
            .toString()
            .toUpperCase();
    final orderStatus = parseOrderStatus(rawOrderStatus);

    return OrderModel(
      id: (json['id'] ?? '').toString(),
      orderToken: json['orderToken']?.toString(),
      orderStatus: orderStatus,
      paymentProvider: (json['paymentProvider'] ?? 'paddle').toString(),
      paymentStatus: paymentStatus,
      currency: (json['currency'] ?? 'USD').toString().trim().toUpperCase(),
      subtotal: minorToMajor(json['subtotal']),
      tax: minorToMajor(json['tax']),
      shippingCost: minorToMajor(json['shippingCost']),
      total: minorToMajor(json['total']),
      items:
          (json['items'] as List<dynamic>? ?? const <dynamic>[])
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList(),
      shippingAddress: ShippingAddress.fromJson(
        Map<String, dynamic>.from(
          (json['shippingAddress'] as Map?) ?? const <String, dynamic>{},
        ),
      ),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      processed: (json['processed'] as bool?) ?? false,
      processedAt: DateTime.tryParse((json['processedAt'] ?? '').toString()),
      processedBy: json['processedBy']?.toString(),
    );
  }

  static double minorToMajor(dynamic value) {
    final amount = (value as num?)?.toDouble() ?? 0.0;
    return amount / 100.0;
  }

  static OrderStatus parseOrderStatus(String status) {
    switch (status) {
      case 'PAID':
        return OrderStatus.paid;
      case 'FAILED':
        return OrderStatus.failed;
      case 'CANCELED':
      case 'CANCELLED':
        return OrderStatus.canceled;
      case 'SHIPPED':
        return OrderStatus.shipped;
      case 'DELIVERED':
        return OrderStatus.delivered;
      default:
        return OrderStatus.pendingPayment;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderToken': orderToken,
      'orderStatus': orderStatus.name,
      'paymentProvider': paymentProvider,
      'paymentStatus': paymentStatus.name,
      'currency': currency,
      'subtotal': subtotal,
      'tax': tax,
      'shippingCost': shippingCost,
      'total': total,
      'items': items,
      'shippingAddress': shippingAddress.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'processed': processed,
      'processedAt': processedAt?.toIso8601String(),
      'processedBy': processedBy,
    };
  }
}
