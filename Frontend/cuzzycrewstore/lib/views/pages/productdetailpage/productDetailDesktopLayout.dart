import 'package:cuzzycrewstore/controller/cartController.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:cuzzycrewstore/utils/design_utils.dart';
import 'package:cuzzycrewstore/utils/helper.dart';
import 'package:cuzzycrewstore/views/pages/cartpage/cartPage.dart';
import 'package:cuzzycrewstore/views/widgets/adaptive_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuzzycrewstore/controller/productDetailController.dart';
import 'package:cuzzycrewstore/model/productModel.dart';

class ProductDetailDesktopLayout extends StatefulWidget {
  const ProductDetailDesktopLayout({required this.product, super.key});

  final ProductModel product;

  @override
  State<ProductDetailDesktopLayout> createState() =>
      _ProductDetailDesktopLayoutState();
}

class _ProductDetailDesktopLayoutState
    extends State<ProductDetailDesktopLayout> {
  int _selectedImageIndex = 0;

  bool _isColorDark(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    if (cleaned.length < 6) return false;

    final r = int.parse(cleaned.substring(0, 2), radix: 16);
    final g = int.parse(cleaned.substring(2, 4), radix: 16);
    final b = int.parse(cleaned.substring(4, 6), radix: 16);
    final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    return luminance < 0.5;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final baseWidth = width > 1440 ? 1440.0 : 1280.0;
    final scale = (width / baseWidth).clamp(0.85, 1.2);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final actionIconSize = DesignUtils.topBarActionIconSize(width);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        toolbarHeight: DesignUtils.topBarHeight,
        titleSpacing: 0,
        leadingWidth: 56,
        shape: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.5,
          ),
        ),
        leading: IconButton(
          iconSize: actionIconSize,
          style: DesignUtils.topBarIconButtonStyle(isDark: isDark),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.product.name,
          style: DesignUtils.topBarTitleStyle(
            isDark: isDark,
            fontSize: 18 * scale,
            letterSpacing: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Consumer<CartController>(
            builder: (context, cartController, _) {
              return Center(
                child: Stack(
                  children: [
                    IconButton(
                      iconSize: actionIconSize,
                      style: DesignUtils.topBarIconButtonStyle(isDark: isDark),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartPage()),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_outlined),
                    ),
                    if (cartController.itemCount > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 17,
                          height: 17,
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${cartController.itemCount}',
                                textAlign: TextAlign.center,
                                style: Theme.of(
                                  context,
                                ).textTheme.labelSmall?.copyWith(
                                  color: AppColors.darkText,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9 * scale,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          SizedBox(width: 12 * scale),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24 * scale,
            vertical: 16 * scale,
          ),
          child: Consumer<ProductDetailController>(
            builder: (context, controller, _) {
              final images = controller.aggregatedImages;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT: Sidebar Thumbnails
                  if (images.isNotEmpty)
                    SizedBox(
                      width: 90 * scale,
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: images.length,
                        separatorBuilder:
                            (_, __) => SizedBox(height: 8 * scale),
                        itemBuilder: (context, idx) {
                          final isSelected = _selectedImageIndex == idx;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImageIndex = idx;
                              });
                            },
                            child: Container(
                              height: 80 * scale,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Colors.transparent,
                                  width: 3 * scale,
                                ),
                                borderRadius: BorderRadius.zero,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.zero,
                                child: AdaptiveImage(
                                  source: images[idx],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  SizedBox(width: 24 * scale),

                  // CENTER: Main Image
                  if (images.isNotEmpty)
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 500 * scale,
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? AppColors.darkSurfaceAlt
                                  : AppColors.slate50,
                          borderRadius: BorderRadius.zero,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.zero,
                          child: AdaptiveImage(
                            source: images[_selectedImageIndex],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(width: 32 * scale),

                  // RIGHT: Product Details
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name & Price
                          Text(
                            widget.product.name,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              fontSize: 28 * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                          Row(
                            children: [
                              Text(
                                formatPrice(
                                  widget.product.price,
                                  currencyCode: widget.product.currency,
                                ),
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  fontSize: 26 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              if (widget.product.isNewArrival)
                                Padding(
                                  padding: EdgeInsets.only(left: 16 * scale),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10 * scale,
                                      vertical: 5 * scale,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    child: Text(
                                      'NEW ARRIVAL',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall?.copyWith(
                                        fontSize: 11 * scale,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 16 * scale),

                          // Color Variants
                          if (widget.product.colorVariants.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Color',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 12 * scale),
                                Consumer<ProductDetailController>(
                                  builder: (context, controller, _) {
                                    return Wrap(
                                      spacing: 16 * scale,
                                      runSpacing: 12 * scale,
                                      children:
                                          widget.product.colorVariants.map((
                                            variant,
                                          ) {
                                            final isSelected =
                                                controller.selectedColorHex ==
                                                variant.colorHex.toLowerCase();
                                            return GestureDetector(
                                              onTap: () {
                                                controller.selectColor(
                                                  variant.colorHex,
                                                );
                                                setState(() {
                                                  _selectedImageIndex = 0;
                                                });
                                              },
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 56 * scale,
                                                    height: 56 * scale,
                                                    decoration: BoxDecoration(
                                                      color: Color(
                                                        int.parse(
                                                          '0xFF${variant.colorHex.replaceFirst('#', '')}',
                                                        ),
                                                      ),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color:
                                                            isSelected
                                                                ? Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primary
                                                                : (isDark
                                                                    ? AppColors
                                                                        .darkBorder
                                                                    : AppColors
                                                                        .lightBorder),
                                                        width:
                                                            isSelected
                                                                ? 3 * scale
                                                                : 1.5 * scale,
                                                      ),
                                                    ),
                                                    child:
                                                        isSelected
                                                            ? Icon(
                                                              Icons.check,
                                                              color:
                                                                  _isColorDark(
                                                                        variant
                                                                            .colorHex,
                                                                      )
                                                                      ? Colors
                                                                          .white
                                                                      : AppColors
                                                                          .ink950,
                                                              size: 24 * scale,
                                                            )
                                                            : null,
                                                  ),
                                                  SizedBox(height: 8 * scale),
                                                  Text(
                                                    variant.colorName,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall
                                                        ?.copyWith(
                                                          fontSize: 12 * scale,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                    );
                                  },
                                ),
                                SizedBox(height: 28 * scale),
                              ],
                            ),

                          // Sizes
                          if (widget.product.sizes.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Size',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontSize: 16 * scale,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (widget
                                        .product
                                        .sizeGuideImage
                                        .isNotEmpty)
                                      GestureDetector(
                                        onTap:
                                            () => _showSizeGuideDialog(
                                              context,
                                              widget.product,
                                              scale,
                                            ),
                                        child: Text(
                                          'Size Guide',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelSmall?.copyWith(
                                            fontSize: 12 * scale,
                                            color: AppColors.primaryAccent,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                AppColors.primaryAccent,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 12 * scale),
                                Consumer<ProductDetailController>(
                                  builder: (context, controller, _) {
                                    return Wrap(
                                      spacing: 12 * scale,
                                      runSpacing: 12 * scale,
                                      children:
                                          widget.product.sizes.map((size) {
                                            final isSelected =
                                                controller.selectedSize == size;
                                            return GestureDetector(
                                              onTap:
                                                  () => controller.selectSize(
                                                    size,
                                                  ),
                                              child: Container(
                                                width: 72 * scale,
                                                height: 50 * scale,
                                                decoration: BoxDecoration(
                                                  color:
                                                      isSelected
                                                          ? Theme.of(
                                                            context,
                                                          ).colorScheme.primary
                                                          : (isDark
                                                              ? AppColors
                                                                  .darkSurfaceAlt
                                                              : AppColors
                                                                  .slate50),
                                                  borderRadius:
                                                      BorderRadius.zero,
                                                  border: Border.all(
                                                    color:
                                                        isSelected
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                            : (isDark
                                                                ? AppColors
                                                                    .darkBorder
                                                                : AppColors
                                                                    .lightBorder),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    size,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          fontSize:
                                                              size != 'ONE SIZE'
                                                                  ? 15 * scale
                                                                  : 12 * scale,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              theme.brightness ==
                                                                      Brightness
                                                                          .dark
                                                                  ? AppColors
                                                                      .darkText
                                                                  : AppColors
                                                                      .lightText,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    );
                                  },
                                ),
                                SizedBox(height: 28 * scale),
                              ],
                            ),

                          // Quantity
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quantity',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 12 * scale),
                              Consumer<ProductDetailController>(
                                builder: (context, controller, _) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            isDark
                                                ? AppColors.darkBorder
                                                : AppColors.lightBorder,
                                      ),
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          iconSize: 22 * scale,
                                          onPressed:
                                              controller.decrementQuantity,
                                          color:
                                              theme.brightness ==
                                                      Brightness.dark
                                                  ? AppColors.darkText
                                                  : AppColors.lightText,
                                        ),
                                        SizedBox(
                                          width: 50 * scale,
                                          child: Center(
                                            child: Text(
                                              '${controller.quantity}',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.copyWith(
                                                fontSize: 16 * scale,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          iconSize: 22 * scale,
                                          onPressed:
                                              controller.incrementQuantity,
                                          color:
                                              theme.brightness ==
                                                      Brightness.dark
                                                  ? AppColors.darkText
                                                  : AppColors.lightText,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 28 * scale),
                            ],
                          ),

                          // Story Section
                          if (widget.product.story?.isNotEmpty == true)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'The Story',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 12 * scale),
                                Text(
                                  widget.product.story!,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    fontSize: 14 * scale,
                                    height: 1.6,
                                    color:
                                        isDark
                                            ? AppColors.slate400
                                            : AppColors.mutedText,
                                  ),
                                ),
                                SizedBox(height: 28 * scale),
                              ],
                            ),

                          // Add to Cart Button
                          SizedBox(
                            width: double.infinity,
                            height: 54 * scale,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    widget.product.availableUnits <= 0
                                        ? (isDark
                                            ? AppColors.darkSurfaceAlt
                                            : AppColors.slate50)
                                        : Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(fontSize: 16 * scale),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              onPressed:
                                  widget.product.availableUnits <= 0
                                      ? null
                                      : () {
                                        final productDetailController =
                                            Provider.of<
                                              ProductDetailController
                                            >(context, listen: false);
                                        final cartController =
                                            Provider.of<CartController>(
                                              context,
                                              listen: false,
                                            );

                                        cartController.addToCart(
                                          product: widget.product,
                                          selectedColorHex:
                                              productDetailController
                                                  .selectedColorHex,
                                          selectedSize:
                                              productDetailController
                                                  .selectedSize,
                                          quantity:
                                              productDetailController.quantity,
                                        );

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${widget.product.name} added to cart!',
                                            ),
                                            duration: const Duration(
                                              milliseconds: 1500,
                                            ),
                                            backgroundColor:
                                                AppColors.semanticSuccess,
                                          ),
                                        );
                                      },
                              child: Text(
                                widget.product.availableUnits <= 0
                                    ? 'OUT OF STOCK'
                                    : 'Add to Cart',
                                style: Theme.of(
                                  context,
                                ).textTheme.labelLarge?.copyWith(
                                  fontSize: 16 * scale,
                                  color:
                                      widget.product.availableUnits <= 0
                                          ? (isDark
                                              ? AppColors.slate400
                                              : AppColors.mutedText)
                                          : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSizeGuideDialog(
    BuildContext context,
    ProductModel product,
    double scale,
  ) {
    final width = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            'Size Guide',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 20 * scale),
          ),
          content: SingleChildScrollView(
            child:
                product.sizeGuideImage.isNotEmpty
                    ? SizedBox(
                      width: (width * 0.6).clamp(300, 600),
                      child: AdaptiveImage(
                        source: product.sizeGuideImage,
                        fit: BoxFit.contain,
                      ),
                    )
                    : Text(
                      'No size guide available',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
