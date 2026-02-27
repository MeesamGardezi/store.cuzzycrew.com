import 'package:cuzzycrewstore/navigation/layout/desktopLayout.dart';
import 'package:cuzzycrewstore/navigation/layout/mobileLayout.dart';
import 'package:cuzzycrewstore/navigation/layout/tabletLayout.dart';
import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return MobileLayout(child: child);
        } else if (constraints.maxWidth < 1024) {
          return TabletLayout(child: child);
        } else {
          return DesktopLayout(child: child);
        }
      },
    );
  }
}
