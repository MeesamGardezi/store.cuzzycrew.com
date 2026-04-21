import 'package:cuzzycrewstore/model/orderModel.dart';
import 'package:cuzzycrewstore/navigation/core/navWrapperController.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:cuzzycrewstore/utils/design_utils.dart';
import 'package:cuzzycrewstore/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 640;
    final isTablet = width >= 640 && width < 1024;
    final maxCardWidth = isMobile ? width : (isTablet ? 680.0 : 760.0);
    final sectionPadding = isMobile ? 16.0 : (isTablet ? 22.0 : 24.0);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
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
          style: DesignUtils.topBarIconButtonStyle(isDark: isDark),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ORDER STATUS',
          style: DesignUtils.topBarTitleStyle(
            isDark: isDark,
            fontSize: isMobile ? 18 : (isTablet ? 20 : 22),
            letterSpacing: 1.4,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(sectionPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxCardWidth),
            child: Container(
              padding: EdgeInsets.all(sectionPadding),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.zero,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: isMobile ? 86 : 96,
                    color: AppColors.primaryAccent,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Payment Successful',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: bodyColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your order has been placed successfully.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: bodyColor,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _OrderSummaryCard(order: order),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      foregroundColor: AppColors.darkText,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () {
                      NavWrapperController.selectedIndex.value = 1;
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Text(
                      'CONTINUE SHOPPING',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORDER SUMMARY',
            style: theme.textTheme.titleMedium?.copyWith(
              color: bodyColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _OrderIdRow(orderId: order.id),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Total Paid',
            value: formatPrice(order.total, currencyCode: order.currency),
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: bodyColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: highlight ? AppColors.primaryAccent : bodyColor,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _OrderIdRow extends StatelessWidget {
  const _OrderIdRow({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Order ID',
                style: theme.textTheme.bodySmall?.copyWith(color: bodyColor),
              ),
            ),
            IconButton(
              tooltip: 'Copy order ID',
              visualDensity: VisualDensity.compact,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: orderId));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order ID copied to clipboard')),
                );
              },
              icon: Icon(
                Icons.copy_rounded,
                size: 18,
                color: isDark ? AppColors.amber300 : AppColors.ink700,
              ),
            ),
          ],
        ),
        SelectableText(
          orderId,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: bodyColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
