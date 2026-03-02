import 'package:flutter/material.dart';

class NavWrapperController {
  static final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  static final ValueNotifier<String?> shopCategory = ValueNotifier<String?>(
    null,
  );
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.dark,
  );

  static const List<String> navItems = [
    'HOME',
    'SHOP',
    'CATEGORIES',
    'TRACK ORDER',
  ];

  static const List<String> desktopItems = navItems;

  static const List<String> tabletItems = navItems;

  static const List<String> mobileItems = navItems;

  static void setSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  static void openShopWithCategory(String? category) {
    shopCategory.value = category;
    selectedIndex.value = 1;
  }

  static void toggleTheme() {
    themeMode.value =
        themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}
