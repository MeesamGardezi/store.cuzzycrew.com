import 'package:cuzzycrewstore/controller/cartController.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:cuzzycrewstore/utils/helper.dart';
import 'package:cuzzycrewstore/views/pages/cartpage/cartPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuzzycrewstore/controller/productDetailController.dart';
import 'package:cuzzycrewstore/model/productModel.dart';

class ProductDetailMobileLayout extends StatefulWidget {
  const ProductDetailMobileLayout({required this.product, super.key});

  final ProductModel product;

  @override
  State<ProductDetailMobileLayout> createState() =>
      _ProductDetailMobileLayoutState();
}

class _ProductDetailMobileLayoutState extends State<ProductDetailMobileLayout> {
  late PageController _pageController;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final scale = (width / 375).clamp(0.85, 1.15);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<CartController>(
            builder: (context, cartController, _) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12,top : 4),
                    child:
                      Center(
                        child: IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, size: 28),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CartPage()),
                            );
                          },
                        ),
                      ),
                    
                  ),

                  if (cartController.itemCount > 0)
                    Positioned(
                      top: 12,
                      right: 13,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${cartController.itemCount}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
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
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 8 * scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Gallery
              SizedBox(
                height: 320 * scale,
                child: Consumer<ProductDetailController>(
                  builder: (context, controller, _) {
                    final images = controller.aggregatedImages;
                    if (images.isEmpty) {
                      return Container(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48 * scale,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      );
                    }
                    return PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (idx) {
                        setState(() {
                          _selectedImageIndex = idx;
                        });
                      },
                      itemBuilder: (context, idx) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12 * scale),
                          child: Image.network(images[idx], fit: BoxFit.cover),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 12 * scale),

              // Thumbnail Indicators
              Consumer<ProductDetailController>(
                builder: (context, controller, _) {
                  final images = controller.aggregatedImages;
                  if (images.length <= 1) return SizedBox.shrink();
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        images.length,
                        (idx) => GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              idx,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                            setState(() {
                              _selectedImageIndex = idx;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 8 * scale),
                            width: 56 * scale,
                            height: 56 * scale,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    _selectedImageIndex == idx
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                width: 2 * scale,
                              ),
                              borderRadius: BorderRadius.circular(8 * scale),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6 * scale),
                              child: Image.network(
                                images[idx],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24 * scale),

              // Product Name & Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 24 * scale,
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
                          fontSize: 22 * scale,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (widget.product.isNewArrival)
                        Padding(
                          padding: EdgeInsets.only(left: 12 * scale),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8 * scale,
                              vertical: 4 * scale,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(4 * scale),
                            ),
                            child: Text(
                              'NEW',
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(
                                fontSize: 10 * scale,
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
                ],
              ),
              SizedBox(height: 20 * scale),

              // Color Variants
              if (widget.product.colorVariants.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Color',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    Consumer<ProductDetailController>(
                      builder: (context, controller, _) {
                        return Wrap(
                          spacing: 12 * scale,
                          runSpacing: 12 * scale,
                          children:
                              widget.product.colorVariants.map((variant) {
                                final isSelected =
                                    controller.selectedColorHex ==
                                    variant.colorHex.toLowerCase();
                                return GestureDetector(
                                  onTap: () {
                                    controller.selectColor(variant.colorHex);
                                    setState(() {
                                      _selectedImageIndex = 0;
                                      _pageController.jumpToPage(0);
                                    });
                                  },
                                  child: Container(
                                    width: 48 * scale,
                                    height: 48 * scale,
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
                                                ).colorScheme.primary
                                                : Colors.grey.shade400,
                                        width:
                                            isSelected ? 3 * scale : 1 * scale,
                                      ),
                                    ),
                                    child:
                                        isSelected
                                            ? Icon(
                                              Icons.check,
                                              color:
                                                  variant.colorHex
                                                              .toLowerCase() ==
                                                          '#000000'
                                                      ? Colors.white
                                                      : Colors.black,
                                              size: 20 * scale,
                                            )
                                            : null,
                                  ),
                                );
                              }).toList(),
                        );
                      },
                    ),
                    SizedBox(height: 20 * scale),
                  ],
                ),

              // Sizes
              if (widget.product.sizes.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Size',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.product.sizeGuideImage.isNotEmpty)
                          GestureDetector(
                            onTap: () => _showSizeGuideDialog(context, scale),
                            child: Text(
                              'Size Guide',
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(
                                fontSize: 11 * scale,
                                color: AppColors.primaryAccent,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primaryAccent,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12 * scale),
                    Consumer<ProductDetailController>(
                      builder: (context, controller, _) {
                        return Wrap(
                          spacing: 10 * scale,
                          runSpacing: 10 * scale,
                          children:
                              widget.product.sizes.map((size) {
                                final isSelected =
                                    controller.selectedSize == size;
                                return GestureDetector(
                                  onTap: () => controller.selectSize(size),
                                  child: Container(
                                    width:
                                        size != 'ONE SIZE'
                                            ? 72 * scale
                                            : 90 * scale,
                                    height: 40 * scale,
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(
                                        6 * scale,
                                      ),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                                : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        size,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          fontSize:
                                              size != 'ONE SIZE'
                                                  ? 14 * scale
                                                  : 12 * scale,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isSelected
                                                  ? Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary
                                                  : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        );
                      },
                    ),
                    SizedBox(height: 20 * scale),
                  ],
                ),

              // Quantity
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quantity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  Consumer<ProductDetailController>(
                    builder: (context, controller, _) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6 * scale),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              iconSize: 20 * scale,
                              onPressed: controller.decrementQuantity,
                              color:
                                  theme.brightness == Brightness.dark
                                      ? AppColors.darkText
                                      : AppColors.lightText,
                            ),
                            SizedBox(
                              width: 40 * scale,
                              child: Center(
                                child: Text(
                                  '${controller.quantity}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14 * scale,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              iconSize: 20 * scale,
                              onPressed: controller.incrementQuantity,
                              color:
                                  theme.brightness == Brightness.dark
                                      ? AppColors.darkText
                                      : AppColors.lightText,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24 * scale),
                ],
              ),

              // Description
              if (widget.product.story?.isNotEmpty == true)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The Story',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    Text(
                      widget.product.story!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13 * scale,
                        height: 1.6,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 24 * scale),
                  ],
                ),

              // Add to Cart Button
              SizedBox(
                width: double.infinity,
                height: 48 * scale,
                child: FilledButton(
                  onPressed:
                      widget.product.availableUnits <= 0
                          ? null
                          : () {
                            final productDetailController =
                                Provider.of<ProductDetailController>(
                                  context,
                                  listen: false,
                                );
                            final cartController = Provider.of<CartController>(
                              context,
                              listen: false,
                            );

                            cartController.addToCart(
                              product: widget.product,
                              selectedColorHex:
                                  productDetailController.selectedColorHex,
                              selectedSize:
                                  productDetailController.selectedSize,
                              quantity: productDetailController.quantity,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${widget.product.name} added to cart!',
                                ),
                                duration: const Duration(milliseconds: 1500),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        widget.product.availableUnits <= 0
                            ? AppColors.darkText
                            : Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                  ),
                  child: Text(
                    widget.product.availableUnits <= 0
                        ? 'OUT OF STOCK'
                        : 'Add to Cart',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 15 * scale,
                      color:
                          widget.product.availableUnits <= 0
                              ? (Brightness.dark == theme.brightness
                                  ? AppColors.darkText
                                  : AppColors.lightText)
                              : null,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24 * scale),
            ],
          ),
        ),
      ),
    );
  }

  void _showSizeGuideDialog(BuildContext context, double scale) {
    final width = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            'Size Guide',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 18 * scale),
          ),
          content: SingleChildScrollView(
            child:
                widget.product.sizeGuideImage.isNotEmpty
                    ? Image.network(
                      widget.product.sizeGuideImage,
                      width: (width * 0.8).clamp(250, 400),
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
