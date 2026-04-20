import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:cuzzycrewstore/views/widgets/adaptive_image.dart';
import 'package:flutter/material.dart';

class CategoryBoxItem {
  const CategoryBoxItem({
    required this.title,
    required this.thumbnail,
    this.launched = true,
    this.onTap,
  });

  final String title;
  final String thumbnail;
  final bool launched;
  final VoidCallback? onTap;
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
          return CategoryBox(
            title: item.title,
            thumbnail: item.thumbnail,
            launched: item.launched,
            onTap: item.onTap,
          );
        },
      ),
    );
  }
}

class CategoryBox extends StatefulWidget {
  const CategoryBox({
    super.key,
    required this.title,
    required this.thumbnail,
    this.launched = true,
    this.onTap,
  });

  final String title;
  final String thumbnail;
  final bool launched;
  final VoidCallback? onTap;

  @override
  State<CategoryBox> createState() => _CategoryBoxState();
}

class _CategoryBoxState extends State<CategoryBox> {
  bool _isHovered = false;

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
    final effectiveOnTap = widget.launched ? widget.onTap : null;

    return GestureDetector(
      onTap: effectiveOnTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: ClipRRect(
                borderRadius: BorderRadius.zero,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AdaptiveImage(
                        source: widget.thumbnail,
                        fit: BoxFit.cover,
                        fallback: Container(
                          color: colorScheme.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
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
                            onPressed: effectiveOnTap,
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
                              widget.launched ? 'VIEW PAGE' : 'COMING SOON',
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
          ),
          SizedBox(height: isMobile ? 6 : 10),
          Text(
            widget.title.toUpperCase(),
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
