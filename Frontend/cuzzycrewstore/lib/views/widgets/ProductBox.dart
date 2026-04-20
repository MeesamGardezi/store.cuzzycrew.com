import 'package:cuzzycrewstore/model/productModel.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:cuzzycrewstore/utils/helper.dart';
import 'package:cuzzycrewstore/views/pages/productdetailpage/productDetailPage.dart';
import 'package:cuzzycrewstore/views/widgets/adaptive_image.dart';
import 'package:flutter/material.dart';

class ProductBoxGrid extends StatelessWidget {
  const ProductBoxGrid({super.key, required this.items});

  final List<ProductModel> items;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.02;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == items.length - 1 ? 0 : spacing,
            ),
            child: ProductBox(product: items[index]),
          ),
        );
      }),
    );
  }
}

class ProductBox extends StatefulWidget {
  const ProductBox({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductBox> createState() => _ProductBoxState();
}

class _ProductBoxState extends State<ProductBox> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 640;
    final bool isTablet = width >= 640 && width < 1024;
    final double nameSize = isMobile ? 12 : (isTablet ? 13 : width * 0.01);
    final double priceSize = isMobile ? 11 : (isTablet ? 12 : width * 0.009);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: widget.product),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: 0.72,
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
                          duration: const Duration(milliseconds: 200),
                          opacity: _isHovered ? 1 : 0,
                          child: Container(
                            color: colorScheme.primary.withValues(alpha: 0.26),
                          ),
                        ),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isHovered ? 1 : 0,
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ProductDetailPage(
                                          product: widget.product,
                                        ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryAccent,
                                foregroundColor: AppColors.darkText,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              child: Text(
                                'VIEW PRODUCT',

                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.darkText,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 6 : 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                child: Text(
                  widget.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color:
                        theme.brightness == Brightness.dark
                            ? AppColors.darkText
                            : AppColors.lightText,
                    fontSize: nameSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 8, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatPrice(
                      widget.product.price,
                      currencyCode: widget.product.currency,
                    ),
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryAccent,
                      fontSize: priceSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 6 : 10),
            ],
          ),
        ),
      ),
    );
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
