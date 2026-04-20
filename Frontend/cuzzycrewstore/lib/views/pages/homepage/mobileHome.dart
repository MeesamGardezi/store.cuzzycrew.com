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

class HomeMobileLayout extends StatefulWidget {
  const HomeMobileLayout();

  @override
  State<HomeMobileLayout> createState() => HomeMobileLayoutState();
}

class HomeMobileLayoutState extends State<HomeMobileLayout> {
  final Homecontroller homeController = Homecontroller();
  final PageController _mobileBannerController = PageController();
  Timer? _mobileBannerTimer;

  List<String> _mobileBannerImages = const ['assets/images/Container.png'];
  int _currentMobileBanner = 0;

  @override
  void initState() {
    super.initState();
    _loadMobileBannerImages();
  }

  Future<void> _loadMobileBannerImages() async {
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
        _mobileBannerImages = banners;
        _currentMobileBanner = 0;
      });

      _startMobileBannerAutoSlide();
    } catch (_) {
      _startMobileBannerAutoSlide();
    }
  }

  void _startMobileBannerAutoSlide() {
    _mobileBannerTimer?.cancel();
    if (_mobileBannerImages.length <= 1) {
      return;
    }

    _mobileBannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_mobileBannerController.hasClients) {
        return;
      }

      final nextPage = (_currentMobileBanner + 1) % _mobileBannerImages.length;
      _mobileBannerController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _mobileBannerTimer?.cancel();
    _mobileBannerController.dispose();
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: pagePadding,
                  top: 12,
                  right: pagePadding,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OFFICIAL 2026 DROP',
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.normal,
                        fontSize: width * 0.025,
                      ),
                    ),
                    SizedBox(height: width * 0.012),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'CUZZY\n',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.primaryAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.092,
                              height: 1.0,
                            ),
                          ),
                          TextSpan(
                            text: 'CREW STORE',
                            style: textTheme.bodyMedium?.copyWith(
                              color: bodyColor,
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.092,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.012),
                    Container(
                      padding: const EdgeInsets.only(left: 8),
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
                          color: bodyColor,
                          fontSize: width * 0.033,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: Builder(
                  builder: (context) {
                    final spacing = MediaQuery.of(context).size.width * 0.017;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: spacing / 2),
                                child: _InfoStatBox(
                                  label: '12K+',
                                  value: 'CREW MEMBERS',
                                  width: double.infinity,
                                  valueFont: width * 0.028,
                                  labelFont: width * 0.023,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: spacing / 2),
                                child: _InfoStatBox(
                                  label: '48H',
                                  value: 'AVG DELIVERY',
                                  width: double.infinity,
                                  valueFont: width * 0.028,
                                  labelFont: width * 0.023,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.01),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: spacing / 2),
                                child: _InfoStatBox(
                                  label: '100%',
                                  value: 'AUTHENTIC',
                                  width: double.infinity,
                                  valueFont: width * 0.028,
                                  labelFont: width * 0.023,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: spacing / 2),
                                child: _InfoStatBox(
                                  label: 'Material',
                                  value: '100% Cotton',
                                  width: double.infinity,
                                  valueFont: width * 0.028,
                                  labelFont: width * 0.023,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: height * 0.02),
              SizedBox(
                width: width,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: width,
                      height: height * 0.32,
                      child: PageView.builder(
                        controller: _mobileBannerController,
                        itemCount: _mobileBannerImages.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentMobileBanner = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Image.asset(
                            _mobileBannerImages[index],
                            width: width,
                            height: height * 0.32,
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
                          horizontal: width * 0.07,
                          vertical: height * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text(
                        'SHOP THE DROP',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkText,
                          fontSize: width * 0.03,
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
                height: height * 0.05,
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
                      fontSize: width * 0.03,
                      fontWeight: FontWeight.bold,
                    ),
                    rotatingTextStyle: textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.lightText : AppColors.darkText,
                      fontSize: width * 0.03,
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
                          fontSize: width * 0.045,
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
                            height: height * 0.16,
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
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
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
                    SizedBox(height: height * 0.018),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NEW ARRIVALS',
                          style: textTheme.bodyMedium?.copyWith(
                            color: bodyColor,
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => NavWrapperController.setSelectedIndex(1),
                          child: Text(
                            'VIEW ALL',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryAccent,
                              fontSize: width * 0.024,
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
                            final productItems = (products);
                            if (productItems.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              children:
                                  productItems.map((item) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: height * 0.018,
                                      ),
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
              const StoreFooter(),
            ],
          ),
        ),
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
          SizedBox(height: width * 0.017),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkText : AppColors.lightText,
              fontSize: width * 0.028,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: width * 0.004),
          Text(
            formatPrice(product.price, currencyCode: product.currency),
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryAccent,
              fontSize: width * 0.032,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
