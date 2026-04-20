import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/order_controller.dart';
import '../models/order.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final Set<String> _pendingToggles = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderController>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          automaticallyImplyLeading: false,
          elevation: 0,
          bottom: const TabBar(
            tabs: [Tab(text: 'Unprocessed'), Tab(text: 'Processed')],
          ),
        ),
        body: Consumer<OrderController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(controller.errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.fetchOrders(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              children: [
                _buildOrderList(
                  context,
                  controller,
                  controller.unprocessedOrders,
                  emptyLabel: 'No unprocessed orders',
                  showLoadMore: controller.hasMoreUnprocessed,
                  onLoadMore: controller.loadMoreUnprocessed,
                ),
                _buildOrderList(
                  context,
                  controller,
                  controller.processedOrders,
                  emptyLabel: 'No processed orders',
                  showLoadMore: controller.hasMoreProcessed,
                  onLoadMore: controller.loadMoreProcessed,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    OrderController controller,
    List<Order> orders, {
    required String emptyLabel,
    required bool showLoadMore,
    required Future<void> Function() onLoadMore,
  }) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(emptyLabel),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length + (showLoadMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= orders.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              child: Center(
                child: OutlinedButton(
                  onPressed: onLoadMore,
                  child: const Text('Load More'),
                ),
              ),
            );
          }

          final order = orders[index];
          final isPending = _pendingToggles.contains(order.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showOrderDetails(context, order),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            order.orderNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _StatusChip(
                          label: order.statusLabel,
                          color: _getStatusColor(order.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: ${order.currency} ${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${order.createdAt.toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatusChip(
                          label: order.processed ? 'Processed' : 'Unprocessed',
                          color: order.processed ? Colors.green : Colors.orange,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed:
                              isPending
                                  ? null
                                  : () async {
                                    setState(
                                      () => _pendingToggles.add(order.id),
                                    );
                                    final ok = await controller.toggleProcessed(
                                      order.id,
                                    );
                                    if (!mounted) return;
                                    setState(
                                      () => _pendingToggles.remove(order.id),
                                    );
                                    if (!ok && context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            controller.errorMessage ??
                                                'Failed to update order',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                          icon:
                              isPending
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Icon(
                                    order.processed
                                        ? Icons.undo
                                        : Icons.check_circle_outline,
                                  ),
                          label: Text(
                            order.processed
                                ? 'Mark Unprocessed'
                                : 'Mark Processed',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showOrderDetails(BuildContext context, Order order) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(order.orderNumber),
          content: SizedBox(
            width: 680,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Order summary', [
                    _buildDetailRow('Order status', order.statusLabel),
                    _buildDetailRow(
                      'Payment provider',
                      order.paymentProvider ?? 'N/A',
                    ),
                    _buildDetailRow(
                      'Payment status',
                      order.paymentStatus ?? 'N/A',
                    ),
                    _buildDetailRow(
                      'Processed',
                      order.processed ? 'Yes' : 'No',
                    ),
                    _buildDetailRow('Created at', order.createdAt.toString()),
                    _buildDetailRow(
                      'Subtotal',
                      '${order.currency} ${order.subtotal.toStringAsFixed(2)}',
                    ),
                    _buildDetailRow(
                      'Discount',
                      '${order.currency} ${order.discountTotal.toStringAsFixed(2)}',
                    ),
                    _buildDetailRow(
                      'Total',
                      '${order.currency} ${order.total.toStringAsFixed(2)}',
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection('Customer and shipping', [
                    _buildDetailRow(
                      'Customer',
                      _shippingValue(order.shippingAddress, 'fullName'),
                    ),
                    _buildDetailRow(
                      'Email',
                      _shippingValue(order.shippingAddress, 'email'),
                    ),
                    _buildDetailRow(
                      'Phone',
                      _shippingValue(order.shippingAddress, 'phone'),
                    ),
                    _buildDetailRow(
                      'Street',
                      _shippingStreet(order.shippingAddress),
                    ),
                    _buildDetailRow(
                      'City',
                      _shippingValue(order.shippingAddress, 'city'),
                    ),
                    _buildDetailRow(
                      'State',
                      _shippingValue(order.shippingAddress, 'state'),
                    ),
                    _buildDetailRow(
                      'Zip code',
                      _shippingZip(order.shippingAddress),
                    ),
                    _buildDetailRow(
                      'Country',
                      _shippingValue(order.shippingAddress, 'country'),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection(
                    'Items',
                    order.items.isEmpty
                        ? [
                          const Text(
                            'No line items were returned for this order.',
                          ),
                        ]
                        : order.items.map(_buildItemCard).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value.isEmpty ? 'N/A' : value)),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final snapshot =
        item['snapshot'] is Map
            ? Map<String, dynamic>.from(item['snapshot'] as Map)
            : const <String, dynamic>{};
    final productName = (snapshot['productName'] ?? '').toString();
    final selectedColor = (item['selectedColor'] ?? '').toString();
    final colorName = (item['colorName'] ?? '').toString();
    final colorHex = (item['colorHex'] ?? '').toString();
    final resolvedColorHex = _normalizeHex(
      colorHex.isNotEmpty ? colorHex : selectedColor,
    );
    final resolvedColorName =
        colorName.isNotEmpty
            ? colorName
            : _inferColorNameFromHex(resolvedColorHex).isNotEmpty
            ? _inferColorNameFromHex(resolvedColorHex)
            : selectedColor;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            productName.isEmpty
                ? (item['productId']?.toString() ?? 'Item')
                : productName,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          _buildDetailRow('Product ID', item['productId']?.toString() ?? ''),
          _buildDetailRow('Quantity', item['quantity']?.toString() ?? ''),
          _buildDetailRow('Size', item['selectedSize']?.toString() ?? ''),
          _buildDetailRow('Color name', resolvedColorName),
          _buildDetailRow('Color code', resolvedColorHex),
          if (resolvedColorHex.isNotEmpty) _buildColorSwatch(resolvedColorHex),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(String colorHex) {
    final color = _hexToColor(colorHex);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(width: 8),
          Text(colorHex),
        ],
      ),
    );
  }

  String _shippingValue(Map<String, dynamic>? shippingAddress, String key) {
    return shippingAddress?[key]?.toString() ?? '';
  }

  String _shippingStreet(Map<String, dynamic>? shippingAddress) {
    final street = _shippingValue(shippingAddress, 'street');
    if (street.isNotEmpty) return street;
    return _shippingValue(shippingAddress, 'addressLine1');
  }

  String _shippingZip(Map<String, dynamic>? shippingAddress) {
    final zip = _shippingValue(shippingAddress, 'zipCode');
    if (zip.isNotEmpty) return zip;
    return _shippingValue(shippingAddress, 'postalCode');
  }

  String _normalizeHex(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return '';
    return raw.startsWith('#') ? raw : '#$raw';
  }

  String _inferColorNameFromHex(String colorHex) {
    final normalized = colorHex.toLowerCase();
    const known = <String, String>{
      '#d9d2c5': 'Bone',
      '#2b2b2b': 'Onyx',
      '#111111': 'Onyx',
      '#ffffff': 'White',
      '#000000': 'Black',
    };
    return known[normalized] ?? '';
  }

  Color _hexToColor(String hexColor) {
    final normalized = _normalizeHex(hexColor).replaceAll('#', '');
    if (normalized.length == 6) {
      return Color(int.parse('0xff$normalized'));
    }
    return Colors.grey;
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.paid:
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.canceled:
      case OrderStatus.failed:
        return Colors.red;
      case OrderStatus.pending:
        return Colors.orange;
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
