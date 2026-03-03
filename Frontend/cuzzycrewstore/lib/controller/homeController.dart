import 'package:cuzzycrewstore/api/ApiService.dart';
import 'package:cuzzycrewstore/model/categoryModel.dart';
import 'package:cuzzycrewstore/model/productModel.dart';
import 'package:flutter/material.dart';

class Homecontroller {
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isProductsLoading = ValueNotifier<bool>(false);
  final ValueNotifier<List<CategoryModel>> categories =
      ValueNotifier<List<CategoryModel>>([]);
  final ValueNotifier<List<ProductModel>> products =
      ValueNotifier<List<ProductModel>>([]);

  onInit(BuildContext context) {
    fetchCategories(context);
    fetchProducts(context);
  }

  void fetchCategories(BuildContext context) async {
    isLoading.value = true;
    debugPrint('🔄 [HomeController] Fetching categories...');

    try {
      final res = await ApiService().getCategories();
      final items =
          (res['data'] as Map<String, dynamic>?)?['categories']
              as List<dynamic>? ??
          <dynamic>[];
      final remote =
          items
              .map(
                (item) => CategoryModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
      if (remote.isNotEmpty) {
        categories.value = remote;
        debugPrint(
          '✅ [HomeController] Successfully fetched ${remote.length} categories from API',
        );

        return;
      }
      debugPrint('⚠️ [HomeController] No categories returned from API');
    } catch (e) {
      debugPrint(
        '❌ [HomeController] API Category fetch failed, falling back to local JSON: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void fetchProducts(BuildContext context) async {
    isProductsLoading.value = true;
    debugPrint('🔄 [HomeController] Fetching products...');

    // Try API first
    try {
      final res = await ApiService().getProducts();
      final items =
          (res['data'] as Map<String, dynamic>?)?['products']
              as List<dynamic>? ??
          <dynamic>[];
      final remote =
          items
              .map(
                (item) => ProductModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
      if (remote.isNotEmpty) {
        products.value = remote;
        debugPrint(
          '✅ [HomeController] Successfully fetched ${remote.length} products from API',
        );

        return;
      }
      debugPrint('⚠️ [HomeController] No products returned from API');
    } catch (e) {
      debugPrint(
        '❌ [HomeController] API Product fetch failed, falling back to local JSON: $e',
      );
    } finally {
      isProductsLoading.value = false;
    }
  }
}
