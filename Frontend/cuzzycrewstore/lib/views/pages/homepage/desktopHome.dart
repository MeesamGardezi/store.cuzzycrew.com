import 'dart:async';
import 'dart:convert';

import 'package:cuzzycrewstore/controller/homeController.dart';
import 'package:cuzzycrewstore/navigation/core/navWrapperController.dart';
import 'package:cuzzycrewstore/model/categoryModel.dart';
import 'package:cuzzycrewstore/model/productModel.dart';
import 'package:cuzzycrewstore/views/widgets/CategoryBox.dart';
import 'package:cuzzycrewstore/views/widgets/ProductBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:carousel_text/carousel_text.dart';

class HomeDesktopLayout extends StatefulWidget {
  const HomeDesktopLayout();

  @override
  State<HomeDesktopLayout> createState() => HomeDesktopLayoutState();
}

class HomeDesktopLayoutState extends State<HomeDesktopLayout> {
  final Homecontroller homeController = Homecontroller();
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;

  List<String> _bannerImages = const ['assets/images/Container.png'];
  int _currentBanner = 0;

  @override
  void initState() {
    super.initState();
    _loadBannerImages();
  }

  Future<void> _loadBannerImages() async {
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
        _bannerImages = banners;
        _currentBanner = 0;
      });

      _startBannerAutoSlide();
    } catch (_) {
      _startBannerAutoSlide();
    }
  }

  void _startBannerAutoSlide() {
    _bannerTimer?.cancel();
    if (_bannerImages.length <= 1) {
      return;
    }

    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_bannerController.hasClients) {
        return;
      }

      final nextPage = (_currentBanner + 1) % _bannerImages.length;
      _bannerController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = AppColors.primaryAccent;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;
    final heroHeight = height * 0.87;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        left: false,
        right: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: width,
                height: heroHeight,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _bannerController,
                      itemCount: _bannerImages.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentBanner = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Opacity(
                          opacity:
                              theme.brightness == Brightness.dark ? 0.8 : 1.0,
                          child: Image.asset(
                            _bannerImages[index],
                            fit: BoxFit.cover,
                            width: width,
                            height: heroHeight,
                          ),
                        );
                      },
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppColors.darkBase.withOpacity(0.78),
                              AppColors.darkBase.withOpacity(0.35),
                              AppColors.darkBase.withOpacity(0.15),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.darkBase.withOpacity(0.35),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.06,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: width * 0.46,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'OFFICIAL 2026 DROP',
                                  style: textTheme.headlineSmall?.copyWith(
                                    color: titleColor,
                                    fontWeight: FontWeight.normal,
                                    fontSize: width * 0.0095,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'CUZZY\n',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: titleColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize: width * 0.05,
                                          height: 1.05,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'CREW STORE',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: AppColors.darkText,
                                          fontWeight: FontWeight.w900,
                                          fontSize: width * 0.05,
                                          height: 1.05,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: height * 0.02),
                                Container(
                                  padding: const EdgeInsets.only(left: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: titleColor,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'PREMIUM STREETWEAR FOR THE CREW.',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.darkText,
                                      fontSize: width * 0.0115,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: height * 0.03),
                          Wrap(
                            spacing: width * 0.012,
                            runSpacing: width * 0.012,
                            children: [
                              _desktopHeroStat(
                                context,
                                value: '12K+',
                                label: 'CREW MEMBERS',
                                width: width,
                              ),
                              _desktopHeroStat(
                                context,
                                value: '48H',
                                label: 'AVG DELIVERY',
                                width: width,
                              ),
                              _desktopHeroStat(
                                context,
                                value: '100%',
                                label: 'AUTHENTIC',
                                width: width,
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.028),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {     NavWrapperController.selectedIndex.value = 1;},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryAccent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 34,
                                    vertical: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                ),
                                child: Text(
                                  'SHOP THE DROP',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.darkText,
                                    fontSize: width * 0.0105,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              SizedBox(width: width * 0.02),
                              Row(
                                children: List.generate(
                                  _bannerImages.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.only(right: 8),
                                    width: _currentBanner == index ? 22 : 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color:
                                          _currentBanner == index
                                              ? AppColors.primaryAccent
                                              : AppColors.darkText.withOpacity(
                                                0.5,
                                              ),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                      'JOIN THE CREW FOR EXCLUSIVE DEALS',
                    ],

                    animationType: AnimationType.typing,

                    fixedTextStyle: textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.lightText : AppColors.darkText,
                      fontSize: width * 0.01,
                      fontWeight: FontWeight.bold,
                    ),
                    rotatingTextStyle: textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.lightText : AppColors.darkText,
                      fontSize: width * 0.01,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.01),
              Container(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 30),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'FEATURED CATEGORIES',
                        style: textTheme.bodyMedium?.copyWith(
                          color: bodyColor,
                          fontSize: width * 0.014,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    ValueListenableBuilder<bool>(
                      valueListenable: homeController.isLoading,
                      builder: (context, isLoading, _) {
                        if (isLoading) {
                          return SizedBox(
                            height: height * 0.22,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        return ValueListenableBuilder<List<CategoryModel>>(
                          valueListenable: homeController.categories,
                          builder: (context, categories, _) {
                            if (categories.isEmpty) {
                              return SizedBox(
                                height: height * 0.12,
                                child: Center(
                                  child: Text(
                                    'No categories found',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: bodyColor,
                                      fontSize: width * 0.011,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final featuredItems =
                                categories.take(4).map((item) {
                                  return CategoryBoxItem(
                                    title: item.name,
                                    thumbnail: item.thumbnail,
                                    launched: item.launched,
                                    onTap:
                                        () =>
                                            NavWrapperController.openShopWithCategory(
                                              item.slug,
                                            ),
                                  );
                                }).toList();

                            return CategoryBoxGrid(
                              items: featuredItems,
                              horizontalPadding: 0,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.0),
              Container(
                width: width,
                padding: const EdgeInsets.only(left: 30, right: 30, top: 0, bottom: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NEW ARRIVALS',
                          style: textTheme.bodyMedium?.copyWith(
                            color: bodyColor,
                            fontSize: width * 0.014,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'VIEW ALL',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryAccent,
                            fontSize: width * 0.008,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    ValueListenableBuilder<bool>(
                      valueListenable: homeController.isProductsLoading,
                      builder: (context, isProductsLoading, _) {
                        if (isProductsLoading) {
                          return SizedBox(
                            height: height * 0.22,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        return ValueListenableBuilder<List<ProductModel>>(
                          valueListenable: homeController.products,
                          builder: (context, products, _) {
                            if (products.isEmpty) {
                              return SizedBox(
                                height: height * 0.1,
                                child: Center(
                                  child: Text(
                                    'No products found',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: bodyColor,
                                      fontSize: width * 0.01,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final items = products.take(4).toList();
                            return ProductBoxGrid(items: items);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.02),
              SafeArea(
                left: false,
                right: false,
                top: false,
                bottom: false,
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Container(
                        height: height * 0.42,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: const AssetImage(
                              'assets/images/Container.png',
                            ),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              isDark
                                  ? AppColors.darkBase.withOpacity(0.45)
                                  : AppColors.lightSurface.withOpacity(0.20),
                              BlendMode.srcATop,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'JOIN THE CREW',
                            style: textTheme.headlineMedium?.copyWith(
                              color:
                                  isDark
                                      ? AppColors.darkText
                                      : AppColors.lightText,
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _desktopHeroStat(
    BuildContext context, {
    required String value,
    required String label,
    required double width,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.45),
        border: Border.all(color: AppColors.primaryAccent, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.primaryAccent,
              fontSize: width * 0.0125,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.darkText,
              fontSize: width * 0.0095,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
