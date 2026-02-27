import 'package:cuzzycrewstore/navigation/layout/store_top_navbar.dart';
import 'package:flutter/material.dart';

class MobileLayout extends StatelessWidget {
  final Widget child;

  const MobileLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const StoreTopNavbar(
            deviceType: NavbarDeviceType.mobile,
            logoAssetPath: 'assets/icons/logo.png',
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
