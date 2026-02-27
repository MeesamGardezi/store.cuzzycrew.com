import 'package:cuzzycrewstore/controller/homeController.dart';
import 'package:cuzzycrewstore/model/categoryModel.dart';
import 'package:cuzzycrewstore/model/productModel.dart';
import 'package:cuzzycrewstore/views/widgets/CategoryBox.dart';
import 'package:cuzzycrewstore/views/widgets/ProductBox.dart';
import 'package:flutter/material.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:carousel_text/carousel_text.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return const _HomeMobileLayout();
        } else if (constraints.maxWidth < 1024) {
          return const _HomeTabletLayout();
        } else {
          return const _HomeDesktopLayout();
        }
      },
    );
  }
}

class _HomeDesktopLayout extends StatefulWidget {
  const _HomeDesktopLayout();

  @override
  State<_HomeDesktopLayout> createState() => _HomeDesktopLayoutState();
}

class _HomeDesktopLayoutState extends State<_HomeDesktopLayout> {
  final Homecontroller homeController = Homecontroller();

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                child: SizedBox(
                  width: width,
                  height: height * 0.7,
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          SizedBox(
                            width: width * 0.5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'OFFICIAL 2026 DROP',
                                  style: textTheme.headlineSmall?.copyWith(
                                    color: titleColor,
                                    fontWeight: FontWeight.normal,
                                    fontSize: width * 0.0095,
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'CUZZY\n',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: titleColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: width * 0.05,
                                          height: 1.1,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'CREW STORE',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: bodyColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: width * 0.05,
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: height * 0.015),
                                Container(
                                  padding: const EdgeInsets.only(left: 10),
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
                                      color: bodyColor,
                                      fontSize: width * 0.012,
                                    ),
                                  ),
                                ),
                                SizedBox(height: height * 0.03),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),

                                      decoration: BoxDecoration(
                                        color: AppColors.primaryAccent
                                            .withOpacity(0.1),
                                        border: Border.all(
                                          color: AppColors.primaryAccent,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '12K+',
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.primaryAccent,
                                                  fontSize: width * 0.013,
                                                ),
                                          ),
                                          Text(
                                            'CREW MEMBERS',
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color: bodyColor,
                                                  fontSize: width * 0.01,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: width * 0.02),
                                    //48H AVG delivery
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),

                                      decoration: BoxDecoration(
                                        color: AppColors.primaryAccent
                                            .withOpacity(0.1),
                                        border: Border.all(
                                          color: AppColors.primaryAccent,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '48H',
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.primaryAccent,
                                                  fontSize: width * 0.013,
                                                ),
                                          ),
                                          Text(
                                            'AVG DELIVERY',
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color: bodyColor,
                                                  fontSize: width * 0.01,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: width * 0.02),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),

                                      decoration: BoxDecoration(
                                        color: AppColors.primaryAccent
                                            .withOpacity(0.1),
                                        border: Border.all(
                                          color: AppColors.primaryAccent,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '100%',
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.primaryAccent,
                                                  fontSize: width * 0.013,
                                                ),
                                          ),
                                          Text(
                                            'AUTHENTIC',
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color: bodyColor,
                                                  fontSize: width * 0.01,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: width * 0.05),
                      Expanded(
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Container.png',
                                // fit: BoxFit.contain,
                                width: width * 0.7,
                                height: height * 0.8,
                              ),

                              ElevatedButton(
                                onPressed: () {
                                  // Add button action here
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryAccent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 30,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                ),
                                child: Text(
                                  'SHOP THE DROP',
                                  style: textTheme.bodySmall?.copyWith(
                                    color:
                                        isDark
                                            ? AppColors.lightText
                                            : AppColors.darkText,
                                    fontSize: width * 0.012,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.078),
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
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'FEATURED CATEGORIES',
                        style: textTheme.bodyMedium?.copyWith(
                          color: bodyColor,
                          fontSize: width * 0.013,
                          fontWeight: FontWeight.bold,
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
              SizedBox(height: height * 0.01),
              Container(
                width: width,
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NEW ARRIVALS',
                          style: textTheme.bodyMedium?.copyWith(
                            color: bodyColor,
                            fontSize: width * 0.013,
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

                            final items = _selectNewArrivals(products);
                            return ProductBoxGrid(items: items);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.01),
              Container(
                width: width,
                child: Column(
                  children: [
                    Container(
                      height: height * 0.42,
                      width: width,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _contactInfoBox(
                              context: context,
                              icon: '📸',
                              title: 'Instagram',
                              link: '@sharikh_naveed',
                              description:
                                  'Primary platform. 69.7K followers. Photos, Reels, and Stories driving high engagement with a tight-knit community.',
                            ),
                          ),
                          SizedBox(width: width * 0.015),
                          Expanded(
                            child: _contactInfoBox(
                              context: context,
                              icon: '🔗',
                              title: 'Linktree',
                              link: 'linktr.ee/sharikh_naveed',
                              description:
                                  'All links in one place — follow, collab, and connect through the official hub for everything Sharikh.',
                            ),
                          ),
                          SizedBox(width: width * 0.015),
                          Expanded(
                            child: _contactInfoBox(
                              context: context,
                              icon: '📬',
                              title: 'Inquiries',
                              link: 'email',
                              description:
                                  'For partnerships, collaborations, and business requests, reach out directly via official inquiry contact.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactInfoBox({
    required BuildContext context,
    required String icon,
    required String title,
    required String link,
    required String description,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final width = MediaQuery.of(context).size.width;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$icon  $title',
            style: textTheme.titleMedium?.copyWith(
              color: isDark ? AppColors.darkText : AppColors.lightText,
              fontSize: width * 0.012,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: width * 0.004),
          Text(
            link,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryAccent,
              fontSize: width * 0.010,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: width * 0.006),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.slate400 : AppColors.mutedText,
              fontSize: width * 0.0095,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTabletLayout extends StatefulWidget {
  const _HomeTabletLayout();

  @override
  State<_HomeTabletLayout> createState() => _HomeTabletLayoutState();
}

class _HomeTabletLayoutState extends State<_HomeTabletLayout> {
  final Homecontroller homeController = Homecontroller();

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
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
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
                              fontSize: width * 0.09,
                              height: 1.0,
                            ),
                          ),
                          TextSpan(
                            text: 'CREW STORE',
                            style: textTheme.bodyMedium?.copyWith(
                              color: bodyColor,
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.09,
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
                          color: bodyColor,
                          fontSize: width * 0.017,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
              SizedBox(height: height * 0.025),
              SizedBox(
                width: width,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Container.png',
                      width: width,
                      height: height * 0.40,
                      fit: BoxFit.cover,
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.05,
                          vertical: height * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: Text(
                        'SHOP THE DROP',
                        style: textTheme.bodyMedium?.copyWith(
                          color:
                              isDark ? AppColors.lightText : AppColors.darkText,
                          fontSize: width * 0.018,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.078),
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
                      'JOIN THE CREW FOR EXCLUSIVE DEALS',
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
              Padding(
                padding: const EdgeInsets.all(20),
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
                            final featuredItems =
                                categories.take(4).map((item) {
                                  return CategoryBoxItem(
                                    title: item.name,
                                    thumbnail: item.thumbnail,
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
                        Text(
                          'VIEW ALL',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryAccent,
                            fontSize: width * 0.012,
                            fontWeight: FontWeight.w700,
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
                            final productItems = _selectNewArrivals(products);
                            if (productItems.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              children:
                                  productItems.map((item) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: height * 0.02,
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
              SizedBox(height: height * 0.01),
              Container(
                width: width,
                height: height * 0.32,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/images/Container.png'),
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
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                      fontSize: width * 0.07,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: const [
                    _ContactInfoCard(
                      icon: '📸',
                      title: 'Instagram',
                      link: '@sharikh_naveed',
                      description:
                          'Primary platform. 69.7K followers. Photos, Reels, and Stories driving high engagement with a tight-knit community.',
                    ),
                    SizedBox(height: 12),
                    _ContactInfoCard(
                      icon: '🔗',
                      title: 'Linktree',
                      link: 'linktr.ee/sharikh_naveed',
                      description:
                          'All links in one place — follow, collab, and connect through the official hub for everything Sharikh.',
                    ),
                    SizedBox(height: 12),
                    _ContactInfoCard(
                      icon: '📬',
                      title: 'Inquiries',
                      link: 'email',
                      description:
                          'For partnerships, collaborations, and business requests, reach out directly via official inquiry contact.',
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeMobileLayout extends StatefulWidget {
  const _HomeMobileLayout();

  @override
  State<_HomeMobileLayout> createState() => _HomeMobileLayoutState();
}

class _HomeMobileLayoutState extends State<_HomeMobileLayout> {
  final Homecontroller homeController = Homecontroller();

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
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
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
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'CUZZY\n',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.primaryAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.10,
                              height: 1.0,
                            ),
                          ),
                          TextSpan(
                            text: 'CREW STORE',
                            style: textTheme.bodyMedium?.copyWith(
                              color: bodyColor,
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.10,
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
                          fontSize: width * 0.035,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: width * 0.018,
                  runSpacing: width * 0.018,
                  children: [
                    _InfoStatBox(
                      label: '12K+',
                      value: 'CREW MEMBERS',
                      width: width * 0.45,
                      valueFont: width * 0.028,
                      labelFont: width * 0.023,
                    ),
                    _InfoStatBox(
                      label: '48H',
                      value: 'AVG DELIVERY',
                      width: width * 0.45,
                      valueFont: width * 0.028,
                      labelFont: width * 0.023,
                    ),
                    _InfoStatBox(
                      label: '100%',
                      value: 'AUTHENTIC',
                      width: width * 0.45,
                      valueFont: width * 0.028,
                      labelFont: width * 0.023,
                    ),
                    _InfoStatBox(
                      label: 'Material',
                      value: '100% Cotton',
                      width: width * 0.45,
                      valueFont: width * 0.028,
                      labelFont: width * 0.023,
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.02),
              SizedBox(
                width: width,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Container.png',
                      width: width,
                      height: height * 0.32,
                      fit: BoxFit.cover,
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.07,
                          vertical: height * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: Text(
                        'SHOP THE DROP',
                        style: textTheme.bodyMedium?.copyWith(
                          color:
                              isDark ? AppColors.lightText : AppColors.darkText,
                          fontSize: width * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.02),
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
              Padding(
                padding: const EdgeInsets.all(16),
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
                            final featuredItems =
                                categories.take(4).map((item) {
                                  return CategoryBoxItem(
                                    title: item.name,
                                    thumbnail: item.thumbnail,
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
                        Text(
                          'VIEW ALL',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryAccent,
                            fontSize: width * 0.024,
                            fontWeight: FontWeight.w700,
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
                            final productItems = _selectNewArrivals(products);
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
              SizedBox(height: height * 0.01),
              Container(
                width: width,
                height: height * 0.28,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/images/Container.png'),
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
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                      fontSize: width * 0.09,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: const [
                    _ContactInfoCard(
                      icon: '📸',
                      title: 'Instagram',
                      link: '@sharikh_naveed',
                      description:
                          'Primary platform. 69.7K followers. Photos, Reels, and Stories driving high engagement with a tight-knit community.',
                    ),
                    SizedBox(height: 12),
                    _ContactInfoCard(
                      icon: '🔗',
                      title: 'Linktree',
                      link: 'linktr.ee/sharikh_naveed',
                      description:
                          'All links in one place — follow, collab, and connect through the official hub for everything Sharikh.',
                    ),
                    SizedBox(height: 12),
                    _ContactInfoCard(
                      icon: '📬',
                      title: 'Inquiries',
                      link: 'email',
                      description:
                          'For partnerships, collaborations, and business requests, reach out directly via official inquiry contact.',
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.02),
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
        color: AppColors.primaryAccent.withOpacity(0.1),
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
    final bool isMobile = width < 640;
    final bool isTablet = width >= 640 && width < 1024;
    final double radius = isMobile ? 8 : (isTablet ? 10 : 12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: AspectRatio(
            aspectRatio: 1.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Image.asset(product.thumbnail, fit: BoxFit.cover),
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
          '\$${product.price.toStringAsFixed(2)}',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.primaryAccent,
            fontSize: width * 0.026,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

List<ProductModel> _selectNewArrivals(
  List<ProductModel> products, {
  int maxItems = 4,
}) {
  final sorted = [...products]
    ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

  final recent = sorted.where((item) => item.isNewArrival).toList();
  final source = recent.isNotEmpty ? recent : sorted;

  return source.take(maxItems).toList();
}

class _ContactInfoCard extends StatelessWidget {
  const _ContactInfoCard({
    required this.icon,
    required this.title,
    required this.link,
    required this.description,
  });

  final String icon;
  final String title;
  final String link;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final width = MediaQuery.of(context).size.width;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$icon  $title',
            style: textTheme.titleMedium?.copyWith(
              color: isDark ? AppColors.darkText : AppColors.lightText,
              fontSize: width * 0.030,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: width * 0.01),
          Text(
            link,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryAccent,
              fontSize: width * 0.028,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: width * 0.012),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.slate400 : AppColors.mutedText,
              fontSize: width * 0.024,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
