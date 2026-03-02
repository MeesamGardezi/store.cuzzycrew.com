import 'package:cuzzycrewstore/controller/cartController.dart';
import 'package:cuzzycrewstore/views/pages/cartpage/cartMobileLayout.dart';
import 'package:cuzzycrewstore/views/pages/cartpage/cartTabletLayout.dart';
import 'package:cuzzycrewstore/views/pages/cartpage/cartDesktopLayout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return const CartMobileLayout();
        } else if (constraints.maxWidth < 1024) {
          return const CartTabletLayout();
        } else {
          return const CartDesktopLayout();
        }
      },
    );
  }
}
