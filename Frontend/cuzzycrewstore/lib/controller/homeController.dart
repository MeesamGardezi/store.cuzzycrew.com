import 'package:cuzzycrewstore/model/categoryModel.dart';
import 'package:cuzzycrewstore/model/productModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    try {
      String? data;
      final List<String> assetKeys = [
        'assets/json/categories.json',
        'json/categories.json',
      ];

      for (final key in assetKeys) {
        try {
          data = await rootBundle.loadString(key);
          if (data.isNotEmpty) {
            break;
          }
        } catch (_) {}
      }

      if (data == null || data.isEmpty) {
        throw Exception(
          'Unable to load categories asset. Tried: ${assetKeys.join(', ')}',
        );
      }

      final List<CategoryModel> loadedCategories = categoryModelFromJson(data);
      categories.value = loadedCategories;
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void fetchProducts(BuildContext context) async {
    isProductsLoading.value = true;
    try {
      String? data;
      final List<String> assetKeys = [
        'assets/json/products.json',
        'json/products.json',
      ];

      for (final key in assetKeys) {
        try {
          data = await rootBundle.loadString(key);
          if (data.isNotEmpty) {
            break;
          }
        } catch (_) {}
      }

      if (data == null || data.isEmpty) {
        throw Exception(
          'Unable to load products asset. Tried: ${assetKeys.join(', ')}',
        );
      }

      final List<ProductModel> loadedProducts = productModelFromJson(data);
      products.value = loadedProducts;
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      isProductsLoading.value = false;
    }
  }
}
