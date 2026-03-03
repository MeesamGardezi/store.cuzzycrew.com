class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://cuzzycrew-backend.vercel.app';

  static const String createOrder = '/api/orders';
  static const String paymentIntent = '/api/payments/intent';
  static const String AllProductFetch = '/api/products';
  static const String CategoriesFetch = '/api/categories';

  static String paymentStatus(String orderId) =>
      '/api/payments/$orderId/status';
}
