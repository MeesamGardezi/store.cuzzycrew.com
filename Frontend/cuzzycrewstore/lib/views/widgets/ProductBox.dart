import 'package:cuzzycrewstore/model/productModel.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
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

class ProductBox extends StatelessWidget {
  const ProductBox({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 640;
    final bool isTablet = width >= 640 && width < 1024;
    final double radius = isMobile ? 8 : (isTablet ? 10 : 12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: SizedBox.expand(
                child: Image.asset(
                  product.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) {
                    return Icon(
                      Icons.image_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: width * 0.008),
        SizedBox(
          height: width * 0.013,
          child: Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color:
                  theme.brightness == Brightness.dark
                      ? AppColors.darkText
                      : AppColors.lightText,
              fontSize: width * 0.01,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: width * 0.003),
        SizedBox(
          height: width * 0.013,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryAccent,
                fontSize: width * 0.009,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
