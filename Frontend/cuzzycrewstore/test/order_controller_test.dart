import 'package:cuzzycrewstore/api/ApiService.dart';
import 'package:cuzzycrewstore/controller/orderController.dart';
import 'package:cuzzycrewstore/model/orderModel.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeApiService extends ApiService {
  Map<String, dynamic>? capturedOrderRequest;
  Map<String, dynamic>? capturedCheckoutRequest;
  Map<String, dynamic> paymentStatusResponse = const {};

  @override
  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required String currency,
    required Map<String, dynamic> shippingAddress,
    required String idempotencyKey,
  }) async {
    capturedOrderRequest = {
      'items': items,
      'currency': currency,
      'shippingAddress': shippingAddress,
      'idempotencyKey': idempotencyKey,
    };

    return {
      'success': true,
      'data': {
        'order': {
          'id': 'order_1',
          'orderToken': 'order-token-1',
          'status': 'PENDING_PAYMENT',
          'paymentStatus': 'pending',
          'paymentProvider': 'paddle',
          'subtotal': 2599,
          'tax': 0,
          'shippingCost': 0,
          'total': 2599,
          'processed': false,
          'createdAt': '2026-04-17T00:00:00.000Z',
        },
        'items': items,
      },
      'message': '',
    };
  }

  @override
  Future<Map<String, dynamic>> createCheckout({
    required String orderId,
    required String orderToken,
  }) async {
    capturedCheckoutRequest = {'orderId': orderId, 'orderToken': orderToken};

    return {
      'success': true,
      'data': {
        'checkoutUrl':
            'https://checkout.example.com/paddle?orderId=$orderId&orderToken=$orderToken',
        'payment': {'provider': 'paddle', 'status': 'pending'},
      },
      'message': '',
    };
  }

  @override
  Future<Map<String, dynamic>> getPaymentStatus({
    required String orderId,
    required String orderToken,
  }) async {
    return paymentStatusResponse.isEmpty
        ? {
          'success': true,
          'data': {
            'order': {
              'id': orderId,
              'orderToken': orderToken,
              'status': 'PAID',
              'paymentStatus': 'paid',
              'paymentProvider': 'paddle',
              'subtotal': 2599,
              'tax': 0,
              'shippingCost': 0,
              'total': 2599,
              'processed': false,
              'createdAt': '2026-04-17T00:00:00.000Z',
            },
            'payment': {'provider': 'paddle', 'status': 'paid'},
          },
          'message': '',
        }
        : paymentStatusResponse;
  }
}

void main() {
  test('placeOrder maps the cart payload and polls payment status', () async {
    final api = FakeApiService();
    final controller = OrderController(
      apiService: api,
      launchCheckoutUrl: (_) async => true,
    );

    final paymentStatus = await controller.placeOrder(
      cartData: {
        'currency': 'USD',
        'items': [
          {
            'productId': 'product_1',
            'quantity': 2,
            'selectedSize': 'M',
            'selectedColor': '#ffffff',
          },
        ],
        'subtotal': 25.99,
        'total': 25.99,
      },
      shippingAddress: const ShippingAddress(
        fullName: 'Test User',
        email: 'test@example.com',
        phone: '555-0100',
        street: '123 Main St',
        city: 'Austin',
        state: 'TX',
        zipCode: '78701',
        country: 'US',
      ),
    );

    expect(paymentStatus, PaymentStatus.paid);
    expect(api.capturedOrderRequest?['currency'], 'USD');
    expect(api.capturedOrderRequest?['items'], isA<List<dynamic>>());
    expect(api.capturedOrderRequest?['shippingAddress'], {
      'fullName': 'Test User',
      'email': 'test@example.com',
      'phone': '555-0100',
      'street': '123 Main St',
      'city': 'Austin',
      'state': 'TX',
      'zipCode': '78701',
      'country': 'US',
    });
    expect(api.capturedCheckoutRequest?['orderId'], 'order_1');
    expect(api.capturedCheckoutRequest?['orderToken'], 'order-token-1');
    expect(controller.currentOrder?.paymentStatus, PaymentStatus.paid);
  });

  test('placeOrder reports failed payment status', () async {
    final api =
        FakeApiService()
          ..paymentStatusResponse = {
            'success': true,
            'data': {
              'order': {
                'id': 'order_1',
                'orderToken': 'order-token-1',
                'status': 'FAILED',
                'paymentStatus': 'failed',
                'paymentProvider': 'paddle',
                'subtotal': 2599,
                'tax': 0,
                'shippingCost': 0,
                'total': 2599,
                'processed': false,
                'createdAt': '2026-04-17T00:00:00.000Z',
              },
              'payment': {'provider': 'paddle', 'status': 'failed'},
            },
            'message': '',
          };

    final controller = OrderController(
      apiService: api,
      launchCheckoutUrl: (_) async => true,
    );

    final paymentStatus = await controller.placeOrder(
      cartData: {
        'currency': 'USD',
        'items': [
          {
            'productId': 'product_1',
            'quantity': 1,
            'selectedSize': 'M',
            'selectedColor': '#ffffff',
          },
        ],
        'subtotal': 25.99,
        'total': 25.99,
      },
      shippingAddress: const ShippingAddress(
        fullName: 'Test User',
        email: 'test@example.com',
        phone: '555-0100',
        street: '123 Main St',
        city: 'Austin',
        state: 'TX',
        zipCode: '78701',
        country: 'US',
      ),
    );

    expect(paymentStatus, PaymentStatus.failed);
    expect(controller.currentOrder?.paymentStatus, PaymentStatus.failed);
  });
}
