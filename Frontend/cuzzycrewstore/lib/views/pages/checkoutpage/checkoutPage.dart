import 'dart:async';
import 'dart:convert';
import 'package:cuzzycrewstore/controller/cartController.dart';
import 'package:cuzzycrewstore/controller/orderController.dart';
import 'package:cuzzycrewstore/model/orderModel.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:cuzzycrewstore/utils/design_utils.dart';
import 'package:cuzzycrewstore/utils/helper.dart';
import 'package:cuzzycrewstore/views/pages/orderpage/orderFailurePage.dart';
import 'package:cuzzycrewstore/views/pages/orderpage/orderSuccessPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, dynamic> cartData;

  const CheckoutPage({super.key, required this.cartData});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const String _draftConsentKey =
      'checkout_shipping_autosave_consent_v1';
  static const String _draftDataKey = 'checkout_shipping_autosave_data_v1';

  final GlobalKey<FormState> _shippingFormKey = GlobalKey<FormState>();
  late TextEditingController _cartDataController;
  late final OrderController _orderController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _zipController;
  late final TextEditingController _countryController;
  bool _isPlacingOrder = false;
  bool _submittedOnce = false;
  bool _allowDraftAutosave = false;
  SharedPreferences? _prefs;
  Timer? _draftDebounceTimer;

  List<_CheckoutLineItem> get _lineItems {
    final rawItems = widget.cartData['items'] as List<dynamic>? ?? <dynamic>[];

    return rawItems.map((rawItem) {
      final item = rawItem as Map<String, dynamic>? ?? <String, dynamic>{};
      final product =
          item['product'] as Map<String, dynamic>? ?? <String, dynamic>{};

      final name =
          item['name']?.toString().trim().isNotEmpty == true
              ? item['name'].toString().trim()
              : (item['productName']?.toString().trim().isNotEmpty == true
                  ? item['productName'].toString().trim()
                  : (product['name']?.toString().trim().isNotEmpty == true
                      ? product['name'].toString().trim()
                      : (product['shortName']?.toString().trim().isNotEmpty ==
                              true
                          ? product['shortName'].toString().trim()
                          : 'Item')));

      final quantity = ((item['quantity'] as num?)?.toInt() ?? 1).clamp(
        1,
        9999,
      );

      final currency =
          item['currency']?.toString().trim().isNotEmpty == true
              ? item['currency'].toString().trim()
              : (product['currency']?.toString().trim().isNotEmpty == true
                  ? product['currency'].toString().trim()
                  : (widget.cartData['currency']
                              ?.toString()
                              .trim()
                              .isNotEmpty ==
                          true
                      ? widget.cartData['currency'].toString().trim()
                      : 'USD'));

      final unitPrice =
          (item['priceAtAddTime'] as num?)?.toDouble() ??
          (item['pricePerItem'] as num?)?.toDouble() ??
          (item['unitPrice'] as num?)?.toDouble() ??
          (item['price'] as num?)?.toDouble() ??
          (product['price'] as num?)?.toDouble() ??
          0.0;

      final lineTotal =
          (item['totalPrice'] as num?)?.toDouble() ?? (unitPrice * quantity);

      return _CheckoutLineItem(
        name: name,
        currency: currency,
        quantity: quantity,
        unitPrice: unitPrice,
        lineTotal: lineTotal,
      );
    }).toList();
  }

  String get _displayCurrency {
    final payloadCurrency = widget.cartData['currency']?.toString();
    if (payloadCurrency != null && payloadCurrency.trim().isNotEmpty) {
      return payloadCurrency.trim();
    }

    if (_lineItems.isNotEmpty) {
      return _lineItems.first.currency;
    }

    return 'USD';
  }

  double get _displayTotal {
    final fromPayload = (widget.cartData['total'] as num?)?.toDouble();
    if (fromPayload != null && fromPayload > 0) {
      return fromPayload;
    }

    return _lineItems.fold<double>(0.0, (sum, item) => sum + item.lineTotal);
  }

  @override
  void initState() {
    super.initState();
    _orderController = OrderController();
    _cartDataController = TextEditingController(
      text: JsonEncoder.withIndent('  ').convert(widget.cartData),
    );
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _streetController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _zipController = TextEditingController();
    _countryController = TextEditingController();

    _bindDraftListeners();
    _initializeDraftPersistence();
  }

  @override
  void dispose() {
    _draftDebounceTimer?.cancel();
    _cartDataController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _bindDraftListeners() {
    final listeners = [
      _fullNameController,
      _emailController,
      _phoneController,
      _streetController,
      _cityController,
      _stateController,
      _zipController,
      _countryController,
    ];

    for (final controller in listeners) {
      controller.addListener(_handleDraftFieldChanged);
    }
  }

  Future<void> _initializeDraftPersistence() async {
    _prefs = await SharedPreferences.getInstance();
    final existingConsent = _prefs!.getBool(_draftConsentKey);

    if (existingConsent == true) {
      if (!mounted) return;
      setState(() {
        _allowDraftAutosave = true;
      });
      _restoreDraftFromPrefs();
      return;
    }

    if (existingConsent == false || !mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final accepted = await _showDraftConsentDialog();
      if (!mounted) return;

      await _prefs?.setBool(_draftConsentKey, accepted);
      if (accepted) {
        setState(() {
          _allowDraftAutosave = true;
        });
        _restoreDraftFromPrefs();
        _queueDraftPersist();
      }
    });
  }

  Future<bool> _showDraftConsentDialog() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surfaceColor,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(
            'Save Checkout Details?',
            style: DesignUtils.topBarTitleStyle(isDark: isDark, fontSize: 28),
          ),
          content: Text(
            'We can auto-save your shipping details on this device for faster checkout next time. You can still edit everything any time.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text('No Thanks'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: AppColors.darkText,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text('Yes, Save'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _restoreDraftFromPrefs() {
    final raw = _prefs?.getString(_draftDataKey);
    if (raw == null || raw.trim().isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _fullNameController.text = (decoded['fullName'] as String?) ?? '';
      _emailController.text = (decoded['email'] as String?) ?? '';
      _phoneController.text = (decoded['phone'] as String?) ?? '';
      _streetController.text = (decoded['street'] as String?) ?? '';
      _cityController.text = (decoded['city'] as String?) ?? '';
      _stateController.text = (decoded['state'] as String?) ?? '';
      _zipController.text = (decoded['zipCode'] as String?) ?? '';
      _countryController.text = (decoded['country'] as String?) ?? '';
    } catch (_) {
      _prefs?.remove(_draftDataKey);
    }
  }

  void _handleDraftFieldChanged() {
    if (!_allowDraftAutosave) {
      return;
    }
    _queueDraftPersist();
  }

  void _queueDraftPersist() {
    _draftDebounceTimer?.cancel();
    _draftDebounceTimer = Timer(const Duration(milliseconds: 250), () async {
      if (!_allowDraftAutosave) {
        return;
      }

      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _prefs = prefs;
      final payload = {
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'street': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zipCode': _zipController.text.trim(),
        'country': _countryController.text.trim().toUpperCase(),
      };
      await prefs.setString(_draftDataKey, jsonEncode(payload));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final mediaSize = MediaQuery.of(context).size;
    final width = mediaSize.width;
    final height = mediaSize.height;
    final isMobile = width < 640;
    final isTablet = width >= 640 && width < 1024;
    final referenceWidth = isMobile ? 390.0 : (isTablet ? 834.0 : 1280.0);
    final referenceHeight = isMobile ? 844.0 : (isTablet ? 1112.0 : 900.0);
    final widthScale = (width / referenceWidth).clamp(0.85, 1.35);
    final heightScale = (height / referenceHeight).clamp(0.85, 1.25);
    final scale = ((widthScale * 0.65) + (heightScale * 0.35)).clamp(0.85, 1.3);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: surfaceColor,
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
          'CHECKOUT',
          style: DesignUtils.topBarTitleStyle(
            isDark: isDark,
            fontSize: (isMobile ? 18 : (isTablet ? 20 : 22)) * scale,
            letterSpacing: 1.4,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(
              (isMobile ? 16 : (isTablet ? 20 : 24)) * scale,
            ),
            child:
                isMobile
                    ? _buildMobileLayout(context, isDark, bodyColor, scale)
                    : isTablet
                    ? _buildTabletLayout(context, isDark, bodyColor, scale)
                    : _buildDesktopLayout(context, isDark, bodyColor, scale),
          ),
          if (_isPlacingOrder)
            Container(
              color: AppColors.ink950.withValues(alpha: 0.22),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    bool isDark,
    Color bodyColor,
    double scale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildOrderReviewSection(isDark, bodyColor, scale),
        SizedBox(height: 24 * scale),
        _buildShippingForm(isDark, bodyColor, scale),

        SizedBox(height: 24 * scale),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
            foregroundColor: AppColors.darkText,
            padding: EdgeInsets.symmetric(vertical: 14 * scale),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          onPressed: _isPlacingOrder ? null : () => _onPlaceOrder(context),
          child: Text(
            'PLACE ORDER',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.darkText,
              fontWeight: FontWeight.w700,
              fontSize: 12 * scale,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    bool isDark,
    Color bodyColor,
    double scale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildOrderReviewSection(isDark, bodyColor, scale),
        SizedBox(height: 28 * scale),
        _buildShippingForm(isDark, bodyColor, scale),

        SizedBox(height: 28 * scale),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
            foregroundColor: AppColors.darkText,
            padding: EdgeInsets.symmetric(vertical: 15 * scale),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          onPressed: _isPlacingOrder ? null : () => _onPlaceOrder(context),
          child: Text(
            'PLACE ORDER',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.darkText,
              fontWeight: FontWeight.w700,
              fontSize: 12 * scale,
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
    double scale,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Form
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_buildShippingForm(isDark, bodyColor, scale)],
          ),
        ),
        SizedBox(width: 32 * scale),
        // Right: Order Review
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOrderReviewSection(isDark, bodyColor, scale),
              SizedBox(height: 24 * scale),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  foregroundColor: AppColors.darkText,
                  padding: EdgeInsets.symmetric(vertical: 16 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed:
                    _isPlacingOrder ? null : () => _onPlaceOrder(context),
                child: Text(
                  'PLACE ORDER',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12 * scale,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderReviewSection(bool isDark, Color bodyColor, double scale) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORDER REVIEW',
            style: textTheme.titleMedium?.copyWith(
              color: bodyColor,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16 * scale),
          Text(
            'Cart Items:',
            style: textTheme.titleSmall?.copyWith(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12 * scale),
          Container(
            padding: const EdgeInsets.only(bottom: 8.0),

            //summary box
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  _lineItems.isEmpty
                      ? [
                        Text(
                          'No items in cart',
                          style: textTheme.titleSmall?.copyWith(
                            fontSize: 11 * scale,
                            fontFamily: 'monospace',
                            color: bodyColor,
                          ),
                        ),
                      ]
                      : _lineItems
                          .map(
                            (item) => Row(
                              children: [
                                Text(
                                  '${item.name} x${item.quantity} ',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontSize: 10 * scale,
                                    fontFamily: 'monospace',
                                    color: bodyColor,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  formatPrice(
                                    item.lineTotal,
                                    currencyCode: item.currency,
                                  ),
                                  style: textTheme.titleSmall?.copyWith(
                                    fontSize: 10 * scale,
                                    fontFamily: 'monospace',
                                    color: bodyColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList()
                          .asMap()
                          .entries
                          .expand(
                            (entry) => [
                              entry.value,
                              if (entry.key < _lineItems.length - 1)
                                SizedBox(height: 8 * scale),
                            ],
                          )
                          .toList(),
            ),

            // child: TextField(
            //   controller: _cartDataController,
            //   maxLines: 10,
            //   readOnly: true,
            //   style: textTheme.bodySmall?.copyWith(
            //     fontSize: 11,
            //     fontFamily: 'monospace',
            //   ),
            //   decoration: InputDecoration(
            //     border: InputBorder.none,
            //     contentPadding: EdgeInsets.zero,
            //   ),
            // ),
          ),
          SizedBox(height: 16 * scale),
          Container(
            height: 1 * scale,
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
                formatPrice(_displayTotal, currencyCode: _displayCurrency),
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryAccent,
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingForm(bool isDark, Color bodyColor, double scale) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Form(
      key: _shippingFormKey,
      autovalidateMode:
          _submittedOnce
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
      child: Container(
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.zero,
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
                fontSize: 14 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16 * scale),
            _buildTextField('Full Name', isDark, scale, _fullNameController),
            SizedBox(height: 12 * scale),
            _buildTextField('Email Address', isDark, scale, _emailController),
            SizedBox(height: 12 * scale),
            _buildTextField('Phone Number', isDark, scale, _phoneController),
            SizedBox(height: 12 * scale),
            _buildTextField('Street Address', isDark, scale, _streetController),
            SizedBox(height: 12 * scale),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'City',
                    isDark,
                    scale,
                    _cityController,
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: _buildTextField(
                    'State',
                    isDark,
                    scale,
                    _stateController,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * scale),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'ZIP Code',
                    isDark,
                    scale,
                    _zipController,
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: _buildTextField(
                    'Country Code',
                    isDark,
                    scale,
                    _countryController,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    bool isDark,
    double scale,
    TextEditingController controller,
  ) {
    final theme = Theme.of(context);
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;

    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      keyboardType: _keyboardTypeForLabel(label),
      textCapitalization:
          label == 'Country Code'
              ? TextCapitalization.characters
              : TextCapitalization.none,
      inputFormatters:
          label == 'Country Code'
              ? [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]'))]
              : null,
      maxLength: label == 'Country Code' ? 2 : null,
      style: theme.textTheme.bodySmall?.copyWith(
        color: bodyColor,
        fontSize: 12 * scale,
      ),
      decoration: InputDecoration(
        hintText: label,
        helperText: _helperTextForLabel(label),
        hintStyle: theme.textTheme.bodySmall?.copyWith(
          color: isDark ? AppColors.slate500 : AppColors.mutedText,
          fontSize: 12 * scale,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(color: AppColors.primaryAccent),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12 * scale,
          vertical: 10 * scale,
        ),
      ),
      validator: (value) => _validateShippingField(label, value),
    );
  }

  TextInputType _keyboardTypeForLabel(String label) {
    switch (label) {
      case 'Email Address':
        return TextInputType.emailAddress;
      case 'Phone Number':
        return TextInputType.phone;
      case 'ZIP Code':
        return TextInputType.streetAddress;
      case 'Country Code':
        return TextInputType.text;
      default:
        return TextInputType.text;
    }
  }

  String _helperTextForLabel(String label) {
    switch (label) {
      case 'Full Name':
        return 'Use the name for the shipping label.';
      case 'Email Address':
        return 'Receipt and order updates.';
      case 'Phone Number':
        return 'Include country code if needed.';
      case 'Street Address':
        return 'House number, street, area.';
      case 'City':
        return 'Delivery city.';
      case 'State':
        return 'Province or state.';
      case 'ZIP Code':
        return 'Postal code.';
      case 'Country Code':
        return '2-letter ISO code, for example US.';
      default:
        return '';
    }
  }

  String? _validateShippingField(String label, String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '$label is required.';
    }

    switch (label) {
      case 'Email Address':
        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed)) {
          return 'Enter a valid email address.';
        }
        break;
      case 'Phone Number':
        final digits = trimmed.replaceAll(RegExp(r'[^0-9+]'), '');
        if (digits.length < 7) {
          return 'Enter a valid phone number.';
        }
        break;
      case 'ZIP Code':
        if (trimmed.length < 3) {
          return 'Enter a valid ZIP code.';
        }
        break;
      case 'Country Code':
        if (!RegExp(r'^[A-Za-z]{2}$').hasMatch(trimmed)) {
          return 'Enter a 2-letter country code.';
        }
        break;
    }

    return null;
  }

  ShippingAddress _readShippingAddress() {
    return ShippingAddress(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zipCode: _zipController.text.trim(),
      country: _countryController.text.trim().toUpperCase(),
    );
  }

  bool _isShippingAddressValid(ShippingAddress address) {
    return address.fullName.isNotEmpty &&
        address.email.isNotEmpty &&
        address.phone.isNotEmpty &&
        address.street.isNotEmpty &&
        address.city.isNotEmpty &&
        address.state.isNotEmpty &&
        address.zipCode.isNotEmpty &&
        address.country.isNotEmpty;
  }

  Future<void> _onPlaceOrder(BuildContext context) async {
    setState(() {
      _submittedOnce = true;
    });

    final isValid = _shippingFormKey.currentState?.validate() ?? false;
    if (!isValid) {
      _showErrorSnackBar('Please fix the highlighted shipping fields.');
      return;
    }

    final shippingAddress = _readShippingAddress();
    if (!_isShippingAddressValid(shippingAddress)) {
      _showErrorSnackBar('Please fill in all shipping address fields.');
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    final paymentStatus = await _orderController.placeOrder(
      cartData: widget.cartData,
      shippingAddress: shippingAddress,
    );

    if (!mounted) return;

    setState(() {
      _isPlacingOrder = false;
    });

    final order = _orderController.currentOrder;
    if (order == null) {
      _showErrorSnackBar(_orderController.errorMessage ?? 'Order failed.');
      return;
    }

    if (paymentStatus == PaymentStatus.paid) {
      Provider.of<CartController>(context, listen: false).clearCart();
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderSuccessPage(order: order)),
      );
      return;
    }

    final retry = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => OrderFailurePage(order: order)),
    );

    if (!mounted) return;
    if (retry == true) {
      await _onPlaceOrder(context);
    } else if (retry == false) {
      Navigator.pop(context);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CheckoutLineItem {
  const _CheckoutLineItem({
    required this.name,
    required this.currency,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final String name;
  final String currency;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
}
