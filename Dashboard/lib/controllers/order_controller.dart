import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderController extends ChangeNotifier {
  List<Order> _unprocessedOrders = [];
  List<Order> _processedOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _unprocessedCursor;
  String? _processedCursor;
  bool _hasMoreUnprocessed = false;
  bool _hasMoreProcessed = false;

  List<Order> get unprocessedOrders => _unprocessedOrders;
  List<Order> get processedOrders => _processedOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMoreUnprocessed => _hasMoreUnprocessed;
  bool get hasMoreProcessed => _hasMoreProcessed;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    _unprocessedCursor = null;
    _processedCursor = null;
    _hasMoreUnprocessed = false;
    _hasMoreProcessed = false;
    notifyListeners();

    try {
      final results = await Future.wait([
        _fetchOrdersWithCursor(false),
        _fetchOrdersWithCursor(true),
      ]);

      _unprocessedOrders = results[0].$1;
      _processedOrders = results[1].$1;
      _unprocessedCursor = results[0].$2;
      _processedCursor = results[1].$2;
      _hasMoreUnprocessed = _unprocessedCursor != null;
      _hasMoreProcessed = _processedCursor != null;

      debugPrint(
        '✅ Loaded ${_unprocessedOrders.length + _processedOrders.length} orders',
      );
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Error loading orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<(List<Order>, String?)> _fetchOrdersWithCursor(
    bool processed, {
    String? cursor,
  }) async {
    final query =
        cursor != null
            ? '/api/admin/orders?processed=$processed&cursor=$cursor'
            : '/api/admin/orders?processed=$processed';
    final response = await ApiService.get(query);
    final data =
        response['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final items =
        data['orders'] as List<dynamic>? ??
        data['items'] as List<dynamic>? ??
        [];
    final nextCursor = data['nextCursor'] as String?;

    return (
      items
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList(),
      nextCursor,
    );
  }

  Future<void> loadMoreUnprocessed() async {
    if (_unprocessedCursor == null) return;
    try {
      _errorMessage = null;
      final result = await _fetchOrdersWithCursor(
        false,
        cursor: _unprocessedCursor,
      );
      _unprocessedOrders = [..._unprocessedOrders, ...result.$1];
      _unprocessedCursor = result.$2;
      _hasMoreUnprocessed = _unprocessedCursor != null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadMoreProcessed() async {
    if (_processedCursor == null) return;
    try {
      _errorMessage = null;
      final result = await _fetchOrdersWithCursor(
        true,
        cursor: _processedCursor,
      );
      _processedOrders = [..._processedOrders, ...result.$1];
      _processedCursor = result.$2;
      _hasMoreProcessed = _processedCursor != null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> toggleProcessed(String orderId) async {
    try {
      final response = await ApiService.patch(
        '/api/admin/orders/$orderId/toggleprocessedkey',
        {},
      );
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) return false;

      final updated = Order.fromJson(data);
      _unprocessedOrders.removeWhere((order) => order.id == orderId);
      _processedOrders.removeWhere((order) => order.id == orderId);
      if (updated.processed) {
        _processedOrders =
            [
              updated,
              ..._processedOrders.where((order) => order.id != orderId),
            ].toList();
      } else {
        _unprocessedOrders =
            [
              updated,
              ..._unprocessedOrders.where((order) => order.id != orderId),
            ].toList();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
