import 'package:cuzzycrewstore/api/ApiService.dart';
import 'package:cuzzycrewstore/config/AppConfig.dart';
import 'package:cuzzycrewstore/model/orderModel.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderController extends ChangeNotifier {
  OrderController({
    ApiService? apiService,
    Future<bool> Function(String checkoutUrl)? launchCheckoutUrl,
  }) : _apiService = apiService ?? ApiService(),
       _launchCheckoutUrl = launchCheckoutUrl;

  final ApiService _apiService;
  final Future<bool> Function(String checkoutUrl)? _launchCheckoutUrl;

  bool _isProcessing = false;
  String? _errorMessage;
  OrderModel? _currentOrder;

  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  OrderModel? get currentOrder => _currentOrder;

  Future<PaymentStatus> placeOrder({
    required Map<String, dynamic> cartData,
    required ShippingAddress shippingAddress,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final idempotencyKey =
          'idem_${DateTime.now().microsecondsSinceEpoch.toString()}';

      final items = _buildOrderItems(cartData);
      final shippingPayload = _buildShippingPayload(shippingAddress);

      final orderResponse = await _apiService.createOrder(
        items: items,
        currency: (cartData['currency'] ?? 'USD').toString(),
        shippingAddress: shippingPayload,
        idempotencyKey: idempotencyKey,
      );

      final createdOrder = _hydrateOrderFromResponses(
        orderResponse: orderResponse,
        cartData: cartData,
        shippingAddress: shippingAddress,
      );

      final checkoutResponse = await _apiService.createCheckout(
        orderId: createdOrder.id,
        orderToken: createdOrder.orderToken ?? '',
      );

      _currentOrder = createdOrder;

      final checkoutUrl =
          _extractData(checkoutResponse)['checkoutUrl']?.toString() ?? '';
      final launched = await _launchHostedCheckout(
        checkoutUrl: checkoutUrl,
        orderId: createdOrder.id,
        orderToken: createdOrder.orderToken ?? '',
      );
      if (!launched) {
        _currentOrder = _currentOrder!.copyWith(
          paymentStatus: PaymentStatus.failed,
        );
        return PaymentStatus.failed;
      }

      final paymentStatus = await _pollPaymentStatus(order: createdOrder);

      if (_currentOrder != null) {
        _currentOrder = _currentOrder!.copyWith(paymentStatus: paymentStatus);
      }
      return paymentStatus;
    } catch (error) {
      _errorMessage = error.toString();
      if (_currentOrder != null) {
        _currentOrder = _currentOrder!.copyWith(
          paymentStatus: PaymentStatus.failed,
        );
      }
      return PaymentStatus.failed;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  PaymentStatus _mapPaymentStatus(dynamic paymentData) {
    final raw =
        (paymentData is Map<String, dynamic> ? paymentData['status'] : null)
            ?.toString()
            .toLowerCase() ??
        '';

    if (raw == 'succeeded' || raw == 'paid') {
      return PaymentStatus.paid;
    }
    if (raw == 'failed') {
      return PaymentStatus.failed;
    }
    return PaymentStatus.pending;
  }

  Future<PaymentStatus> _pollPaymentStatus({required OrderModel order}) async {
    final orderToken = order.orderToken;
    if (orderToken == null || orderToken.isEmpty) {
      return PaymentStatus.failed;
    }

    final delays = <Duration>[
      const Duration(seconds: 1),
      const Duration(seconds: 2),
      const Duration(seconds: 4),
      const Duration(seconds: 8),
    ];

    for (final delay in delays) {
      final statusResponse = await _apiService.getPaymentStatus(
        orderId: order.id,
        orderToken: orderToken,
      );
      final data = _extractData(statusResponse);
      final paymentData = data['payment'];
      final paymentStatus = _mapPaymentStatus(paymentData);
      final refreshedOrder = data['order'];
      if (refreshedOrder is Map<String, dynamic>) {
        _currentOrder = OrderModel.fromJson(refreshedOrder);
      }

      if (paymentStatus == PaymentStatus.paid ||
          paymentStatus == PaymentStatus.failed) {
        return paymentStatus;
      }

      await Future.delayed(delay);
    }

    final finalStatusResponse = await _apiService.getPaymentStatus(
      orderId: order.id,
      orderToken: orderToken,
    );
    final finalData = _extractData(finalStatusResponse);
    final finalPaymentStatus = _mapPaymentStatus(finalData['payment']);
    final finalOrder = finalData['order'];
    if (finalOrder is Map<String, dynamic>) {
      _currentOrder = OrderModel.fromJson(finalOrder);
    }
    return finalPaymentStatus;
  }

  Future<bool> _launchHostedCheckout({
    required String checkoutUrl,
    required String orderId,
    required String orderToken,
  }) async {
    if (kUseDummyPaddle) {
      try {
        await _apiService.simulatePaymentSuccess(
          orderId: orderId,
          orderToken: orderToken,
        );
        return true;
      } catch (_) {
        return false;
      }
    }

    if (checkoutUrl.isEmpty) return false;

    if (_launchCheckoutUrl != null) {
      return _launchCheckoutUrl(checkoutUrl);
    }

    final uri = Uri.tryParse(checkoutUrl);
    if (uri == null) return false;

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Map<String, dynamic> _buildShippingPayload(ShippingAddress address) {
    return {
      'fullName': address.fullName,
      'email': address.email,
      'phone': address.phone,
      'street': address.street,
      'city': address.city,
      'state': address.state,
      'zipCode': address.zipCode,
      'country': address.country,
    };
  }

  List<Map<String, dynamic>> _buildOrderItems(Map<String, dynamic> cartData) {
    final rawItems = (cartData['items'] as List<dynamic>? ?? const <dynamic>[]);
    return rawItems
        .map((item) => Map<String, dynamic>.from(item as Map))
        .map(
          (item) => {
            'productId': item['productId']?.toString() ?? '',
            'quantity': (item['quantity'] as num?)?.toInt() ?? 1,
            'selectedSize': item['selectedSize']?.toString() ?? '',
            'selectedColor': item['selectedColor']?.toString() ?? '',
          },
        )
        .where((item) => item['productId'].toString().isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _extractData(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return <String, dynamic>{};
  }

  OrderModel _hydrateOrderFromResponses({
    required Map<String, dynamic> orderResponse,
    required Map<String, dynamic> cartData,
    required ShippingAddress shippingAddress,
  }) {
    final data = _extractData(orderResponse);
    final order =
        (data['order'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final items =
        (data['items'] as List<dynamic>? ??
                cartData['items'] as List<dynamic>? ??
                <dynamic>[])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();

    return OrderModel(
      id: (order['id'] ?? '').toString(),
      orderToken: order['orderToken']?.toString(),
      orderStatus: OrderModel.parseOrderStatus(
        (order['status'] ?? 'PENDING_PAYMENT').toString().toUpperCase(),
      ),
      paymentProvider: (order['paymentProvider'] ?? 'paddle').toString(),
      paymentStatus: PaymentStatus.pending,
      currency: (order['currency'] ?? cartData['currency'] ?? 'USD').toString(),
      subtotal: _displayAmount(order['subtotal'], cartData['subtotal']),
      tax: _displayAmount(order['tax'], 0),
      shippingCost: _displayAmount(order['shippingCost'], 0),
      total: _displayAmount(order['total'], cartData['total']),
      items: items,
      shippingAddress: shippingAddress,
      createdAt:
          DateTime.tryParse((order['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      processed: (order['processed'] as bool?) ?? false,
      processedAt: DateTime.tryParse((order['processedAt'] ?? '').toString()),
      processedBy: order['processedBy']?.toString(),
    );
  }

  double _displayAmount(dynamic backendValue, dynamic fallbackMajorValue) {
    if (backendValue is num) {
      return backendValue.toDouble() / 100.0;
    }

    return (fallbackMajorValue as num?)?.toDouble() ?? 0.0;
  }
}

extension on OrderModel {
  OrderModel copyWith({
    String? id,
    String? orderToken,
    OrderStatus? orderStatus,
    String? paymentProvider,
    PaymentStatus? paymentStatus,
    String? currency,
    double? subtotal,
    double? tax,
    double? shippingCost,
    double? total,
    List<Map<String, dynamic>>? items,
    ShippingAddress? shippingAddress,
    DateTime? createdAt,
    bool? processed,
    DateTime? processedAt,
    String? processedBy,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderToken: orderToken ?? this.orderToken,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      currency: currency ?? this.currency,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shippingCost: shippingCost ?? this.shippingCost,
      total: total ?? this.total,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdAt: createdAt ?? this.createdAt,
      processed: processed ?? this.processed,
      processedAt: processedAt ?? this.processedAt,
      processedBy: processedBy ?? this.processedBy,
    );
  }
}
