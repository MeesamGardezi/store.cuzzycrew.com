import 'dart:convert';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, dynamic> cartData;

  const CheckoutPage({super.key, required this.cartData});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late TextEditingController _cartDataController;

  @override
  void initState() {
    super.initState();
    _cartDataController = TextEditingController(
      text: JsonEncoder.withIndent('  ').convert(widget.cartData),
    );
  }

  @override
  void dispose() {
    _cartDataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 640;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CHECKOUT',
          style: textTheme.headlineSmall?.copyWith(
            color: bodyColor,
            fontSize: isMobile ? 18 : 22,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child:
            isMobile
                ? _buildMobileLayout(context, isDark, bodyColor)
                : _buildDesktopLayout(context, isDark, bodyColor),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    bool isDark,
    Color bodyColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCheckoutSteps(isDark, bodyColor),
        const SizedBox(height: 24),
        _buildOrderReviewSection(isDark, bodyColor),
        const SizedBox(height: 24),
        _buildShippingForm(isDark, bodyColor),
        const SizedBox(height: 24),
        _buildPaymentForm(isDark, bodyColor),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
            foregroundColor: AppColors.darkText,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onPressed: () {
            _showPlaceOrderDialog(context);
          },
          child: Text(
            'PLACE ORDER',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.darkText,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    bool isDark,
    Color bodyColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Form
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCheckoutSteps(isDark, bodyColor),
              const SizedBox(height: 32),
              _buildShippingForm(isDark, bodyColor),
              const SizedBox(height: 32),
              _buildPaymentForm(isDark, bodyColor),
            ],
          ),
        ),
        const SizedBox(width: 32),
        // Right: Order Review
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOrderReviewSection(isDark, bodyColor),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  foregroundColor: AppColors.darkText,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () {
                  _showPlaceOrderDialog(context);
                },
                child: Text(
                  'PLACE ORDER',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutSteps(bool isDark, Color bodyColor) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          _buildStepIndicator(1, 'Cart', true, isDark),
          Container(height: 2, width: 20, color: AppColors.primaryAccent),
          _buildStepIndicator(2, 'Shipping', true, isDark),
          Container(height: 2, width: 20, color: AppColors.primaryAccent),
          _buildStepIndicator(3, 'Payment', true, isDark),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    int number,
    String label,
    bool isActive,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isActive
                    ? AppColors.primaryAccent
                    : (isDark
                        ? AppColors.darkSurfaceAlt
                        : AppColors.lightSurfaceAlt),
          ),
          child: Center(
            child: Text(
              '$number',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isActive ? AppColors.darkText : AppColors.slate500,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderReviewSection(bool isDark, Color bodyColor) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORDER REVIEW',
            style: textTheme.titleMedium?.copyWith(
              color: bodyColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cart Items:',
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.darkBackground : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: TextField(
              controller: _cartDataController,
              maxLines: 10,
              readOnly: true,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontFamily: 'monospace',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\$${(widget.cartData['total'] as num).toStringAsFixed(2)}',
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingForm(bool isDark, Color bodyColor) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SHIPPING ADDRESS',
            style: textTheme.titleMedium?.copyWith(
              color: bodyColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Full Name', isDark),
          const SizedBox(height: 12),
          _buildTextField('Email Address', isDark),
          const SizedBox(height: 12),
          _buildTextField('Phone Number', isDark),
          const SizedBox(height: 12),
          _buildTextField('Street Address', isDark),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField('City', isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField('State', isDark)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField('ZIP Code', isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField('Country', isDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm(bool isDark, Color bodyColor) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PAYMENT INFORMATION',
            style: textTheme.titleMedium?.copyWith(
              color: bodyColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Card Number', isDark),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField('MM/YY', isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField('CVC', isDark)),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField('Cardholder Name', isDark),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, bool isDark) {
    final theme = Theme.of(context);
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;

    return TextField(
      style: theme.textTheme.bodySmall?.copyWith(color: bodyColor),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: theme.textTheme.bodySmall?.copyWith(
          color: isDark ? AppColors.slate500 : AppColors.mutedText,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.primaryAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }

  void _showPlaceOrderDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                isDark ? AppColors.darkSurface : AppColors.lightSurface,
            title: Text(
              'Confirm Order',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            content: Text(
              'This is a template. Order processing will be integrated with the backend.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Order template submitted. Backend API needed.',
                      ),
                    ),
                  );
                },
                child: const Text('Place Order'),
              ),
            ],
          ),
    );
  }
}
