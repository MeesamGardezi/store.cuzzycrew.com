import 'package:cuzzycrewstore/navigation/layout/store_top_navbar.dart';
import 'package:flutter/material.dart';

class TabletLayout extends StatelessWidget {
  final Widget child;

  const TabletLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const StoreTopNavbar(
            deviceType: NavbarDeviceType.tablet,
            logoAssetPath: 'assets/icons/logo.png',
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
