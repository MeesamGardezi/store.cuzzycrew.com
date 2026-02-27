import 'package:flutter/material.dart';
import 'package:cuzzycrewstore/navigation/layout/store_top_navbar.dart';

class DesktopLayout extends StatelessWidget {
  final Widget child;

  const DesktopLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const StoreTopNavbar(deviceType: NavbarDeviceType.desktop,      logoAssetPath: 'assets/icons/logo.png',),
          Expanded(child: child),
        ],
      ),
    );
  }
}
