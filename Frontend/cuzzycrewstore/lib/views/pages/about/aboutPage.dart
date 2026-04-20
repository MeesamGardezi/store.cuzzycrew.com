import 'package:flutter/material.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1100) {
      return _DesktopLayout();
    } else if (width >= 700) {
      return _TabletLayout();
    }
    return _MobileLayout();
  }
}

class _DesktopLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final baseWidth = width > 1440 ? 1440.0 : 1280.0;
    final scale = (width / baseWidth).clamp(0.85, 1.2);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        left: false,
        right: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 48 * scale,
              vertical: 40 * scale,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SHARIKH NAVEED',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 40 * scale,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      Text(
                        '✦ CREATOR · PAKISTAN · EST. CUZZY CREW',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 28 * scale),
                      Text(
                        'THE CUZZY HIMSELF',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                      Text(
                        _aboutIntro,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 15 * scale,
                          height: 1.8,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 28 * scale),
                      Text(
                        'FIND ME EVERYWHERE',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                      SizedBox(height: 14 * scale),
                      _buildLink(
                        context,
                        scale,
                        '📸 Instagram @sharikh_naveed',
                        'Primary platform. 69.7K followers.',
                      ),
                      SizedBox(height: 12 * scale),
                      _buildLink(
                        context,
                        scale,
                        '🔗 Linktree',
                        'linktr.ee/sharikh_naveed',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 56 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LET\'S BUILD.',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 28 * scale,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                      Text(
                        _letsBuild,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 15 * scale,
                          height: 1.8,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 28 * scale),
                      Text(
                        'CONTACT / MANAGEMENT',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      SelectableText(
                        'Managed by @saadahmedbhatti · @juggernautmediapr',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14 * scale,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final scale = (width / 768).clamp(0.85, 1.15);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        left: false,
        right: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SHARIKH NAVEED',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 28 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryAccent,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  '✦ CREATOR · PAKISTAN · EST. CUZZY CREW',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontSize: 11 * scale,
                    letterSpacing: 1.2,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 20 * scale),
                Text(
                  'THE CUZZY HIMSELF',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryAccent,
                  ),
                ),
                SizedBox(height: 10 * scale),
                Text(
                  _aboutIntro,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14 * scale,
                    height: 1.7,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 20 * scale),
                Text(
                  'FIND ME EVERYWHERE',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryAccent,
                  ),
                ),
                SizedBox(height: 10 * scale),
                _buildLink(
                  context,
                  scale,
                  '📸 Instagram @sharikh_naveed',
                  'Primary platform. 69.7K followers.',
                ),
                SizedBox(height: 10 * scale),
                _buildLink(
                  context,
                  scale,
                  '🔗 Linktree',
                  'linktr.ee/sharikh_naveed',
                ),
                SizedBox(height: 20 * scale),
                Text(
                  'LET\'S BUILD.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryAccent,
                  ),
                ),
                SizedBox(height: 10 * scale),
                Text(
                  _letsBuild,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13 * scale,
                    height: 1.7,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 20 * scale),
                Text(
                  'CONTACT / MANAGEMENT',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.primaryAccent,
                  ),
                ),
                SizedBox(height: 6 * scale),
                SelectableText(
                  'Managed by @saadahmedbhatti · @juggernautmediapr',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12 * scale,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final scale = (width / 375).clamp(0.85, 1.15);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        left: false,
        right: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 12 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SHARIKH NAVEED',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: width * 0.080,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryAccent,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  '✦ CREATOR · PAKISTAN · EST. CUZZY CREW',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: width * 0.030,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 16 * scale),
                Container(
                  padding: EdgeInsets.only(left: 8 * scale),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: AppColors.primaryAccent,
                        width: 3 * scale,
                      ),
                    ),
                  ),
                  child: Text(
                    'THE CUZZY HIMSELF',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: width * 0.040,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                SizedBox(height: 12 * scale),
                Text(
                  _aboutIntro,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: width * 0.036,
                    height: 1.7,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 20 * scale),
                Container(
                  padding: EdgeInsets.only(left: 8 * scale),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: AppColors.primaryAccent,
                        width: 3 * scale,
                      ),
                    ),
                  ),
                  child: Text(
                    'FIND ME EVERYWHERE',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: width * 0.038,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                SizedBox(height: 12 * scale),
                _buildLink(
                  context,
                  scale,
                  '📸 Instagram @sharikh_naveed',
                  'Primary platform. 69.7K followers.',
                ),
                SizedBox(height: 10 * scale),
                _buildLink(
                  context,
                  scale,
                  '🔗 Linktree',
                  'linktr.ee/sharikh_naveed',
                ),
                SizedBox(height: 20 * scale),
                Container(
                  padding: EdgeInsets.only(left: 8 * scale),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: AppColors.primaryAccent,
                        width: 3 * scale,
                      ),
                    ),
                  ),
                  child: Text(
                    'LET\'S BUILD.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: width * 0.040,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                SizedBox(height: 12 * scale),
                Text(
                  _letsBuild,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: width * 0.034,
                    height: 1.7,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 20 * scale),
                Text(
                  'CONTACT / MANAGEMENT',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: width * 0.032,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.primaryAccent,
                  ),
                ),
                SizedBox(height: 6 * scale),
                SelectableText(
                  'Managed by @saadahmedbhatti · @juggernautmediapr',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: width * 0.032,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 20 * scale),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildLink(
  BuildContext context,
  double scale,
  String title,
  String subtitle,
) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final textColor = isDark ? AppColors.darkText : AppColors.lightText;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 13 * scale,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      SizedBox(height: 3 * scale),
      Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 12 * scale,
          color: AppColors.mutedText,
        ),
      ),
    ],
  );
}

const String _aboutIntro =
    'Sharikh Naveed is a Pakistani content creator with a growing community of nearly 70K followers on Instagram — built on authentic personality, sharp style, and a vibe that\'s unmistakably his own. Known for his signature catchphrase "Hayadun, cuzzy?", Sharikh has cultivated a loyal community around the Cuzzy Crew — a brand identity as bold and distinctive as the creator himself.';

const String _letsBuild =
    'Got a brand, product, or campaign you want to push to a real, engaged Pakistani audience? Let\'s talk. The Cuzzy Crew doesn\'t take just any deal — it takes the right ones.';
