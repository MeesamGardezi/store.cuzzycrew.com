import 'package:cuzzycrewstore/navigation/core/navWrapperController.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:flutter/material.dart';

enum NavbarDeviceType { desktop, tablet, mobile }

class _NavMetrics {
  final double screenWidth;
  final double screenHeight;
  final double horizontalPadding;
  final double navHeight;
  final double logoWidth;
  final double logoHeight;
  final double logoRadius;
  final double logoBorderWidth;
  final double navItemHorizontalPadding;
  final double navItemFontSize;
  final double tabletNavItemHorizontalPadding;
  final double tabletNavItemFontSize;
  final double actionIconSize;
  final double actionButtonRadius;
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
    required this.logoRadius,
    required this.logoBorderWidth,
    required this.navItemHorizontalPadding,
    required this.navItemFontSize,
    required this.tabletNavItemHorizontalPadding,
    required this.tabletNavItemFontSize,
    required this.actionIconSize,
    required this.actionButtonRadius,
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
    final isMobile = deviceType == NavbarDeviceType.mobile;
    final isTablet = deviceType == NavbarDeviceType.tablet;

    return _NavMetrics(
      screenWidth: width,
      screenHeight: height,
      horizontalPadding:
          isDesktop
              ? width * 0.02
              : isMobile
              ? width * 0.04
              : width * 0.02,
      navHeight: isMobile ? height * 0.09 : height * 0.105,
      logoWidth:
          isDesktop
              ? width * 0.12
              : isTablet
              ? width * 0.20
              : width * 0.36,
      logoHeight:
          isDesktop
              ? height * 0.04
              : isTablet
              ? height * 0.060
              : height * 0.048,
      logoRadius: width * 0.010,
      logoBorderWidth: (width * 0.0016).clamp(1.4, 2.4),
      navItemHorizontalPadding: width * 0.007,
      navItemFontSize:
          ((isDesktop ? width * 0.0095 : width * 0.014).clamp(
            12.0,
            16.0,
          )).toDouble(),
      tabletNavItemHorizontalPadding: width * 0.003,
      tabletNavItemFontSize: (width * 0.020).clamp(12.5, 14.0).toDouble(),
      actionIconSize: isMobile ? width * 0.060 : width * 0.018,
      actionButtonRadius: width * 0.022,
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

    return Container(
      color: isDark ? AppColors.darkBackground : theme.scaffoldBackgroundColor,
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
            Expanded(
              flex: 3,
              child: _BrandLogo(logoAssetPath: logoAssetPath, metrics: metrics),
            ),
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
            Expanded(
              flex: 3,
              child: _BrandLogo(logoAssetPath: logoAssetPath, metrics: metrics),
            ),
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
            Expanded(
              child: _BrandLogo(logoAssetPath: logoAssetPath, metrics: metrics),
            ),
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
  final String? logoAssetPath;
  final _NavMetrics metrics;

  const _BrandLogo({required this.logoAssetPath, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: _LogoAssetView(logoAssetPath: logoAssetPath, metrics: metrics),
    );
  }
}

class _LogoAssetView extends StatelessWidget {
  final String? logoAssetPath;
  final _NavMetrics metrics;

  const _LogoAssetView({required this.logoAssetPath, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    final logo =
        logoAssetPath == null || logoAssetPath!.isEmpty
            ? _LogoFallback(metrics: metrics)
            : Image.asset(
              logoAssetPath!,
              width: metrics.logoWidth,
              height: metrics.logoHeight,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _LogoFallback(metrics: metrics);
              },
            );

    if (!isLight) {
      return logo;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: metrics.logoWidth * 0.04,
        vertical: metrics.logoHeight * 0.025,
      ),
      decoration: BoxDecoration(
        // color: AppColors.mutedText.withValues(alpha: 0.10),
        // borderRadius: BorderRadius.circular(metrics.logoRadius),
        boxShadow: [
          // BoxShadow(
          //   color: AppColors.mutedText.withValues(alpha: 0.18),
          //   blurRadius: metrics.logoRadius * 0.55,
          //   offset: Offset.zero,
          // ),
        ],
      ),
      child: logo,
    );
  }
}

class _LogoFallback extends StatelessWidget {
  final _NavMetrics metrics;

  const _LogoFallback({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: metrics.logoWidth,
      height: metrics.logoHeight,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.primaryAccent,
          width: metrics.logoBorderWidth,
        ),
        borderRadius: BorderRadius.circular(metrics.logoRadius),
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
    final theme = Theme.of(context);

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
              child: TextButton(
                onPressed: () => NavWrapperController.setSelectedIndex(index),
                style: TextButton.styleFrom(
                  foregroundColor:
                      isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                  textStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize:
                        isTablet
                            ? metrics.tabletNavItemFontSize
                            : metrics.navItemFontSize,
                  ),
                ),
                child: Text(items[index]),
              ),
            );
          }),
        );
      },
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

    final buttonSide =
        isTablet
            ? (iconSize * 2.1).clamp(30.0, 36.0)
            : isMobileActionRow
            ? metrics.actionButtonRadius * 2
            : (iconSize * 1.8).clamp(40.0, 60.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: NavWrapperController.toggleTheme,
          iconSize: iconSize,
          style: IconButton.styleFrom(minimumSize: Size.square(buttonSide)),
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode,
            color: menuIconColor,
          ),
        ),
        if (showCart)
          IconButton(
            onPressed: () {},
            iconSize: iconSize,
            style: IconButton.styleFrom(minimumSize: Size.square(buttonSide)),
            icon: Icon(Icons.shopping_cart_outlined, color: menuIconColor),
          ),
        if (showMenu)
          IconButton(
            onPressed: () => _showMobileMenu(context),
            iconSize: iconSize,
            style: IconButton.styleFrom(minimumSize: Size.square(buttonSide)),
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
      barrierColor: Colors.black45,
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
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: metrics.mobilePanelTitleSize,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            iconSize: metrics.actionIconSize,
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
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontSize:
                                                metrics.mobileTileFontSize,
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                            color:
                                                isSelected
                                                    ? theme.colorScheme.primary
                                                    : theme
                                                        .colorScheme
                                                        .onSurface,
                                          ),
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      metrics.screenWidth * 0.02,
                                    ),
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
