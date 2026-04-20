import 'package:flutter/material.dart';
import 'dart:convert';

import '../models/product.dart';
import '../utils/currency.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailCard(
              title: 'Product summary',
              children: [
                _DetailRow('Name', product.name),
                _DetailRow('Category', product.category),
                _DetailRow(
                  'Price',
                  formatPrice(product.price, currencyCode: product.currency),
                ),
                _DetailRow(
                  'Available units',
                  product.availableUnits.toString(),
                ),
                _DetailRow('Product ID', product.id),
              ],
            ),
            const SizedBox(height: 16),
            _DetailCard(
              title: 'Thumbnail',
              children: [
                if (product.thumbnail.isNotEmpty)
                  _ThumbnailPreview(imageUrl: product.thumbnail)
                else
                  const Text('No thumbnail available'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryDetailPage extends StatelessWidget {
  const CategoryDetailPage({Key? key, required this.category})
    : super(key: key);

  final dynamic category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.name ?? 'Category')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailCard(
              title: 'Category summary',
              children: [
                _DetailRow('Name', category.name ?? ''),
                _DetailRow(
                  'Status',
                  category.launched == true ? 'Active' : 'Inactive',
                ),
                _DetailRow('Category ID', category.id ?? ''),
              ],
            ),
            const SizedBox(height: 16),
            _DetailCard(
              title: 'Thumbnail',
              children: [
                if ((category.thumbnail ?? '').toString().isNotEmpty)
                  _ThumbnailPreview(imageUrl: category.thumbnail)
                else
                  const Text('No thumbnail available'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? 'N/A' : value)),
        ],
      ),
    );
  }
}

class _ThumbnailPreview extends StatelessWidget {
  const _ThumbnailPreview({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('data:image/')) {
      final commaIndex = imageUrl.indexOf(',');
      if (commaIndex > 0) {
        try {
          final bytes = base64Decode(imageUrl.substring(commaIndex + 1));
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              bytes,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        } catch (_) {}
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => Container(
              height: 220,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported),
            ),
      ),
    );
  }
}
