import 'package:cuzzycrewstore/views/pages/homepage/homePage.dart';
import 'package:flutter/material.dart';
import 'package:cuzzycrewstore/navigation/core/navWrapperController.dart';
import 'package:cuzzycrewstore/navigation/core/responsiveWrapper.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:cuzzycrewstore/views/pages/categories_page.dart';
import 'package:cuzzycrewstore/views/pages/shop_page.dart';
import 'package:cuzzycrewstore/views/pages/track_order_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: NavWrapperController.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Cuzzy Crew Store',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          home: const ResponsiveWrapper(child: _AppPageStack()),
        );
      },
    );
  }
}

class _AppPageStack extends StatelessWidget {
  const _AppPageStack();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: NavWrapperController.selectedIndex,
      builder: (context, selectedIndex, _) {
        return IndexedStack(
          index: selectedIndex,
          children:  [
            HomePage(),
            ShopPage(),
            CategoriesPage(),
            TrackOrderPage(),
          ],
        );
      },
    );
  }
}
