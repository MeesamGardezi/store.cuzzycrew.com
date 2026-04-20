import 'package:cuzzycrewstore/model/productModel.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:cuzzycrewstore/utils/helper.dart';
import 'package:cuzzycrewstore/views/pages/productdetailpage/productDetailPage.dart';
import 'package:cuzzycrewstore/views/widgets/adaptive_image.dart';
import 'package:flutter/material.dart';

class ShopProductCard extends StatefulWidget {
  const ShopProductCard({super.key, required this.product, this.onTap});

  final ProductModel product;
  final VoidCallback? onTap;

  @override
  State<ShopProductCard> createState() => _ShopProductCardState();
}

class _ShopProductCardState extends State<ShopProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final width = MediaQuery.of(context).size.width;
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = width < 640;
    final isTablet = width >= 640 && width < 1024;

    final double titleFontSize = isMobile ? 11 : (isTablet ? 12 : 13);
    final double priceFontSize = isMobile ? 12 : (isTablet ? 13 : 14);
    final double metaFontSize = isMobile ? 9 : (isTablet ? 10 : 11);
    final String? badge = _badgeLabel(widget.product);

    return GestureDetector(
      onTap:
          widget.onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(product: widget.product),
              ),
            );
          },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.zero),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AdaptiveImage(
                        source: widget.product.primaryImage,
                        sources: widget.product.imageCandidates,
                        fit: BoxFit.cover,
                        fallback: _imageFallback(colorScheme),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: _isHovered ? 1 : 0,
                        child: Container(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      if (badge != null)
                        Positioned(
                          left: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            color: _badgeBackground(badge),
                            child: Text(
                              badge,
                              style: textTheme.bodySmall?.copyWith(
                                color:
                                    badge == 'LIMITED'
                                        ? AppColors.lightText
                                        : (isDark
                                            ? AppColors.darkText
                                            : AppColors.lightText),
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        fontSize: titleFontSize,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatPrice(
                      widget.product.price,
                      currencyCode: widget.product.currency,
                    ),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: priceFontSize,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                '${widget.product.shortName.toUpperCase()} / ${widget.product.category.toUpperCase()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.6,
                  fontSize: metaFontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _badgeLabel(ProductModel item) {
    if (!item.launched) {
      return 'SOLD OUT';
    }
    if (item.availableUnits <= 35) {
      return 'LIMITED';
    }
    if (item.isNewArrival) {
      return 'NEW';
    }
    return null;
  }

  Color _badgeBackground(String badge) {
    switch (badge) {
      case 'NEW':
        return AppColors.primaryAccent;
      case 'LIMITED':
        return AppColors.slate400.withValues(alpha: 0.65);
      case 'SOLD OUT':
        return AppColors.slate500.withValues(alpha: 0.72);
      default:
        return AppColors.primaryAccent;
    }
  }

  Widget _imageFallback(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
