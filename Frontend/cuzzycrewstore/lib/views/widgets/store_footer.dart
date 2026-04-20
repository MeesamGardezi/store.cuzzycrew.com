import 'package:cuzzycrewstore/navigation/core/navWrapperController.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';
import 'package:cuzzycrewstore/utils/design_utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreFooter extends StatelessWidget {
  const StoreFooter({super.key});

  static const String _instagramUrl = 'https://instagram.com/sharikh_naveed';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 640;
    final horizontalPadding = width < 900 ? 24.0 : 60.0;
    final topPadding = isMobile ? 24.0 : (width < 900 ? 44.0 : 52.0);
    final bottomPadding = isMobile ? 18.0 : (width < 900 ? 28.0 : 36.0);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: isMobile ? 12 : 28),
      decoration: BoxDecoration(
        color: AppColors.ink950,
        border: Border(top: BorderSide(color: AppColors.amber900, width: 3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              topPadding,
              horizontalPadding,
              bottomPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                      isMobile
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: DesignUtils.topBarLogoStyle(
                                isDark: true,
                                fontSize: isMobile ? 24 : 30,
                              ).copyWith(letterSpacing: 4),
                              children: const [
                                TextSpan(text: 'Cuzzy'),
                                TextSpan(
                                  text: 'Crew',
                                  style: TextStyle(color: AppColors.amber600),
                                ),
                              ],
                            ),
                          ),
                          if (!isMobile) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Est. 2023 · @sharikh_naveed · Il Creatore'
                                  .toUpperCase(),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: AppColors.ink500,
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: isMobile ? 12 : 24),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _FooterActionButton(
                          label: '↗  INSTAGRAM',
                          onTap: () async {
                            final uri = Uri.parse(_instagramUrl);
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                        ),
                        if (!isMobile) ...[
                          const SizedBox(width: 12),
                          _FooterActionButton(
                            label: '↗  CONTACT',
                            onTap:
                                () => NavWrapperController.setSelectedIndex(2),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 12 : 24),
                Container(
                  width: double.infinity,
                  height: 1.5,
                  color: AppColors.amber950,
                ),
                SizedBox(height: isMobile ? 12 : 24),
                if (isMobile)
                  Text(
                    '© 2026 CuzzyCrew. All rights reserved.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.darkSurfaceAlt,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  )
                else
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runSpacing: 12,
                    spacing: 12,
                    children: [
                      Text(
                        '© 2026 CuzzyCrew. All rights reserved.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.darkSurfaceAlt,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Built with taste. Served with respect.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.darkSurfaceAlt,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterActionButton extends StatefulWidget {
  const _FooterActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_FooterActionButton> createState() => _FooterActionButtonState();
}

class _FooterActionButtonState extends State<_FooterActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final shadowOffset = _hovered ? const Offset(3, 3) : const Offset(2, 2);
    final translateOffset = _hovered ? const Offset(-1, -1) : Offset.zero;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Transform.translate(
          offset: translateOffset,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.amber800, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.amber900,
                  offset: shadowOffset,
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.amber600,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
