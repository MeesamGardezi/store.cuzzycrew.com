import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderController extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/api/admin/orders');
      final items =
          (response['data'] as Map<String, dynamic>?)?['orders']
              as List<dynamic>? ??
          [];

      _orders =
          items
              .map((item) => Order.fromJson(item as Map<String, dynamic>))
              .toList();

      debugPrint('✅ Loaded ${_orders.length} orders');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Error loading orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

void debugPrint(String message) {
  print(message);
}
