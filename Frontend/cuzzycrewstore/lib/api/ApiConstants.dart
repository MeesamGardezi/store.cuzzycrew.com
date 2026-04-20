class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000',
  );

  static const String createOrder = '/api/orders';
  static const String createCheckout = '/api/payments/checkout';
  static const String simulatePaymentSuccess =
      '/api/dev/simulate-payment-success';
  static const String AllProductFetch = '/api/products';
  static const String CategoriesFetch = '/api/categories';

  static String paymentStatus(String orderId) =>
      '/api/payments/$orderId/status';
}
