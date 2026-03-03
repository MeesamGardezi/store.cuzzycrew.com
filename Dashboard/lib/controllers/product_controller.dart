import 'package:flutter/foundation.dart' hide Category;
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
      await ApiService.delete('/api/products/$productId');
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
      await ApiService.delete('/api/categories/$categoryId');
      _categories.removeWhere((c) => c.id == categoryId);
      debugPrint('✅ Category deleted successfully');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete category: $e';
      debugPrint('❌ Error deleting category: $e');
    }
  }
}
