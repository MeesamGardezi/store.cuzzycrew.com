import 'package:cuzzycrewstore/api/ApiService.dart';
import 'package:cuzzycrewstore/model/productModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const String allCategoryKey = 'all';

enum ShopSortOption { featured, newest, priceLowToHigh, priceHighToLow }

class ShopController extends ChangeNotifier {
  ShopController({String? initialCategory})
    : _initialCategory = initialCategory?.trim().toLowerCase();

  final String? _initialCategory;

  bool _isLoading = false;
  List<ProductModel> _allProducts = <ProductModel>[];
  Set<String> _apiCategoryKeys = <String>{};

  String _selectedCategory = allCategoryKey;
  final Set<String> _selectedSizes = <String>{};
  final Set<String> _selectedColors = <String>{};

  ShopSortOption _sortOption = ShopSortOption.featured;

  double _minPriceBound = 0;
  double _maxPriceBound = 0;
  double _selectedMinPrice = 0;
  double _selectedMaxPrice = 0;

  int _itemsPerPage = 6;
  int _currentPage = 1;

  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  Set<String> get selectedSizes => _selectedSizes;
  Set<String> get selectedColors => _selectedColors;
  ShopSortOption get sortOption => _sortOption;

  double get minPriceBound => _minPriceBound;
  double get maxPriceBound => _maxPriceBound;
  double get selectedMinPrice => _selectedMinPrice;
  double get selectedMaxPrice => _selectedMaxPrice;

  int get itemsPerPage => _itemsPerPage;
  int get currentPage => _currentPage;

  static String normalizeCategory(String input) {
    return input.trim().toLowerCase();
  }

  static String normalizeSize(String input) {
    return input.trim().toLowerCase();
  }

  static String categoryLabel(String categoryKey) {
    if (categoryKey == allCategoryKey) {
      return 'All Items';
    }

    return categoryKey
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  static String shopHeading(String categoryKey) {
    if (categoryKey == allCategoryKey) {
      return 'ALL PRODUCTS';
    }

    return categoryLabel(categoryKey).toUpperCase();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    debugPrint('🔄 [ShopController] Initializing shop controller...');

    // Try API first
    try {
      debugPrint('🔄 [ShopController] Fetching products from API...');
      final ApiService api = ApiService();
      final res = await api.getProducts();
      final items =
          (res['data'] as Map<String, dynamic>?)?['products']
              as List<dynamic>? ??
          <dynamic>[];
      _allProducts =
          items
              .map(
                (item) => ProductModel.fromJson(item as Map<String, dynamic>),
              )
              .where((product) => product.launched)
              .toList();
      if (_allProducts.isNotEmpty) {
        debugPrint(
          '✅ [ShopController] Successfully loaded ${_allProducts.length} products from API',
        );
        await _fetchCategoryKeys(api);
        _setupPriceBounds();
        _applyInitialCategory();
        _clampCurrentPage();
        _isLoading = false;
        notifyListeners();
        return;
      }
      debugPrint(
        '⚠️ [ShopController] No launched products from API, trying fallback...',
      );
    } catch (e) {
      debugPrint(
        '❌ [ShopController] API Product fetch failed, falling back to local JSON: $e',
      );
    }

    // Fallback to local JSON
    String? data;
    const List<String> assetKeys = <String>[
      'assets/json/products.json',
      'json/products.json',
    ];

    for (final key in assetKeys) {
      try {
        debugPrint('🔄 [ShopController] Trying to load local JSON from: $key');
        data = await rootBundle.loadString(key);
        if (data.isNotEmpty) {
          debugPrint(
            '✅ [ShopController] Successfully loaded local JSON from: $key',
          );
          break;
        }
      } catch (_) {}
    }

    if (data == null || data.isEmpty) {
      throw Exception(
        'Unable to load products asset. Tried: ${assetKeys.join(', ')}',
      );
    }

    _allProducts =
        productModelFromJson(
          data,
        ).where((product) => product.launched).toList();

    debugPrint(
      '✅ [ShopController] Loaded ${_allProducts.length} products from local JSON fallback',
    );
    await _fetchCategoryKeys();
    _setupPriceBounds();
    _applyInitialCategory();
    _clampCurrentPage();
    _isLoading = false;
    notifyListeners();
  }

  void updateItemsPerPage(int nextValue) {
    if (nextValue <= 0 || _itemsPerPage == nextValue) {
      return;
    }

    _itemsPerPage = nextValue;
    _clampCurrentPage();
    notifyListeners();
  }

  void selectCategory(String categoryKey) {
    final normalized = normalizeCategory(categoryKey);
    if (_selectedCategory == normalized) {
      return;
    }

    _selectedCategory = normalized;
    _selectedSizes.clear();
    _selectedColors.clear();
    _setupPriceBounds(forCategoryOnly: true);
    _currentPage = 1;
    notifyListeners();
  }

  void toggleSize(String size) {
    final normalized = normalizeSize(size);
    if (_selectedSizes.contains(normalized)) {
      _selectedSizes.remove(normalized);
    } else {
      _selectedSizes.add(normalized);
    }

    _currentPage = 1;
    notifyListeners();
  }

  void toggleColor(String colorHex) {
    final normalized = colorHex.toLowerCase();
    if (_selectedColors.contains(normalized)) {
      _selectedColors.remove(normalized);
    } else {
      _selectedColors.add(normalized);
    }

    _currentPage = 1;
    notifyListeners();
  }

  void applyFilters({
    required String category,
    required Set<String> sizes,
    required Set<String> colors,
    required double minPrice,
    required double maxPrice,
  }) {
    final normalizedCategory = normalizeCategory(category);
    final normalizedSizes = sizes.map(normalizeSize).toSet();
    final normalizedColors = colors.map((value) => value.toLowerCase()).toSet();

    final priceBounds = priceBoundsForCategory(normalizedCategory);
    final boundedMin = minPrice.clamp(priceBounds.$1, priceBounds.$2);
    final boundedMax = maxPrice.clamp(priceBounds.$1, priceBounds.$2);

    _selectedCategory = normalizedCategory;
    _selectedSizes
      ..clear()
      ..addAll(normalizedSizes);
    _selectedColors
      ..clear()
      ..addAll(normalizedColors);
    _minPriceBound = priceBounds.$1;
    _maxPriceBound = priceBounds.$2;
    _selectedMinPrice = boundedMin <= boundedMax ? boundedMin : boundedMax;
    _selectedMaxPrice = boundedMax >= boundedMin ? boundedMax : boundedMin;

    _currentPage = 1;
    notifyListeners();
  }

  void setSortOption(ShopSortOption option) {
    if (_sortOption == option) {
      return;
    }

    _sortOption = option;
    _currentPage = 1;
    notifyListeners();
  }

  void setPriceRange(double minValue, double maxValue) {
    final nextMin = minValue.clamp(_minPriceBound, _maxPriceBound);
    final nextMax = maxValue.clamp(_minPriceBound, _maxPriceBound);

    if (_selectedMinPrice == nextMin && _selectedMaxPrice == nextMax) {
      return;
    }

    _selectedMinPrice = nextMin;
    _selectedMaxPrice = nextMax;
    _currentPage = 1;
    notifyListeners();
  }

  void goToPage(int page) {
    if (page < 1 || page > totalPages || page == _currentPage) {
      return;
    }

    _currentPage = page;
    notifyListeners();
  }

  void applyExternalCategory(String? category) {
    if (category == null || category.trim().isEmpty) {
      return;
    }

    final normalized = normalizeCategory(category);
    if (normalized == allCategoryKey) {
      selectCategory(allCategoryKey);
      return;
    }

    final hasCategory =
        _apiCategoryKeys.contains(normalized) ||
        _allProducts.any(
          (product) => normalizeCategory(product.category) == normalized,
        );

    if (hasCategory) {
      selectCategory(normalized);
    }
  }

  Map<String, int> get categoryCounts {
    final counts = <String, int>{allCategoryKey: _allProducts.length};

    for (final categoryKey in _apiCategoryKeys) {
      if (categoryKey == allCategoryKey) continue;
      counts.putIfAbsent(categoryKey, () => 0);
    }

    for (final product in _allProducts) {
      final key = normalizeCategory(product.category);
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return counts;
  }

  int get categoryItemCount => _categoryFilteredProducts.length;

  List<String> get availableSizes {
    return availableSizesForCategory(_selectedCategory);
  }

  List<String> get availableColors {
    return availableColorsForCategory(_selectedCategory);
  }

  List<String> availableSizesForCategory(String categoryKey) {
    final sizes = <String>{};
    for (final product in _productsForCategory(categoryKey)) {
      sizes.addAll(product.sizes);
    }

    final result = sizes.toList();
    result.sort((a, b) => normalizeSize(a).compareTo(normalizeSize(b)));
    return result;
  }

  List<String> availableColorsForCategory(String categoryKey) {
    final colors = <String>{};
    for (final product in _productsForCategory(categoryKey)) {
      for (final variant in product.colorVariants) {
        final normalized = variant.colorHex.toLowerCase();
        if (normalized.isNotEmpty) {
          colors.add(normalized);
        }
      }
    }

    return colors.toList();
  }

  (double, double) priceBoundsForCategory(String categoryKey) {
    final prices =
        _productsForCategory(
          categoryKey,
        ).map((product) => product.price).toList();

    if (prices.isEmpty) {
      return (0, 0);
    }

    prices.sort();
    return (prices.first, prices.last);
  }

  int get totalItemCount => sortedFilteredProducts.length;

  int get totalPages {
    if (totalItemCount == 0) {
      return 1;
    }

    return (totalItemCount / _itemsPerPage).ceil();
  }

  List<ProductModel> get currentPageItems {
    if (sortedFilteredProducts.isEmpty) {
      return const <ProductModel>[];
    }

    final start = (_currentPage - 1) * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, sortedFilteredProducts.length);

    return sortedFilteredProducts.sublist(start, end);
  }

  List<ProductModel> get sortedFilteredProducts {
    final filtered = _filteredProducts.toList();

    switch (_sortOption) {
      case ShopSortOption.featured:
      case ShopSortOption.newest:
        filtered.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case ShopSortOption.priceLowToHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ShopSortOption.priceHighToLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
    }

    return filtered;
  }

  Iterable<ProductModel> get _categoryFilteredProducts {
    if (_selectedCategory == allCategoryKey) {
      return _allProducts;
    }

    return _allProducts.where(
      (product) => normalizeCategory(product.category) == _selectedCategory,
    );
  }

  Iterable<ProductModel> get _filteredProducts {
    return _categoryFilteredProducts.where((product) {
      if (_selectedSizes.isNotEmpty &&
          !product.sizes.any(
            (size) => _selectedSizes.contains(normalizeSize(size)),
          )) {
        return false;
      }

      if (_selectedColors.isNotEmpty &&
          !product.colorVariants.any(
            (variant) =>
                _selectedColors.contains(variant.colorHex.toLowerCase()),
          )) {
        return false;
      }

      if (product.price < _selectedMinPrice ||
          product.price > _selectedMaxPrice) {
        return false;
      }

      return true;
    });
  }

  void _setupPriceBounds({bool forCategoryOnly = false}) {
    final prices =
        (forCategoryOnly ? _categoryFilteredProducts : _allProducts)
            .map((product) => product.price)
            .toList();

    if (prices.isEmpty) {
      _minPriceBound = 0;
      _maxPriceBound = 0;
      _selectedMinPrice = 0;
      _selectedMaxPrice = 0;
      return;
    }

    prices.sort();
    _minPriceBound = prices.first;
    _maxPriceBound = prices.last;
    _selectedMinPrice = _minPriceBound;
    _selectedMaxPrice = _maxPriceBound;
  }

  Iterable<ProductModel> _productsForCategory(String categoryKey) {
    final normalizedCategory = normalizeCategory(categoryKey);
    if (normalizedCategory == allCategoryKey) {
      return _allProducts;
    }

    return _allProducts.where(
      (product) => normalizeCategory(product.category) == normalizedCategory,
    );
  }

  void _applyInitialCategory() {
    final initialCategory = _initialCategory;
    if (initialCategory == null || initialCategory.isEmpty) {
      return;
    }

    final normalized = normalizeCategory(initialCategory);
    if (normalized == allCategoryKey) {
      _selectedCategory = allCategoryKey;
      return;
    }

    final hasCategory =
        _apiCategoryKeys.contains(normalized) ||
        _allProducts.any(
          (product) => normalizeCategory(product.category) == normalized,
        );

    if (hasCategory) {
      _selectedCategory = normalized;
      _setupPriceBounds(forCategoryOnly: true);
    }
  }

  Future<void> _fetchCategoryKeys([ApiService? api]) async {
    try {
      final service = api ?? ApiService();
      final res = await service.getCategories();
      final data = res['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final items =
          data['items'] as List<dynamic>? ??
          data['categories'] as List<dynamic>? ??
          const <dynamic>[];

      final keys = <String>{};
      for (final item in items.whereType<Map>()) {
        final json = Map<String, dynamic>.from(item);
        final launched = (json['launched'] as bool?) ?? true;
        if (!launched) continue;

        final slug = normalizeCategory((json['slug'] ?? '').toString());
        final name = normalizeCategory((json['name'] ?? '').toString());
        final key = slug.isNotEmpty ? slug : name;
        if (key.isNotEmpty) {
          keys.add(key);
        }
      }

      _apiCategoryKeys = keys;
      debugPrint(
        '✅ [ShopController] Loaded ${_apiCategoryKeys.length} category keys from API',
      );
    } catch (e) {
      debugPrint(
        '⚠️ [ShopController] Failed to fetch category keys from API: $e',
      );
      _apiCategoryKeys = <String>{};
    }
  }

  void _clampCurrentPage() {
    if (_currentPage > totalPages) {
      _currentPage = totalPages;
    }
    if (_currentPage < 1) {
      _currentPage = 1;
    }
  }
}
