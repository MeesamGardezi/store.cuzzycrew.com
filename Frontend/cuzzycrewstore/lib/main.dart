import 'package:cuzzycrewstore/controller/cartController.dart';
import 'package:cuzzycrewstore/views/pages/homepage/homePage.dart';
import 'package:cuzzycrewstore/views/pages/shoppage/shopPage.dart';
import 'package:flutter/material.dart';
import 'package:cuzzycrewstore/navigation/core/navWrapperController.dart';
import 'package:cuzzycrewstore/navigation/core/responsiveWrapper.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:cuzzycrewstore/views/pages/about/aboutPage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartController(),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: NavWrapperController.themeMode,
        builder: (context, themeMode, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Cuzzy Crew Store',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,

            home: const ResponsiveWrapper(child: _AppPageStack()),
          );
        },
      ),
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
          children: [
            HomePage(),
            ValueListenableBuilder<String?>(
              valueListenable: NavWrapperController.shopCategory,
              builder: (context, category, _) {
                return ShopPage(initialCategory: category);
              },
            ),
            AboutPage(),
          ],
        );
      },
    );
  }
}
