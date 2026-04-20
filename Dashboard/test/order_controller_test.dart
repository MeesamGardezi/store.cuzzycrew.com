import 'dart:convert';

import 'package:cuzzycrew_dashboard/controllers/order_controller.dart';
import 'package:cuzzycrew_dashboard/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> _order({
  required String id,
  required bool processed,
  required String status,
  required int total,
}) {
  return {
    'id': id,
    'orderNumber': 'CC-${id.split('_').last}',
    'status': status,
    'processed': processed,
    'processedAt': processed ? '2026-04-17T02:00:00.000Z' : null,
    'processedBy': processed ? 'admin_1' : null,
    'total': total,
    'currency': 'USD',
    'createdAt': '2026-04-17T00:00:00.000Z',
  };
}

void main() {
  tearDown(() {
    ApiService.setClient(null);
  });

  test('fetchOrders loads processed and unprocessed lists', () async {
    ApiService.setClient(
      MockClient((request) async {
        if (request.method == 'GET' &&
            request.url.path == '/api/admin/orders') {
          final processed = request.url.queryParameters['processed'] == 'true';
          final payload =
              processed
                  ? {
                    'success': true,
                    'data': {
                      'orders': [
                        _order(
                          id: 'order_2',
                          processed: true,
                          status: 'PAID',
                          total: 2599,
                        ),
                      ],
                      'nextCursor': null,
                    },
                    'message': '',
                  }
                  : {
                    'success': true,
                    'data': {
                      'orders': [
                        _order(
                          id: 'order_1',
                          processed: false,
                          status: 'PENDING_PAYMENT',
                          total: 2599,
                        ),
                      ],
                      'nextCursor': null,
                    },
                    'message': '',
                  };
          return http.Response(
            jsonEncode(payload),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response('Not Found', 404);
      }),
    );

    final controller = OrderController();
    await controller.fetchOrders();

    expect(controller.unprocessedOrders, hasLength(1));
    expect(controller.processedOrders, hasLength(1));
    expect(controller.unprocessedOrders.first.id, 'order_1');
    expect(controller.processedOrders.first.id, 'order_2');
  });

  test('toggleProcessed moves an order into the processed list', () async {
    ApiService.setClient(
      MockClient((request) async {
        if (request.method == 'GET' &&
            request.url.path == '/api/admin/orders') {
          final processed = request.url.queryParameters['processed'] == 'true';
          final payload =
              processed
                  ? {
                    'success': true,
                    'data': {'orders': [], 'nextCursor': null},
                    'message': '',
                  }
                  : {
                    'success': true,
                    'data': {
                      'orders': [
                        _order(
                          id: 'order_1',
                          processed: false,
                          status: 'PENDING_PAYMENT',
                          total: 2599,
                        ),
                      ],
                      'nextCursor': null,
                    },
                    'message': '',
                  };
          return http.Response(
            jsonEncode(payload),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'PATCH' &&
            request.url.path ==
                '/api/admin/orders/order_1/toggleprocessedkey') {
          final payload = {
            'success': true,
            'data': _order(
              id: 'order_1',
              processed: true,
              status: 'PAID',
              total: 2599,
            ),
            'message': '',
          };
          return http.Response(
            jsonEncode(payload),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response('Not Found', 404);
      }),
    );

    final controller = OrderController();
    await controller.fetchOrders();
    final toggled = await controller.toggleProcessed('order_1');

    expect(toggled, isTrue);
    expect(controller.unprocessedOrders, isEmpty);
    expect(controller.processedOrders, hasLength(1));
    expect(controller.processedOrders.first.id, 'order_1');
    expect(controller.processedOrders.first.processed, isTrue);
  });
}
