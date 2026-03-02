import 'package:cuzzycrewstore/model/productModel.dart';
import 'package:flutter/foundation.dart';

class ProductDetailController extends ChangeNotifier {
  ProductDetailController({required this.product})
    : _selectedColorHex =
          product.colorVariants.isNotEmpty
              ? product.colorVariants.first.colorHex.toLowerCase()
              : '',
      _selectedSize = product.sizes.isNotEmpty ? product.sizes.first : '';

  final ProductModel product;

  String _selectedColorHex;
  String _selectedSize;
  int _quantity = 1;

  @override
  void dispose() {
    super.dispose();
  }

  String get selectedColorHex => _selectedColorHex;
  String get selectedSize => _selectedSize;
  int get quantity => _quantity;

  String get selectedColorName {
    try {
      return product.colorVariants
          .firstWhere((v) => v.colorHex.toLowerCase() == _selectedColorHex)
          .colorName;
    } catch (_) {
      return '';
    }
  }

  List<String> get aggregatedImages {
    final images = <String>{};

    // Add product images first
    images.addAll(product.images.where((img) => img.trim().isNotEmpty));

    // Add color variant images
    for (final variant in product.colorVariants) {
      if (variant.image.trim().isNotEmpty) {
        images.add(variant.image);
      }
    }

    return images.toList();
  }

  String get mainImage {
    try {
      final colorImage =
          product.colorVariants
              .firstWhere((v) => v.colorHex.toLowerCase() == _selectedColorHex)
              .image;
      if (colorImage.isNotEmpty) {
        return colorImage;
      }
    } catch (_) {}

    return product.primaryImage;
  }

  void selectColor(String hex) {
    final normalized = hex.toLowerCase();
    if (_selectedColorHex != normalized) {
      _selectedColorHex = normalized;
      notifyListeners();
    }
  }

  void selectSize(String size) {
    if (_selectedSize != size) {
      _selectedSize = size;
      notifyListeners();
    }
  }

  void setQuantity(int value) {
    final clamped = value.clamp(1, product.availableUnits);
    if (_quantity != clamped) {
      _quantity = clamped;
      notifyListeners();
    }
  }

  void incrementQuantity() {
    setQuantity(_quantity + 1);
  }

  void decrementQuantity() {
    setQuantity(_quantity - 1);
  }
}
