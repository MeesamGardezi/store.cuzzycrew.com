import 'package:flutter/foundation.dart' hide Category;
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductController extends ChangeNotifier {
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/api/products');
      final items =
          (response['data'] as Map<String, dynamic>?)?['products']
              as List<dynamic>? ??
          [];

      _products =
          items
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList();

      debugPrint('✅ Loaded ${_products.length} products');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/api/categories');
      final items =
          (response['data'] as Map<String, dynamic>?)?['items']
              as List<dynamic>? ??
          (response['data'] as Map<String, dynamic>?)?['categories']
              as List<dynamic>? ??
          [];

      _categories =
          items
              .map((item) => Category.fromJson(item as Map<String, dynamic>))
              .toList();

      debugPrint('✅ Loaded ${_categories.length} categories');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      debugPrint('🗑️ Deleting product: $productId');
      await ApiService.delete('/api/admin/products/$productId');
      _products.removeWhere((p) => p.id == productId);
      debugPrint('✅ Product deleted successfully');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete product: $e';
      debugPrint('❌ Error deleting product: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      debugPrint('🗑️ Deleting category: $categoryId');
      await ApiService.delete('/api/admin/categories/$categoryId');
      _categories.removeWhere((c) => c.id == categoryId);
      debugPrint('✅ Category deleted successfully');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete category: $e';
      debugPrint('❌ Error deleting category: $e');
    }
  }

  Future<bool> createProduct({
    required Map<String, dynamic> payload,
    Uint8List? thumbnailBytes,
    List<Uint8List> imageBytes = const [],
    Uint8List? sizeGuideImageBytes,
  }) async {
    try {
      final sanitizedPayload = _sanitizeProductPayload(payload);
      final files = <http.MultipartFile>[];
      if (thumbnailBytes != null) {
        files.add(
          http.MultipartFile.fromBytes(
            'thumbnail',
            thumbnailBytes,
            filename: 'thumbnail.jpg',
          ),
        );
      }
      if (sizeGuideImageBytes != null) {
        files.add(
          http.MultipartFile.fromBytes(
            'sizeGuideImage',
            sizeGuideImageBytes,
            filename: 'size-guide.jpg',
          ),
        );
      }
      for (var index = 0; index < imageBytes.length; index += 1) {
        files.add(
          http.MultipartFile.fromBytes(
            'images',
            imageBytes[index],
            filename: 'image_$index.jpg',
          ),
        );
      }

      await ApiService.postMultipart(
        '/api/admin/products',
        fields: {'data': jsonEncode(sanitizedPayload)},
        files: files,
      );
      await fetchProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create product: $e';
      debugPrint('❌ Error creating product: $e');
      notifyListeners();
      return false;
    }
  }

  Map<String, dynamic> _sanitizeProductPayload(Map<String, dynamic> payload) {
    final sanitized = <String, dynamic>{};

    for (final entry in payload.entries) {
      final key = entry.key;
      final value = entry.value;

      if (key == 'thumbnailBytes' ||
          key == 'sizeGuideImageBytes' ||
          key == 'images' &&
              value is List &&
              value.every((item) => item is Uint8List)) {
        continue;
      }

      if (key == 'colorVariants' && value is List) {
        sanitized[key] =
            value.whereType<Map>().map((variant) {
              final variantMap = Map<String, dynamic>.from(variant);
              final imageValue = variantMap['image'];
              if (imageValue is Uint8List) {
                variantMap['image'] =
                    'data:image/png;base64,${base64Encode(imageValue)}';
              }
              variantMap.remove('imageBytes');
              variantMap.remove('imageFile');
              return variantMap;
            }).toList();
        continue;
      }

      if (value is Uint8List) {
        continue;
      }

      sanitized[key] = value;
    }

    return sanitized;
  }

  Future<bool> createCategory({
    required Map<String, dynamic> payload,
    Uint8List? thumbnailBytes,
  }) async {
    try {
      final categoryPayload = Map<String, dynamic>.from(payload);
      if (thumbnailBytes != null) {
        categoryPayload['thumbnail'] =
            'data:image/png;base64,${base64Encode(thumbnailBytes)}';
      }

      await ApiService.post('/api/admin/categories', categoryPayload);
      await fetchCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create category: $e';
      debugPrint('❌ Error creating category: $e');
      notifyListeners();
      return false;
    }
  }
}
