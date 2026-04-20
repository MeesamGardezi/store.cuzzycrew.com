import 'package:cuzzycrewstore/controller/cartController.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:cuzzycrewstore/utils/design_utils.dart';
import 'package:cuzzycrewstore/utils/helper.dart';
import 'package:cuzzycrewstore/views/pages/checkoutpage/checkoutPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartTabletLayout extends StatelessWidget {
  const CartTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 768).clamp(0.95, 1.1);

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
            fontSize: 22,
            letterSpacing: 1.4,
          ),
        ),
        centerTitle: true,
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
                    size: 80,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: textTheme.bodyMedium?.copyWith(
                      color: bodyColor,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(24 * scale),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cart Items
                Expanded(
                  flex: 2,
                  child: Column(
                    children:
                        controller.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _CartItemCard(
                              item: item,
                              controller: controller,
                              isDark: isDark,
                            ),
                          );
                        }).toList(),
                  ),
                ),
                SizedBox(width: 24 * scale),
                // Order Summary Sidebar
                Expanded(
                  child: _OrderSummarySidebar(
                    controller: controller,
                    isDark: isDark,
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
  });

  final dynamic item;
  final CartController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      padding: const EdgeInsets.all(16),
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
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.zero,
              image: DecorationImage(
                image: NetworkImage(item.product.primaryImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: textTheme.titleMedium?.copyWith(
                    color: bodyColor,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _SpecTag(
                      label: 'Size: ${item.selectedSize}',
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
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
                const SizedBox(height: 12),
                _QuantityControl(
                  item: item,
                  controller: controller,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent10,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Text(
                    'REMOVE',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.primaryAccent,
                      fontSize: 11,
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
  const _SpecTag({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
        borderRadius: BorderRadius.zero,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 11),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.item,
    required this.controller,
    required this.isDark,
  });

  final dynamic item;
  final CartController controller;
  final bool isDark;

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
        children: [
          GestureDetector(
            onTap: () {
              if (item.quantity > 1) {
                controller.updateQuantity(item.id, item.quantity - 1);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                '−',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${item.quantity}',
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          GestureDetector(
            onTap: () {
              controller.updateQuantity(item.id, item.quantity + 1);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                '+',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
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
    required this.onCheckout,
  });

  final CartController controller;
  final bool isDark;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      padding: const EdgeInsets.all(20),
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
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...controller.items.map((item) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${item.product.name} *${item.quantity}',
                        style: textTheme.bodySmall?.copyWith(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatPrice(
                        item.totalPrice,
                        currencyCode: item.product.currency,
                      ),
                      style: textTheme.bodyMedium?.copyWith(
                        color: bodyColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),
          Container(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          const SizedBox(height: 12),

          Container(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: textTheme.titleMedium?.copyWith(
                  color: bodyColor,
                  fontSize: 14,
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
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: AppColors.darkText,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            onPressed: onCheckout,
            child: Text(
              'PROCEED TO CHECKOUT',
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

Color fromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
