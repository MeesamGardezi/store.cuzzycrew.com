import 'package:cuzzycrewstore/controller/cartController.dart';
import 'package:cuzzycrewstore/navigation/core/navWrapperController.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:cuzzycrewstore/utils/design_utils.dart';
import 'package:cuzzycrewstore/views/pages/cartpage/cartPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

enum NavbarDeviceType { desktop, tablet, mobile }

class _NavMetrics {
  final double screenWidth;
  final double screenHeight;
  final double horizontalPadding;
  final double navHeight;
  final double logoWidth;
  final double logoHeight;
  final double navItemHorizontalPadding;
  final double navItemFontSize;
  final double tabletNavItemHorizontalPadding;
  final double tabletNavItemFontSize;
  final double actionIconSize;
  final double mobilePanelWidth;
  final double mobilePanelTitleSize;
  final double mobileTileFontSize;

  const _NavMetrics({
    required this.screenWidth,
    required this.screenHeight,
    required this.horizontalPadding,
    required this.navHeight,
    required this.logoWidth,
    required this.logoHeight,
    required this.navItemHorizontalPadding,
    required this.navItemFontSize,
    required this.tabletNavItemHorizontalPadding,
    required this.tabletNavItemFontSize,
    required this.actionIconSize,
    required this.mobilePanelWidth,
    required this.mobilePanelTitleSize,
    required this.mobileTileFontSize,
  });

  factory _NavMetrics.fromContext(
    BuildContext context,
    NavbarDeviceType deviceType,
  ) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isDesktop = deviceType == NavbarDeviceType.desktop;

    return _NavMetrics(
      screenWidth: width,
      screenHeight: height,
      horizontalPadding: DesignUtils.pagePadding(width).horizontal / 2,
      navHeight: DesignUtils.topBarHeight,
      logoWidth:
          isDesktop
              ? width * 0.116
              : deviceType == NavbarDeviceType.tablet
              ? width * 0.195
              : width * 0.32,
      logoHeight:
          isDesktop
              ? height * 0.036
              : deviceType == NavbarDeviceType.tablet
              ? height * 0.052
              : height * 0.043,
      navItemHorizontalPadding: width * 0.007,
      navItemFontSize:
          ((isDesktop ? width * 0.0095 : width * 0.014).clamp(
            12.0,
            16.0,
          )).toDouble(),
      tabletNavItemHorizontalPadding: width * 0.003,
      tabletNavItemFontSize: (width * 0.020).clamp(12.5, 14.0).toDouble(),
      actionIconSize: DesignUtils.topBarActionIconSize(width),
      mobilePanelWidth: width * 0.76,
      mobilePanelTitleSize: width * 0.045,
      mobileTileFontSize: width * 0.041,
    );
  }
}

class StoreTopNavbar extends StatelessWidget {
  final NavbarDeviceType deviceType;
  final String? logoAssetPath;

  const StoreTopNavbar({
    super.key,
    required this.deviceType,
    this.logoAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final metrics = _NavMetrics.fromContext(context, deviceType);
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        boxShadow: DesignUtils.hardShadow(isDark: isDark),
      ),
      padding: EdgeInsets.symmetric(horizontal: metrics.horizontalPadding),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: metrics.navHeight,
          child: Column(
            children: [Expanded(child: _buildRow(context, isDark, metrics))],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, bool isDark, _NavMetrics metrics) {
    switch (deviceType) {
      case NavbarDeviceType.desktop:
        return Row(
          children: [
            Expanded(flex: 3, child: _BrandLogo(metrics: metrics)),
            Expanded(
              flex: 5,
              child: _NavItemsRow(
                items: NavWrapperController.desktopItems,
                metrics: metrics,
              ),
            ),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: _ActionRow(
                  isDark: isDark,
                  showCart: true,
                  showMenu: false,
                  metrics: metrics,
                ),
              ),
            ),
          ],
        );
      case NavbarDeviceType.tablet:
        return Row(
          children: [
            Expanded(flex: 3, child: _BrandLogo(metrics: metrics)),
            Expanded(
              flex: 6,
              child: _NavItemsRow(
                items: NavWrapperController.tabletItems,
                metrics: metrics,
                isTablet: true,
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: _ActionRow(
                  isDark: isDark,
                  showCart: true,
                  showMenu: false,
                  metrics: metrics,
                  isTablet: true,
                ),
              ),
            ),
          ],
        );
      case NavbarDeviceType.mobile:
        return Row(
          children: [
            Expanded(child: _BrandLogo(metrics: metrics)),
            _ActionRow(
              isDark: isDark,
              showCart: true,
              showMenu: true,
              metrics: metrics,
            ),
          ],
        );
    }
  }
}

class _BrandLogo extends StatelessWidget {
  final _NavMetrics metrics;

  const _BrandLogo({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: _LogoWordmark(metrics: metrics),
    );
  }
}

class _LogoWordmark extends StatelessWidget {
  final _NavMetrics metrics;

  const _LogoWordmark({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontSize = (metrics.logoHeight * 0.92).clamp(28.0, 38.0).toDouble();

    return RichText(
      text: TextSpan(
        style: DesignUtils.topBarLogoStyle(isDark: isDark, fontSize: fontSize),
        children: const [
          TextSpan(text: 'Cuzzy'),
          TextSpan(text: 'Crew', style: TextStyle(color: AppColors.amber600)),
        ],
      ),
    );
  }
}

class _NavItemsRow extends StatelessWidget {
  final List<String> items;
  final _NavMetrics metrics;
  final bool isTablet;

  const _NavItemsRow({
    required this.items,
    required this.metrics,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: NavWrapperController.selectedIndex,
      builder: (context, selectedIndex, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (index) {
            final isSelected = selectedIndex == index;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    isTablet
                        ? metrics.tabletNavItemHorizontalPadding
                        : metrics.navItemHorizontalPadding,
              ),
              child: _NavTab(
                label: items[index],
                isSelected: isSelected,
                isTablet: isTablet,
                metrics: metrics,
                onTap: () => NavWrapperController.setSelectedIndex(index),
              ),
            );
          }),
        );
      },
    );
  }
}

class _NavTab extends StatefulWidget {
  final String label;
  final bool isSelected;
  final bool isTablet;
  final _NavMetrics metrics;
  final VoidCallback onTap;

  const _NavTab({
    required this.label,
    required this.isSelected,
    required this.isTablet,
    required this.metrics,
    required this.onTap,
  });

  @override
  State<_NavTab> createState() => _NavTabState();
}

class _NavTabState extends State<_NavTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool active = widget.isSelected || _hovered;
    final double fontSize =
        widget.isTablet
            ? widget.metrics.tabletNavItemFontSize
            : widget.metrics.navItemFontSize;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.amber600 : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: TextButton(
          onPressed: widget.onTap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isTablet ? 10 : 14,
              vertical: 8,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            foregroundColor:
                active ? AppColors.amber600 : theme.colorScheme.onSurface,
            textStyle: GoogleFonts.spaceMono(
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: fontSize,
              letterSpacing: 1.0,
            ),
            side: BorderSide.none,
            overlayColor: AppColors.amber200.withValues(alpha: 0.28),
          ),
          child: Text(widget.label.toUpperCase()),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final bool isDark;
  final bool showCart;
  final bool showMenu;
  final _NavMetrics metrics;
  final bool isTablet;

  const _ActionRow({
    required this.isDark,
    required this.showCart,
    required this.showMenu,
    required this.metrics,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final menuIconColor =
        isDark ? AppColors.darkText : theme.colorScheme.onSurface;
    final isMobileActionRow = showMenu;
    final iconSize =
        isTablet
            ? (metrics.tabletNavItemFontSize * 1.55).clamp(18.0, 22.0)
            : isMobileActionRow
            ? metrics.actionIconSize
            : (metrics.screenWidth * 0.015).clamp(22.0, 32.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: NavWrapperController.toggleTheme,
          iconSize: iconSize,
          style: DesignUtils.topBarIconButtonStyle(isDark: isDark),
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode,
            color: menuIconColor,
          ),
        ),
        if (showCart)
          Consumer<CartController>(
            builder: (context, cartController, _) {
              return Center(
                child: Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartPage()),
                        );
                      },
                      iconSize: iconSize,
                      style: DesignUtils.topBarIconButtonStyle(isDark: isDark),
                      icon: Icon(
                        Icons.shopping_cart_outlined,
                        color: menuIconColor,
                      ),
                    ),
                    if (cartController.itemCount > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 18,
                          height: 18,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.ink950,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            '${cartController.itemCount}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.darkText,
                              fontWeight: FontWeight.w700,
                              fontSize: (iconSize * 0.3).clamp(8, 12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        if (showMenu)
          IconButton(
            onPressed: () => _showMobileMenu(context),
            iconSize: iconSize,
            style: DesignUtils.topBarIconButtonStyle(isDark: isDark),
            icon: Icon(Icons.menu, color: menuIconColor),
          ),
      ],
    );
  }

  void _showMobileMenu(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierLabel: 'MobileMenu',
      barrierDismissible: true,
      barrierColor: AppColors.ink950.withValues(alpha: 0.52),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) {
        final theme = Theme.of(context);

        return SafeArea(
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: theme.colorScheme.surface,
              child: SizedBox(
                width: metrics.mobilePanelWidth,
                height: metrics.screenHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: metrics.screenWidth * 0.05,
                    vertical: metrics.screenHeight * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Menu',
                              style: DesignUtils.topBarTitleStyle(
                                isDark: theme.brightness == Brightness.dark,
                                fontSize: metrics.mobilePanelTitleSize,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            iconSize: metrics.actionIconSize,
                            style: DesignUtils.topBarIconButtonStyle(
                              isDark: theme.brightness == Brightness.dark,
                            ),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      Divider(color: theme.colorScheme.outline),
                      ValueListenableBuilder<int>(
                        valueListenable: NavWrapperController.selectedIndex,
                        builder: (context, selectedIndex, _) {
                          return Expanded(
                            child: ListView.builder(
                              itemCount:
                                  NavWrapperController.mobileItems.length,
                              itemBuilder: (context, index) {
                                final isSelected = index == selectedIndex;

                                return ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: metrics.screenWidth * 0.005,
                                    vertical: metrics.screenHeight * 0.003,
                                  ),
                                  title: Center(
                                    child: Text(
                                      NavWrapperController.mobileItems[index],
                                      style: GoogleFonts.spaceMono(
                                        fontSize: metrics.mobileTileFontSize,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                        color:
                                            isSelected
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  tileColor:
                                      isSelected
                                          ? theme.colorScheme.primary
                                              .withValues(alpha: 0.10)
                                          : Colors.transparent,
                                  onTap: () {
                                    NavWrapperController.setSelectedIndex(
                                      index,
                                    );
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        );
      },
    );
  }
}
