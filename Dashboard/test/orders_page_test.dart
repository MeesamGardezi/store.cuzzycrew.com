import 'package:cuzzycrew_dashboard/controllers/order_controller.dart';
import 'package:cuzzycrew_dashboard/models/order.dart';
import 'package:cuzzycrew_dashboard/pages/orders_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class FakeOrdersController extends OrderController {
  FakeOrdersController()
    : _unprocessed = [
        Order.fromJson({
          'id': 'order_1',
          'orderNumber': 'CC-1',
          'status': 'PENDING_PAYMENT',
          'processed': false,
          'total': 2599,
          'currency': 'USD',
          'createdAt': '2026-04-17T00:00:00.000Z',
        }),
      ],
      _processed = [];

  List<Order> _unprocessed;
  List<Order> _processed;

  @override
  List<Order> get unprocessedOrders => _unprocessed;

  @override
  List<Order> get processedOrders => _processed;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  Future<void> fetchOrders() async {}

  @override
  Future<bool> toggleProcessed(String orderId) async {
    final moved = _unprocessed.where((order) => order.id == orderId).toList();
    _unprocessed = _unprocessed.where((order) => order.id != orderId).toList();
    _processed = [
      ..._processed,
      ...moved.map(
        (order) => Order.fromJson({
          'id': order.id,
          'orderNumber': order.orderNumber,
          'status': 'PAID',
          'processed': true,
          'processedAt': '2026-04-17T02:00:00.000Z',
          'processedBy': 'admin_1',
          'total': 2599,
          'currency': order.currency,
          'createdAt': order.createdAt.toIso8601String(),
        }),
      ),
    ];
    notifyListeners();
    return true;
  }
}

void main() {
  testWidgets('OrdersPage renders split tabs and toggles orders', (
    tester,
  ) async {
    final controller = FakeOrdersController();

    await tester.pumpWidget(
      ChangeNotifierProvider<OrderController>.value(
        value: controller,
        child: const MaterialApp(home: OrdersPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Unprocessed'), findsWidgets);
    expect(find.text('Processed'), findsWidgets);
    expect(find.text('CC-1'), findsOneWidget);
    expect(find.text('Mark Processed'), findsOneWidget);

    await tester.tap(find.text('Mark Processed'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Processed').first);
    await tester.pumpAndSettle();

    expect(find.text('CC-1'), findsOneWidget);
    expect(find.text('Mark Unprocessed'), findsOneWidget);
  });
}
