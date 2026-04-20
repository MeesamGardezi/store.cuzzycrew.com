import 'dart:async';
import 'dart:convert';

import 'package:cuzzycrewstore/controller/homeController.dart';
import 'package:cuzzycrewstore/navigation/core/navWrapperController.dart';
import 'package:cuzzycrewstore/model/categoryModel.dart';
import 'package:cuzzycrewstore/model/productModel.dart';
import 'package:cuzzycrewstore/views/pages/productdetailpage/productDetailPage.dart';
import 'package:cuzzycrewstore/views/widgets/adaptive_image.dart';
import 'package:cuzzycrewstore/views/widgets/CategoryBox.dart';
import 'package:cuzzycrewstore/views/widgets/store_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:cuzzycrewstore/utils/design_utils.dart';
import 'package:cuzzycrewstore/utils/helper.dart';
import 'package:carousel_text/carousel_text.dart';

class HomeTabletLayout extends StatefulWidget {
  const HomeTabletLayout();

  @override
  State<HomeTabletLayout> createState() => HomeTabletLayoutState();
}

class HomeTabletLayoutState extends State<HomeTabletLayout> {
  final Homecontroller homeController = Homecontroller();
  final PageController _tabletBannerController = PageController();
  Timer? _tabletBannerTimer;

  List<String> _tabletBannerImages = const ['assets/images/Container.png'];
  int _currentTabletBanner = 0;

  @override
  void initState() {
    super.initState();
    _loadTabletBannerImages();
  }

  Future<void> _loadTabletBannerImages() async {
    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = jsonDecode(manifestJson);

      final banners =
          manifest.keys
              .where((key) => key.startsWith('assets/images/banner-images/'))
              .where(
                (key) =>
                    key.endsWith('.png') ||
                    key.endsWith('.jpg') ||
                    key.endsWith('.jpeg') ||
                    key.endsWith('.webp'),
              )
              .toList()
            ..sort();

      if (!mounted || banners.isEmpty) {
        return;
      }

      setState(() {
        _tabletBannerImages = banners;
        _currentTabletBanner = 0;
      });

      _startTabletBannerAutoSlide();
    } catch (_) {
      _startTabletBannerAutoSlide();
    }
  }

  void _startTabletBannerAutoSlide() {
    _tabletBannerTimer?.cancel();
    if (_tabletBannerImages.length <= 1) {
      return;
    }

    _tabletBannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_tabletBannerController.hasClients) {
        return;
      }

      final nextPage = (_currentTabletBanner + 1) % _tabletBannerImages.length;
      _tabletBannerController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _tabletBannerTimer?.cancel();
    _tabletBannerController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if ((homeController.categories.value.isEmpty ||
            homeController.products.value.isEmpty) &&
        !homeController.isLoading.value &&
        !homeController.isProductsLoading.value) {
      homeController.onInit(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final pagePadding = DesignUtils.pagePadding(width).horizontal / 2;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        left: false,
        right: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OFFICIAL 2026 DROP',
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.normal,
                        fontSize: width * 0.015,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'CUZZY\n',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.primaryAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.082,
                              height: 1.0,
                            ),
                          ),
                          TextSpan(
                            text: 'CREW STORE',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.darkText,
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.082,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.012),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: AppColors.primaryAccent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        'PREMIUM STREETWEAR FOR THE CREW.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkText,
                          fontSize: width * 0.016,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: Wrap(
                  spacing: width * 0.015,
                  runSpacing: width * 0.015,
                  children: [
                    _InfoStatBox(
                      label: '12K+',
                      value: 'CREW MEMBERS',
                      width: width * 0.28,
                      valueFont: width * 0.015,
                      labelFont: width * 0.013,
                    ),
                    _InfoStatBox(
                      label: '48H',
                      value: 'AVG DELIVERY',
                      width: width * 0.28,
                      valueFont: width * 0.015,
                      labelFont: width * 0.013,
                    ),
                    _InfoStatBox(
                      label: '100%',
                      value: 'AUTHENTIC',
                      width: width * 0.28,
                      valueFont: width * 0.015,
                      labelFont: width * 0.013,
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.03),
              SizedBox(
                width: width,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: width,
                      height: height * 0.40,
                      child: PageView.builder(
                        controller: _tabletBannerController,
                        itemCount: _tabletBannerImages.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentTabletBanner = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Image.asset(
                            _tabletBannerImages[index],
                            width: width,
                            height: height * 0.40,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        NavWrapperController.selectedIndex.value = 1;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.05,
                          vertical: height * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text(
                        'SHOP THE DROP',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkText,
                          fontSize: width * 0.018,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // SizedBox(height: height * 0.02),
              Container(
                width: width,
                height: height * 0.055,
                color: AppColors.primaryAccent,
                child: Center(
                  child: CarouselText(
                    fixedText: 'CUZZYCREW STORE -',
                    rotatingWords: [
                      'FREE SHIPPING ON ALL ORDERS',
                      'NEW ARRIVALS DROPPING WEEKLY',
                      'LIMITED DROPS. FAST SELL-OUTS.',
                    ],
                    animationType: AnimationType.typing,
                    fixedTextStyle: textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.lightText : AppColors.darkText,
                      fontSize: width * 0.02,
                      fontWeight: FontWeight.bold,
                    ),
                    rotatingTextStyle: textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.lightText : AppColors.darkText,
                      fontSize: width * 0.02,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              Padding(
                padding: EdgeInsets.all(pagePadding),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'FEATURED CATEGORIES',
                        style: textTheme.bodyMedium?.copyWith(
                          color: bodyColor,
                          fontSize: width * 0.02,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.015),
                    ValueListenableBuilder<bool>(
                      valueListenable: homeController.isLoading,
                      builder: (context, isLoading, _) {
                        if (isLoading) {
                          return SizedBox(
                            height: height * 0.18,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        return ValueListenableBuilder<List<CategoryModel>>(
                          valueListenable: homeController.categories,
                          builder: (context, categories, _) {
                            return ValueListenableBuilder<List<ProductModel>>(
                              valueListenable: homeController.products,
                              builder: (context, products, __) {
                                String normalize(String value) =>
                                    value.trim().toLowerCase();

                                final featuredItems =
                                    categories.take(4).map((item) {
                                      final categorySlug = normalize(item.slug);
                                      final categoryName = normalize(item.name);
                                      final hasProducts = products.any((
                                        product,
                                      ) {
                                        final productCategory = normalize(
                                          product.category,
                                        );
                                        return productCategory ==
                                                categorySlug ||
                                            productCategory == categoryName;
                                      });
                                      final canOpen =
                                          item.launched && hasProducts;

                                      return CategoryBoxItem(
                                        title: item.name,
                                        thumbnail: item.thumbnail,
                                        launched: canOpen,
                                        onTap:
                                            canOpen
                                                ? () =>
                                                    NavWrapperController.openShopWithCategory(
                                                      item.slug,
                                                    )
                                                : null,
                                      );
                                    }).toList();

                                if (featuredItems.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: featuredItems.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 0.8,
                                      ),
                                  itemBuilder: (context, index) {
                                    final item = featuredItems[index];
                                    return CategoryBox(
                                      title: item.title,
                                      thumbnail: item.thumbnail,
                                      launched: item.launched,
                                      onTap: item.onTap,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NEW ARRIVALS',
                          style: textTheme.bodyMedium?.copyWith(
                            color: bodyColor,
                            fontSize: width * 0.02,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => NavWrapperController.setSelectedIndex(1),
                          child: Text(
                            'VIEW ALL',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryAccent,
                              fontSize: width * 0.012,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primaryAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.015),
                    ValueListenableBuilder<bool>(
                      valueListenable: homeController.isProductsLoading,
                      builder: (context, isProductsLoading, _) {
                        if (isProductsLoading) {
                          return SizedBox(
                            height: height * 0.2,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        return ValueListenableBuilder<List<ProductModel>>(
                          valueListenable: homeController.products,
                          builder: (context, products, _) {
                            final productItems = products;
                            if (productItems.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Wrap(
                              spacing: width * 0.02,
                              runSpacing: height * 0.02,
                              children:
                                  productItems.map((item) {
                                    return SizedBox(
                                      width:
                                          (width - (20 * 3)) /
                                          2, // 2 per row with spacing
                                      child: _VerticalProductCard(
                                        product: item,
                                      ),
                                    );
                                  }).toList(),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.02),
              SizedBox(height: height * 0.02),
              const StoreFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerticalProductCard extends StatelessWidget {
  const _VerticalProductCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final width = MediaQuery.of(context).size.width;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: AspectRatio(
              aspectRatio: 1.2,
              child: ClipRRect(
                borderRadius: BorderRadius.zero,
                child: AdaptiveImage(
                  source: product.primaryImage,
                  fit: BoxFit.cover,
                  fallback: Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: width * 0.012),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkText : AppColors.lightText,
              fontSize: width * 0.022,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: width * 0.005),
          Text(
            formatPrice(product.price, currencyCode: product.currency),
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryAccent,
              fontSize: width * 0.026,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoStatBox extends StatelessWidget {
  const _InfoStatBox({
    required this.label,
    required this.value,
    required this.width,
    required this.valueFont,
    required this.labelFont,
  });

  final String label;
  final String value;
  final double width;
  final double valueFont;
  final double labelFont;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.primaryAccent, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.primaryAccent,
              fontSize: valueFont,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.darkText : AppColors.lightText,
              fontSize: labelFont,
            ),
          ),
        ],
      ),
    );
  }
}
