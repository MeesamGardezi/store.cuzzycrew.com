import 'package:cuzzycrewstore/api/ApiService.dart';
import 'package:cuzzycrewstore/model/orderModel.dart';
import 'package:flutter/foundation.dart';

class OrderController extends ChangeNotifier {
  OrderController({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

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

      final orderResponse = await _apiService.createOrder(
        // TODO: replace with real persisted shipping address id from backend.
        shippingAddressId: 'shipping_checkout_temp',
        idempotencyKey: idempotencyKey,
      );

      final createdOrder = _hydrateOrderFromResponses(
        orderResponse: orderResponse,
        cartData: cartData,
        shippingAddress: shippingAddress,
      );

      final intentResponse = await _apiService.createPaymentIntent(
        orderId: createdOrder.id,
      );

      final paymentIntentId =
          _extractData(intentResponse)['stripePaymentIntentId']?.toString();
      _currentOrder = OrderModel(
        id: createdOrder.id,
        stripeSessionId: createdOrder.stripeSessionId,
        paymentIntentId: paymentIntentId,
        paymentStatus: PaymentStatus.pending,
        currency: createdOrder.currency,
        subtotal: createdOrder.subtotal,
        tax: createdOrder.tax,
        shippingCost: createdOrder.shippingCost,
        total: createdOrder.total,
        items: createdOrder.items,
        shippingAddress: createdOrder.shippingAddress,
        createdAt: createdOrder.createdAt,
      );

      final clientSecret =
          _extractData(intentResponse)['clientSecret']?.toString();

      final launched = await _launchStripeCheckout(clientSecret: clientSecret);
      if (!launched) {
        _currentOrder = _currentOrder!.copyWith(
          paymentStatus: PaymentStatus.failed,
        );
        return PaymentStatus.failed;
      }

      final statusResponse = await _apiService.getPaymentStatus(
        orderId: createdOrder.id,
      );
      final paymentData = _extractData(statusResponse)['payment'];
      final paymentStatus = _mapPaymentStatus(paymentData);

      _currentOrder = _currentOrder!.copyWith(paymentStatus: paymentStatus);
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

  Future<bool> _launchStripeCheckout({String? clientSecret}) async {
    if (clientSecret == null || clientSecret.isEmpty) {
      return false;
    }

    // TODO: Integrate Stripe SDK/UI here.
    // Suggested options:
    // 1) flutter_stripe PaymentSheet with the clientSecret.
    // 2) Redirect to your backend-hosted Stripe Checkout session URL.
    // Returning true means checkout UI completed and backend status can be polled.
    return true;
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
      stripeSessionId: order['stripeSessionId']?.toString(),
      paymentIntentId: order['stripePaymentIntentId']?.toString(),
      paymentStatus: PaymentStatus.pending,
      currency: (order['currency'] ?? cartData['currency'] ?? 'USD').toString(),
      subtotal:
          (order['subtotal'] as num?)?.toDouble() ??
          (cartData['subtotal'] as num?)?.toDouble() ??
          0,
      tax: (order['tax'] as num?)?.toDouble() ?? 0,
      shippingCost: (order['shippingCost'] as num?)?.toDouble() ?? 0,
      total:
          (order['total'] as num?)?.toDouble() ??
          (cartData['total'] as num?)?.toDouble() ??
          0,
      items: items,
      shippingAddress: shippingAddress,
      createdAt:
          DateTime.tryParse((order['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

extension on OrderModel {
  OrderModel copyWith({
    String? id,
    String? stripeSessionId,
    String? paymentIntentId,
    PaymentStatus? paymentStatus,
    String? currency,
    double? subtotal,
    double? tax,
    double? shippingCost,
    double? total,
    List<Map<String, dynamic>>? items,
    ShippingAddress? shippingAddress,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      stripeSessionId: stripeSessionId ?? this.stripeSessionId,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      currency: currency ?? this.currency,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shippingCost: shippingCost ?? this.shippingCost,
      total: total ?? this.total,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
