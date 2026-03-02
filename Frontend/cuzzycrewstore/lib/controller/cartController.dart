import 'package:cuzzycrewstore/model/cartItemModel.dart';
import 'package:cuzzycrewstore/model/productModel.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class CartController extends ChangeNotifier {
  CartController() : _items = [];

  final List<CartItem> _items;
  String? _lastRemovedItem;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;

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
      notifyListeners();
    }
  }

  /// Remove item from cart
  void removeFromCart(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      _lastRemovedItem = _items[index].id;
      _items.removeAt(index);
      notifyListeners();
    }
  }

  /// Clear entire cart
  void clearCart() {
    _items.clear();
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
                  'productName': item.product.name,
                  'quantity': item.quantity,
                  'selectedColor': item.selectedColor,
                  'selectedSize': item.selectedSize,
                  'pricePerItem': item.priceAtAddTime,
                  'totalPrice': item.totalPrice,
                },
              )
              .toList(),
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
