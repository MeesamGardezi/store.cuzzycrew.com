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

  /// Gets the main image for the selected color
  String get mainImage {
    try {
      final colorImage =
          product.colorVariants
              .firstWhere((v) => v.colorHex.toLowerCase() == _selectedColorHex)
              .image;
      if (colorImage.trim().isNotEmpty) {
        return colorImage;
      }
    } catch (_) {}
    return product.primaryImage;
  }

  /// Gets all images for the gallery, with selected color image first
  List<String> get aggregatedImages {
    final images = <String>[];
    final seen = <String>{};

    // Add the selected color's image first
    final colorImage = mainImage;
    if (colorImage.trim().isNotEmpty) {
      images.add(colorImage);
      seen.add(colorImage);
    }

    // Add other product images (excluding the main/color image)
    for (final img in product.images) {
      if (img.trim().isNotEmpty && !seen.contains(img)) {
        images.add(img);
        seen.add(img);
      }
    }

    // Add other color variant images (excluding the selected one and already added)
    for (final variant in product.colorVariants) {
      if (variant.image.trim().isNotEmpty && !seen.contains(variant.image)) {
        images.add(variant.image);
        seen.add(variant.image);
      }
    }

    return images;
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
