import 'package:cuzzycrewstore/controller/shopController.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:cuzzycrewstore/views/pages/productdetailpage/productDetailPage.dart';
import 'package:cuzzycrewstore/views/widgets/shopProductCard.dart';
import 'package:flutter/material.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  late final ShopController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ShopController(initialCategory: widget.initialCategory);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ShopPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory) {
      _controller.applyExternalCategory(widget.initialCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 640;
    final isTablet = width >= 640 && width < 1024;

    final int perPage = isMobile ? 4 : (isTablet ? 4 : 6);
    _controller.updateItemsPerPage(perPage);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child:
                _controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 12 : 20,
                                vertical: isMobile ? 12 : 20,
                              ),
                              child:
                                  isMobile
                                      ? _ShopMobileLayout(
                                        controller: _controller,
                                      )
                                      : _ShopWideLayout(
                                        controller: _controller,
                                        isTablet: isTablet,
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }
}

class _ShopWideLayout extends StatelessWidget {
  const _ShopWideLayout({required this.controller, required this.isTablet});

  final ShopController controller;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;
    final baseWidth = isTablet ? 900.0 : 1280.0;
    final scale = (width / baseWidth).clamp(0.85, 1.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShopHeader(controller: controller),
        SizedBox(height: 18 * scale),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: isTablet ? width * 0.23 : width * 0.19,
              child: _ShopSidebar(controller: controller),
            ),
            SizedBox(width: 20 * scale),
            Expanded(
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.currentPageItems.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 2 : 3,
                      crossAxisSpacing: 14 * scale,
                      mainAxisSpacing: 16 * scale,
                      childAspectRatio: isTablet ? 0.67 : 0.70,
                    ),
                    itemBuilder: (context, index) {
                      return ShopProductCard(
                        product: controller.currentPageItems[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ProductDetailPage(
                                    product: controller.currentPageItems[index],
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  if (controller.currentPageItems.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 32 * scale),
                      child: Text(
                        'No products found for selected filters.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.slate400,
                        ),
                      ),
                    ),
                  SizedBox(height: 18 * scale),
                  _ShopPagination(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ShopMobileLayout extends StatefulWidget {
  const _ShopMobileLayout({required this.controller});

  final ShopController controller;

  @override
  State<_ShopMobileLayout> createState() => _ShopMobileLayoutState();
}

class _ShopMobileLayoutState extends State<_ShopMobileLayout> {
  Future<void> _openMobileFilters(BuildContext context) async {
    final controller = widget.controller;
    final nextCategory = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MobileFilterSidebar(controller: controller),
    );

    if (nextCategory != null && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 390).clamp(0.9, 1.15);
    final controller = widget.controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShopHeader(
          controller: controller,
          onOpenFilters: () => _openMobileFilters(context),
        ),
        SizedBox(height: 16 * scale),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.currentPageItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10 * scale,
            mainAxisSpacing: 14 * scale,
            childAspectRatio: 0.66,
          ),
          itemBuilder: (context, index) {
            return ShopProductCard(
              product: controller.currentPageItems[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ProductDetailPage(
                          product: controller.currentPageItems[index],
                        ),
                  ),
                );
              },
            );
          },
        ),
        if (controller.currentPageItems.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 24 * scale),
            child: Text(
              'No products found for selected filters.',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.slate400),
            ),
          ),
        SizedBox(height: 16 * scale),
        _ShopPagination(controller: controller),
      ],
    );
  }
}

class _ShopHeader extends StatelessWidget {
  const _ShopHeader({required this.controller, this.onOpenFilters});

  final ShopController controller;
  final VoidCallback? onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 640;
    final isDark = theme.brightness == Brightness.dark;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;
    final scale =
        isMobile
            ? (width / 390).clamp(0.9, 1.2)
            : (width / 1280).clamp(0.9, 1.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ShopController.shopHeading(controller.selectedCategory),
          style: textTheme.displayLarge?.copyWith(
            color: bodyColor,
            fontWeight: FontWeight.w700,
            fontSize: isMobile ? 44 : (width < 1024 ? 62 : 72),
            letterSpacing: 0.2,
            height: 0.92,
          ),
        ),
        SizedBox(height: 4 * scale),
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    '${controller.totalItemCount} ITEMS TOTAL',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryAccent,
                      letterSpacing: 1.0,
                      fontSize: 9.5 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 6 * scale),
                  Text(
                    '/ EST. 2024',
                    style: textTheme.bodySmall?.copyWith(
                      color: bodyColor,
                      letterSpacing: 1.0,
                      fontSize: 9.5 * scale,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * scale),
              Row(
                children: [
                  _SortDropdown(controller: controller),
                  SizedBox(width: 8 * scale),
                  _FilterButton(onTap: onOpenFilters),
                ],
              ),
            ],
          )
        else
          Row(
            children: [
              Text(
                '${controller.totalItemCount} ITEMS TOTAL',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryAccent,
                  letterSpacing: 1.0,
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 6 * scale),
              Text(
                '/ EST. 2024',
                style: textTheme.bodySmall?.copyWith(
                  color: bodyColor,
                  letterSpacing: 1.0,
                  fontSize: 15 * scale,
                ),
              ),
              const Spacer(),
              _SortDropdown(controller: controller),
            ],
          ),
        SizedBox(height: 14 * scale),
        Divider(color: theme.dividerColor, height: 1),
      ],
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.controller});

  final ShopController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurface,
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ShopSortOption>(
          value: controller.sortOption,
          dropdownColor:
              isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurface,
          iconEnabledColor: isDark ? AppColors.darkText : AppColors.lightText,
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
            fontSize: 9.5,
          ),
          onChanged: (option) {
            if (option != null) {
              controller.setSortOption(option);
            }
          },
          items: const [
            DropdownMenuItem(
              value: ShopSortOption.featured,
              child: Text('SORT BY: FEATURED', style: TextStyle(fontSize: 11)),
            ),
            DropdownMenuItem(
              value: ShopSortOption.newest,
              child: Text(
                'SORT BY: NEW ARRIVALS',
                style: TextStyle(fontSize: 11),
              ),
            ),
            DropdownMenuItem(
              value: ShopSortOption.priceLowToHigh,
              child: Text(
                'SORT BY: PRICE LOW-HIGH',
                style: TextStyle(fontSize: 11),
              ),
            ),
            DropdownMenuItem(
              value: ShopSortOption.priceHighToLow,
              child: Text(
                'SORT BY: PRICE HIGH-LOW',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 390).clamp(0.9, 1.15);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 35,
        padding: EdgeInsets.symmetric(horizontal: 12 * scale),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurface,
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Center(
          child: Text(
            'FILTER',
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileFilterSidebar extends StatefulWidget {
  const _MobileFilterSidebar({required this.controller});

  final ShopController controller;

  @override
  State<_MobileFilterSidebar> createState() => _MobileFilterSidebarState();
}

class _MobileFilterSidebarState extends State<_MobileFilterSidebar> {
  late String _selectedCategory;
  late Set<String> _selectedSizes;
  late Set<String> _selectedColors;
  late double _selectedMinPrice;
  late double _selectedMaxPrice;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.controller.selectedCategory;
    _selectedSizes = widget.controller.selectedSizes.toSet();
    _selectedColors = widget.controller.selectedColors.toSet();
    _selectedMinPrice = widget.controller.selectedMinPrice;
    _selectedMaxPrice = widget.controller.selectedMaxPrice;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final width = MediaQuery.of(context).size.width;
    final sheetWidth = (width * 0.9).clamp(280.0, 360.0);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;

    final categoryEntries =
        widget.controller.categoryCounts.entries.toList()..sort((a, b) {
          if (a.key == allCategoryKey) {
            return -1;
          }
          if (b.key == allCategoryKey) {
            return 1;
          }
          return a.key.compareTo(b.key);
        });

    final availableSizes = widget.controller.availableSizesForCategory(
      _selectedCategory,
    );
    final availableColors = widget.controller.availableColorsForCategory(
      _selectedCategory,
    );
    final priceBounds = widget.controller.priceBoundsForCategory(
      _selectedCategory,
    );

    if (_selectedMinPrice < priceBounds.$1 ||
        _selectedMinPrice > priceBounds.$2) {
      _selectedMinPrice = priceBounds.$1;
    }
    if (_selectedMaxPrice > priceBounds.$2 ||
        _selectedMaxPrice < priceBounds.$1) {
      _selectedMaxPrice = priceBounds.$2;
    }

    final showPriceRangeSection =
        widget.controller.categoryCounts[_selectedCategory] != null &&
        widget.controller.categoryCounts[_selectedCategory]! > 1;
    final showSizingSection =
        _selectedCategory != allCategoryKey && availableSizes.isNotEmpty;
    final showColorwaySection = availableColors.isNotEmpty;

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: sheetWidth,
          height: double.infinity,
          color: theme.scaffoldBackgroundColor,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FILTERS',
                    style: textTheme.titleMedium?.copyWith(
                      color: bodyColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(color: theme.dividerColor, height: 1),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(label: 'CATEGORIES'),
                          const SizedBox(height: 8),
                          ...categoryEntries.map((entry) {
                            final isSelected = _selectedCategory == entry.key;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = entry.key;
                                  final nextSizes = widget.controller
                                      .availableSizesForCategory(
                                        _selectedCategory,
                                      );
                                  final nextColors = widget.controller
                                      .availableColorsForCategory(
                                        _selectedCategory,
                                      );
                                  _selectedSizes =
                                      _selectedSizes
                                          .where(
                                            (size) => nextSizes.any(
                                              (value) =>
                                                  ShopController.normalizeSize(
                                                    value,
                                                  ) ==
                                                  size,
                                            ),
                                          )
                                          .toSet();
                                  _selectedColors =
                                      _selectedColors
                                          .where(nextColors.contains)
                                          .toSet();
                                  final nextBounds = widget.controller
                                      .priceBoundsForCategory(
                                        _selectedCategory,
                                      );
                                  _selectedMinPrice = nextBounds.$1;
                                  _selectedMaxPrice = nextBounds.$2;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                  horizontal: 6,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        ShopController.categoryLabel(entry.key),
                                        style: textTheme.bodySmall?.copyWith(
                                          color:
                                              isSelected
                                                  ? AppColors.primaryAccent
                                                  : bodyColor,
                                          fontSize: 14,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${entry.value.toString().padLeft(2, '0')}',
                                      style: textTheme.bodySmall?.copyWith(
                                        color:
                                            isSelected
                                                ? AppColors.primaryAccent
                                                : bodyColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          if (showPriceRangeSection) ...[
                            const SizedBox(height: 12),
                            Divider(color: theme.dividerColor, height: 1),
                            const SizedBox(height: 12),
                            const _SectionTitle(label: 'PRICE RANGE'),
                            const SizedBox(height: 10),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColors.primaryAccent,
                                inactiveTrackColor: colorScheme.outline
                                    .withValues(alpha: 0.45),
                                thumbColor: AppColors.primaryAccent,
                                overlayColor: AppColors.primaryAccent
                                    .withOpacity(0.15),
                                trackHeight: 2.5,
                              ),
                              child: RangeSlider(
                                values: RangeValues(
                                  _selectedMinPrice,
                                  _selectedMaxPrice,
                                ),
                                min: priceBounds.$1,
                                max:
                                    priceBounds.$2 == priceBounds.$1
                                        ? priceBounds.$1 + 1
                                        : priceBounds.$2,
                                onChanged:
                                    priceBounds.$2 <= priceBounds.$1
                                        ? null
                                        : (values) {
                                          setState(() {
                                            _selectedMinPrice = values.start;
                                            _selectedMaxPrice = values.end;
                                          });
                                        },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _MetaText(
                                  '\$${_selectedMinPrice.toStringAsFixed(0)}',
                                ),
                                _MetaText(
                                  '\$${_selectedMaxPrice.toStringAsFixed(0)}+',
                                ),
                              ],
                            ),
                          ],
                          if (showColorwaySection) ...[
                            const SizedBox(height: 12),
                            Divider(color: theme.dividerColor, height: 1),
                            const SizedBox(height: 12),
                            const _SectionTitle(label: 'COLORWAY'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  availableColors.map((hex) {
                                    final isSelected = _selectedColors.contains(
                                      hex,
                                    );
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedColors.remove(hex);
                                          } else {
                                            _selectedColors.add(hex);
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _safeColor(hex),
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? AppColors.primaryAccent
                                                    : bodyColor,
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                          if (showSizingSection) ...[
                            const SizedBox(height: 12),
                            Divider(color: theme.dividerColor, height: 1),
                            const SizedBox(height: 12),
                            const _SectionTitle(label: 'SIZING'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children:
                                  availableSizes.map((size) {
                                    final normalizedSize =
                                        ShopController.normalizeSize(size);
                                    final isSelected = _selectedSizes.contains(
                                      normalizedSize,
                                    );
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedSizes.remove(
                                              normalizedSize,
                                            );
                                          } else {
                                            _selectedSizes.add(normalizedSize);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? AppColors.primaryAccent
                                                      .withOpacity(0.14)
                                                  : Colors.transparent,
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? AppColors.primaryAccent
                                                    : colorScheme.outline,
                                          ),
                                        ),
                                        child: Text(
                                          size.toUpperCase(),
                                          style: textTheme.bodySmall?.copyWith(
                                            color:
                                                isSelected
                                                    ? AppColors.primaryAccent
                                                    : bodyColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('CANCEL'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            widget.controller.applyFilters(
                              category: _selectedCategory,
                              sizes: _selectedSizes,
                              colors: _selectedColors,
                              minPrice: _selectedMinPrice,
                              maxPrice: _selectedMaxPrice,
                            );
                            Navigator.of(context).pop(_selectedCategory);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryAccent,
                            foregroundColor: AppColors.darkText,
                          ),
                          child: const Text('APPLY'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _safeColor(String hex) {
    try {
      return fromHex(hex);
    } catch (_) {
      return AppColors.slate400;
    }
  }
}

class _ShopSidebar extends StatelessWidget {
  const _ShopSidebar({required this.controller});

  final ShopController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 640;
    final scale =
        isMobile
            ? (width / 390).clamp(0.9, 1.15)
            : (width / 1280).clamp(0.85, 1.2);
    final textTheme = Theme.of(context).textTheme;
    final showPriceRangeSection = controller.categoryItemCount > 1;
    final showColorwaySection = controller.availableColors.isNotEmpty;
    final showSizingSection =
        controller.selectedCategory != allCategoryKey &&
        controller.availableSizes.isNotEmpty;
    final categoryEntries =
        controller.categoryCounts.entries.toList()..sort((a, b) {
          if (a.key == allCategoryKey) {
            return -1;
          }
          if (b.key == allCategoryKey) {
            return 1;
          }
          return a.key.compareTo(b.key);
        });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(label: 'CATEGORIES'),
        SizedBox(height: 8 * scale),
        ...categoryEntries.map((entry) {
          final isSelected = controller.selectedCategory == entry.key;
          return InkWell(
            onTap: () => controller.selectCategory(entry.key),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 3 * scale,
                horizontal: 6 * scale,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ShopController.categoryLabel(entry.key),
                      style: textTheme.bodySmall?.copyWith(
                        color: isSelected ? AppColors.primaryAccent : bodyColor,
                        fontSize: 14 * scale,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.value.toString().padLeft(2, '0')}',
                    style: textTheme.bodySmall?.copyWith(
                      color: isSelected ? AppColors.primaryAccent : bodyColor,
                      fontSize: 14 * scale,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        if (showPriceRangeSection) ...[
          SizedBox(height: 12 * scale),
          Divider(color: theme.dividerColor, height: 1),
          SizedBox(height: 12 * scale),
          _SectionTitle(label: 'PRICE RANGE'),
          SizedBox(height: 10 * scale),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryAccent,
              inactiveTrackColor: colorScheme.outline.withValues(alpha: 0.45),
              thumbColor: AppColors.primaryAccent,
              overlayColor: AppColors.primaryAccent.withOpacity(0.15),
              trackHeight: 2.5,
            ),
            child: RangeSlider(
              values: RangeValues(
                controller.selectedMinPrice,
                controller.selectedMaxPrice,
              ),
              min: controller.minPriceBound,
              max:
                  controller.maxPriceBound == controller.minPriceBound
                      ? controller.minPriceBound + 1
                      : controller.maxPriceBound,
              onChanged:
                  controller.maxPriceBound <= controller.minPriceBound
                      ? null
                      : (values) =>
                          controller.setPriceRange(values.start, values.end),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MetaText('\$${controller.selectedMinPrice.toStringAsFixed(0)}'),
              _MetaText('\$${controller.selectedMaxPrice.toStringAsFixed(0)}+'),
            ],
          ),
        ],
        if (showColorwaySection) ...[
          SizedBox(height: 12 * scale),
          Divider(color: theme.dividerColor, height: 1),
          SizedBox(height: 12 * scale),
          _SectionTitle(label: 'COLORWAY'),
          SizedBox(height: 10 * scale),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                controller.availableColors.map((hex) {
                  final isSelected = controller.selectedColors.contains(hex);
                  return GestureDetector(
                    onTap: () => controller.toggleColor(hex),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _safeColor(hex),
                        border: Border.all(
                          color:
                              isSelected ? AppColors.primaryAccent : bodyColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
        if (showSizingSection) ...[
          SizedBox(height: 12 * scale),
          Divider(color: theme.dividerColor, height: 1),
          SizedBox(height: 12 * scale),
          _SectionTitle(label: 'SIZING'),
          SizedBox(height: 10 * scale),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  controller.availableSizes.map((size) {
                    final isSelected = controller.selectedSizes.contains(
                      ShopController.normalizeSize(size),
                    );
                    return Padding(
                      padding: EdgeInsets.only(right: 6 * scale),
                      child: GestureDetector(
                        onTap: () => controller.toggleSize(size),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12 * scale,
                            vertical: 6 * scale,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.primaryAccent.withOpacity(0.14)
                                    : Colors.transparent,
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColors.primaryAccent
                                      : colorScheme.outline,
                            ),
                          ),
                          child: Text(
                            size.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color:
                                  isSelected
                                      ? AppColors.primaryAccent
                                      : bodyColor,
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Color _safeColor(String hex) {
    try {
      return fromHex(hex);
    } catch (_) {
      return AppColors.slate400;
    }
  }
}

class _ShopPagination extends StatelessWidget {
  const _ShopPagination({required this.controller});

  final ShopController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;
    final pages = _visiblePages(controller.currentPage, controller.totalPages);
    final isDark = theme.brightness == Brightness.dark;
    final metaColor = isDark ? AppColors.slate400 : AppColors.mutedText;

    return Column(
      children: [
        Wrap(
          spacing: 6,
          children: [
            _pageButton(
              context: context,
              label: '<',
              enabled: controller.currentPage > 1,
              onTap: () => controller.goToPage(controller.currentPage - 1),
            ),
            ...pages.map(
              (page) => _pageButton(
                context: context,
                label: '$page',
                enabled: page != controller.currentPage,
                selected: page == controller.currentPage,
                onTap: () => controller.goToPage(page),
              ),
            ),
            _pageButton(
              context: context,
              label: '>',
              enabled: controller.currentPage < controller.totalPages,
              onTap: () => controller.goToPage(controller.currentPage + 1),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'SHOWING ${controller.currentPageItems.length} OF ${controller.totalItemCount} ITEMS',
          style: textTheme.bodySmall?.copyWith(
            color: metaColor,
            fontSize: width < 640 ? 9 : 10,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _pageButton({
    required BuildContext context,
    required String label,
    required bool enabled,
    bool selected = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.slate500 : AppColors.mutedText;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: enabled || selected ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryAccent : Colors.transparent,
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color:
                selected
                    ? AppColors.darkText
                    : (enabled ? bodyColor : mutedColor),
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  List<int> _visiblePages(int current, int total) {
    if (total <= 5) {
      return List<int>.generate(total, (index) => index + 1);
    }

    if (current <= 3) {
      return const [1, 2, 3, 4, 5];
    }

    if (current >= total - 2) {
      return List<int>.generate(5, (index) => total - 4 + index);
    }

    return [current - 2, current - 1, current, current + 1, current + 2];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 640;
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.primaryAccent,
        fontSize: isMobile ? 11 : 14,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Text(
      value,
      style: theme.textTheme.bodySmall?.copyWith(
        color: isDark ? AppColors.darkText : AppColors.lightText,
        fontSize: 14,
      ),
    );
  }
}
