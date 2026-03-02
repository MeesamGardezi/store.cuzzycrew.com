import 'package:cuzzycrewstore/model/cartItemModel.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

class Order {
  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.shippingAddress,
    this.notes,
  });

  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? shippingAddress;
  final String? notes;

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items:
          (json['items'] as List<dynamic>? ?? [])
              .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
              .toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      shippingAddress: json['shippingAddress'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'shippingAddress': shippingAddress,
      'notes': notes,
    };
  }
}
