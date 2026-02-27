import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:flutter/material.dart';

class CategoryBoxItem {
  const CategoryBoxItem({required this.title, required this.thumbnail});

  final String title;
  final String thumbnail;
}

class CategoryBoxGrid extends StatelessWidget {
  const CategoryBoxGrid({
    super.key,
    required this.items,
    this.horizontalPadding,
  });

  final List<CategoryBoxItem> items;
  final double? horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 640;
    final isTablet = width >= 640 && width < 1024;

    final int crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);
    final double spacing = isMobile ? 10 : (isTablet ? 14 : 18);
    final double sectionPadding =
        horizontalPadding ?? (isMobile ? 12 : (isTablet ? 18 : 24));
    final double aspectRatio = isMobile ? 0.74 : (isTablet ? 0.78 : 0.82);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sectionPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: aspectRatio,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return CategoryBox(title: item.title, thumbnail: item.thumbnail);
        },
      ),
    );
  }
}

class CategoryBox extends StatelessWidget {
  const CategoryBox({
    super.key,
    required this.title,
    required this.thumbnail,
    this.onTap,
  });

  final String title;
  final String thumbnail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 640;
    final bool isTablet = width >= 640 && width < 1024;

    final double titleSize =
        isMobile ? width * 0.03 : (isTablet ? width * 0.018 : width * 0.012);
    final double radius = isMobile ? 8 : (isTablet ? 10 : 12);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Image.asset(
                  thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) {
                    return Container(
                      color: colorScheme.surface,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image_outlined,
                        size: isMobile ? 24 : 32,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: isMobile ? 6 : 10),
          Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(
              color:
                  theme.brightness == Brightness.dark
                      ? AppColors.darkText
                      : AppColors.lightText,
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
