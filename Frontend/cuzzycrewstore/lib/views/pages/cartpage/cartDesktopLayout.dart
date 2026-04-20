import 'package:cuzzycrewstore/controller/cartController.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:cuzzycrewstore/utils/design_utils.dart';
import 'package:cuzzycrewstore/utils/helper.dart';
import 'package:cuzzycrewstore/views/pages/checkoutpage/checkoutPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartDesktopLayout extends StatelessWidget {
  const CartDesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 1280).clamp(0.852, 1.2);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: DesignUtils.topBarHeight,
        titleSpacing: 0,
        shape: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.5,
          ),
        ),
        leading: IconButton(
          style: DesignUtils.topBarIconButtonStyle(isDark: isDark),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'YOUR CART',
          style: DesignUtils.topBarTitleStyle(
            isDark: isDark,
            fontSize: 24,
            letterSpacing: 1.4,
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<CartController>(
        builder: (context, controller, _) {
          if (controller.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your cart is empty',
                    style: textTheme.bodyMedium?.copyWith(
                      color: bodyColor,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(32 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cart Items
                      Expanded(
                        flex: 3,
                        child: Column(
                          children:
                              controller.items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: _CartItemCard(
                                    item: item,
                                    controller: controller,
                                    isDark: isDark,
                                    scale: scale,
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                      SizedBox(width: 40 * scale),
                      // Order Summary Sidebar
                      SizedBox(
                        width: 320 * scale,
                        child: _OrderSummarySidebar(
                          controller: controller,
                          isDark: isDark,
                          scale: scale,
                          onCheckout: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => CheckoutPage(
                                      cartData: controller.getCartData(),
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.controller,
    required this.isDark,
    required this.scale,
  });

  final dynamic item;
  final CartController controller;
  final bool isDark;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 160 * scale,
            height: 160 * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.zero,
              image: DecorationImage(
                image: NetworkImage(item.product.primaryImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 20 * scale),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: textTheme.titleMedium?.copyWith(
                    color: bodyColor,
                    fontSize: 18 * scale,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12 * scale),
                Row(
                  children: [
                    _SpecTag(
                      label: 'Size: ${item.selectedSize}',
                      isDark: isDark,
                      scale: scale,
                    ),
                    SizedBox(width: 12 * scale),
                    Row(
                      children: [
                        Container(
                          width: 24 * scale,
                          height: 24 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _hexToColor(item.selectedColor),
                            border: Border.all(
                              color:
                                  isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16 * scale),
                _QuantityControl(
                  item: item,
                  controller: controller,
                  isDark: isDark,
                  scale: scale,
                ),
              ],
            ),
          ),
          SizedBox(width: 20 * scale),
          // Price and Remove
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatPrice(
                  item.priceAtAddTime,
                  currencyCode: item.product.currency,
                ),
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryAccent,
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12 * scale),
              GestureDetector(
                onTap: () {
                  controller.removeFromCart(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Item removed from cart'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale,
                    vertical: 8 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent10,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Text(
                    'REMOVE',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.primaryAccent,
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hexString) {
    try {
      return fromHex(hexString);
    } catch (_) {
      return AppColors.slate400;
    }
  }
}

class _SpecTag extends StatelessWidget {
  const _SpecTag({
    required this.label,
    required this.isDark,
    required this.scale,
  });

  final String label;
  final bool isDark;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
        borderRadius: BorderRadius.zero,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontSize: 11 * scale),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.item,
    required this.controller,
    required this.isDark,
    required this.scale,
  });

  final dynamic item;
  final CartController controller;
  final bool isDark;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (item.quantity > 1) {
                controller.updateQuantity(item.id, item.quantity - 1);
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10 * scale,
                vertical: 8 * scale,
              ),
              child: Text(
                '−',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24 * scale,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
            child: Text(
              '${item.quantity}',
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24 * scale,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          GestureDetector(
            onTap: () {
              controller.updateQuantity(item.id, item.quantity + 1);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10 * scale,
                vertical: 8 * scale,
              ),
              child: Text(
                '+',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummarySidebar extends StatelessWidget {
  const _OrderSummarySidebar({
    required this.controller,
    required this.isDark,
    required this.scale,
    required this.onCheckout,
  });

  final CartController controller;
  final bool isDark;
  final double scale;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ORDER SUMMARY',
            style: textTheme.titleMedium?.copyWith(
              color: bodyColor,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16 * scale),
          ...controller.items.map((item) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${item.product.name} * ${item.quantity}',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11 * scale,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      formatPrice(
                        item.totalPrice,
                        currencyCode: item.product.currency,
                      ),
                      style: textTheme.bodyMedium?.copyWith(
                        color: bodyColor,
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * scale),
              ],
            );
          }).toList(),

          Container(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          SizedBox(height: 16 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: textTheme.titleMedium?.copyWith(
                  color: bodyColor,
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                formatPrice(
                  controller.total,
                  currencyCode: controller.displayCurrency,
                ),
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryAccent,
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * scale),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: AppColors.darkText,
              padding: EdgeInsets.symmetric(vertical: 14 * scale),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            onPressed: onCheckout,
            child: Text(
              'PROCEED TO CHECKOUT',
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.w700,
                fontSize: 9.5 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
