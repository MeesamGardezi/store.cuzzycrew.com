enum PaymentStatus { pending, paid, failed }

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
    required this.stripeSessionId,
    required this.paymentIntentId,
    required this.paymentStatus,
    required this.currency,
    required this.subtotal,
    required this.tax,
    required this.shippingCost,
    required this.total,
    required this.items,
    required this.shippingAddress,
    required this.createdAt,
  });

  final String id;
  final String? stripeSessionId;
  final String? paymentIntentId;
  final PaymentStatus paymentStatus;
  final String currency;
  final double subtotal;
  final double tax;
  final double shippingCost;
  final double total;
  final List<Map<String, dynamic>> items;
  final ShippingAddress shippingAddress;
  final DateTime createdAt;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['paymentStatus'] ?? '').toString().toLowerCase();
    final normalizedStatus =
        rawStatus == 'succeeded' || rawStatus == 'paid'
            ? PaymentStatus.paid
            : rawStatus == 'failed'
            ? PaymentStatus.failed
            : PaymentStatus.pending;

    return OrderModel(
      id: (json['id'] ?? '').toString(),
      stripeSessionId: json['stripeSessionId']?.toString(),
      paymentIntentId: json['paymentIntentId']?.toString(),
      paymentStatus: normalizedStatus,
      currency: (json['currency'] ?? 'USD').toString(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stripeSessionId': stripeSessionId,
      'paymentIntentId': paymentIntentId,
      'paymentStatus': paymentStatus.name,
      'currency': currency,
      'subtotal': subtotal,
      'tax': tax,
      'shippingCost': shippingCost,
      'total': total,
      'items': items,
      'shippingAddress': shippingAddress.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
