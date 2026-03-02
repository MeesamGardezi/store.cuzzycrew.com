import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuzzycrewstore/controller/productDetailController.dart';
import 'package:cuzzycrewstore/model/productModel.dart';
import 'package:cuzzycrewstore/views/pages/productdetailpage/productDetailMobileLayout.dart';
import 'package:cuzzycrewstore/views/pages/productdetailpage/productDetailDesktopLayout.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({required this.product, super.key});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 640;

    return ChangeNotifierProvider(
      create: (_) => ProductDetailController(product: product),
      child:
          isMobile
              ? ProductDetailMobileLayout(product: product)
              : ProductDetailDesktopLayout(product: product),
    );
  }
}
