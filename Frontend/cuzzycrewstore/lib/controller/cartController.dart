import 'dart:convert';

import 'package:cuzzycrewstore/model/cartItemModel.dart';
import 'package:cuzzycrewstore/model/productModel.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class CartController extends ChangeNotifier {
  CartController() : _items = [] {
    _restoreCart();
  }

  static const String _cartStorageKey = 'cart_items_v1';

  final List<CartItem> _items;

  Future<void> _persistCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_items.map(_serializeCartItem).toList());
      await prefs.setString(_cartStorageKey, encoded);
    } catch (_) {}
  }

  Future<void> _restoreCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cartStorageKey);
      if (raw == null || raw.trim().isEmpty) return;

      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      _items
        ..clear()
        ..addAll(
          decoded.whereType<Map>().map(
            (item) => CartItem.fromJson(Map<String, dynamic>.from(item)),
          ),
        );
      notifyListeners();
    } catch (_) {}
  }

  Map<String, dynamic> _serializeCartItem(CartItem item) {
    return {
      'id': item.id,
      'product': {
        'id': item.product.id,
        'category': item.product.category,
        'dateAdded': item.product.dateAdded.toIso8601String(),
        'name': item.product.name,
        'shortName': item.product.shortName,
        'price': item.product.price,
        'currency': item.product.currency,
        'unit': item.product.unit,
        'availableUnits': item.product.availableUnits,
        'thumbnail': item.product.thumbnail,
        'images': item.product.images,
        'sizeGuideImage': item.product.sizeGuideImage,
        'sizes': item.product.sizes,
        'story': item.product.story,
        'launched': item.product.launched,
        'colorVariants':
            item.product.colorVariants
                .map(
                  (variant) => {
                    'colorName': variant.colorName,
                    'colorHex': variant.colorHex,
                    'image': variant.image,
                  },
                )
                .toList(),
      },
      'selectedColor': item.selectedColor,
      'selectedSize': item.selectedSize,
      'quantity': item.quantity,
      'priceAtAddTime': item.priceAtAddTime,
      'addedAt': item.addedAt.toIso8601String(),
    };
  }

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  String get displayCurrency =>
      _items.isNotEmpty ? _items.first.product.currency : 'USD';

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  double get total => subtotal; // Add tax/shipping calculation if needed later

  bool get isEmpty => _items.isEmpty;

  /// Add item to cart
  void addToCart({
    required ProductModel product,
    required String selectedColorHex,
    required String selectedSize,
    required int quantity,
  }) {
    // Check if item with same product and specs already exists
    final existingIndex = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedColor == selectedColorHex &&
          item.selectedSize == selectedSize,
    );

    if (existingIndex >= 0) {
      // Update quantity if it exists
      updateQuantity(
        _items[existingIndex].id,
        _items[existingIndex].quantity + quantity,
      );
    } else {
      // Add new item
      final cartItem = CartItem(
        id: const Uuid().v4(),
        product: product,
        selectedColor: selectedColorHex,
        selectedSize: selectedSize,
        quantity: quantity,
        priceAtAddTime: product.price,
        addedAt: DateTime.now(),
      );
      _items.add(cartItem);
    }
    _persistCart();
    notifyListeners();
  }

  /// Update quantity for a cart item
  void updateQuantity(String cartItemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(cartItemId);
      return;
    }

    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      final oldItem = _items[index];
      _items[index] = CartItem(
        id: oldItem.id,
        product: oldItem.product,
        selectedColor: oldItem.selectedColor,
        selectedSize: oldItem.selectedSize,
        quantity: newQuantity,
        priceAtAddTime: oldItem.priceAtAddTime,
        addedAt: oldItem.addedAt,
      );
      _persistCart();
      notifyListeners();
    }
  }

  /// Remove item from cart
  void removeFromCart(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      _items.removeAt(index);
      _persistCart();
      notifyListeners();
    }
  }

  /// Clear entire cart
  void clearCart() {
    _items.clear();
    _persistCart();
    notifyListeners();
  }

  /// Get cart summary for checkout
  Map<String, dynamic> getCartData() {
    return {
      'items':
          _items
              .map(
                (item) => {
                  'cartItemId': item.id,
                  'productId': item.product.id,
                  'name': item.product.name,
                  'productName': item.product.name,
                  'currency': item.product.currency,
                  'quantity': item.quantity,
                  'selectedColor': item.selectedColor,
                  'selectedSize': item.selectedSize,
                  'price': item.priceAtAddTime,
                  'pricePerItem': item.priceAtAddTime,
                  'totalPrice': item.totalPrice,
                },
              )
              .toList(),
      'currency': displayCurrency,
      'subtotal': subtotal,
      'total': total,
      'itemCount': itemCount,
    };
  }

  /// Get color name from hex
  String getColorName(String colorHex) {
    try {
      for (var item in _items) {
        final colorVariant = item.product.colorVariants.firstWhere(
          (v) => v.colorHex.toLowerCase() == colorHex.toLowerCase(),
        );
        return colorVariant.colorName;
      }
      return colorHex;
    } catch (_) {
      return colorHex;
    }
  }
}
