import 'dart:convert';
import 'package:cuzzycrewstore/model/productModel.dart';

class CartItem {
  CartItem({
    required this.id,
    required this.product,
    required this.selectedColor,
    required this.selectedSize,
    required this.quantity,
    required this.priceAtAddTime,
    required this.addedAt,
  
  });

  final String id;
  final ProductModel product;
  final String selectedColor; // color hex
  final String selectedSize;
  final int quantity;
  final double priceAtAddTime;
  final DateTime addedAt;

  double get totalPrice => priceAtAddTime * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      product: ProductModel.fromJson(json['product']),
      selectedColor: json['selectedColor'] ?? '',
      selectedSize: json['selectedSize'] ?? '',
      quantity: json['quantity'] ?? 1,
      priceAtAddTime: (json['priceAtAddTime'] as num?)?.toDouble() ?? 0.0,
      addedAt: DateTime.tryParse(json['addedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
      'quantity': quantity,
      'priceAtAddTime': priceAtAddTime,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}
