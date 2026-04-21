import 'package:flutter/material.dart';
import 'package:cuzzycrewstore/utils/colorUtils.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isDesktop = width >= 1100;
    final isTablet = width >= 700 && width < 1100;
    final horizontalPadding = isDesktop ? 54.0 : (isTablet ? 28.0 : 16.0);
    final maxContentWidth = isDesktop ? 1220.0 : 900.0;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;
    final softColor =
        isDark ? AppColors.amber300.withValues(alpha: 0.86) : AppColors.ink700;
    final heroBackground =
        isDark
            ? const LinearGradient(
              colors: [Color(0xFF1A0800), Color(0xFF2D1400)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
            : const LinearGradient(
              colors: [Color(0xFFFFF8EE), Color(0xFFFFE4BA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        left: false,
        right: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PinstripePainter(
                  stripeColor:
                      isDark
                          ? AppColors.amber600.withValues(alpha: 0.10)
                          : AppColors.amber800.withValues(alpha: 0.08),
                  weaveColor:
                      isDark
                          ? AppColors.amber900.withValues(alpha: 0.12)
                          : AppColors.amber800.withValues(alpha: 0.08),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isDesktop ? 28 : 20,
                      horizontalPadding,
                      28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: heroBackground,
                            border: Border.all(
                              color:
                                  isDark
                                      ? AppColors.amber800
                                      : AppColors.lightBorder,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    isDark
                                        ? AppColors.amber900
                                        : AppColors.ink950,
                                offset: const Offset(6, 6),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(isDesktop ? 26 : 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Badge(isDark: isDark),
                                const SizedBox(height: 18),
                                Text(
                                  'SHARIKH NAVEED',
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    fontSize:
                                        isDesktop
                                            ? 76
                                            : (isTablet ? 56 : width * 0.14),
                                    height: 0.92,
                                    letterSpacing: isDesktop ? 5.5 : 3,
                                    color:
                                        isDark
                                            ? AppColors.amber400
                                            : AppColors.amber800,
                                  ),
                                ),
                                Text(
                                  'THE CUZZY HIMSELF',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: bodyColor,
                                    fontSize: isDesktop ? 28 : 22,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Pakistani creator. Distinct voice. A loyal community around Cuzzy Crew.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: softColor,
                                    height: 1.6,
                                    fontSize: isDesktop ? 14 : 13,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: const [
                                    _StatChip(label: '69.7K Followers'),
                                    _StatChip(label: '40+ Countries Reach'),
                                    _StatChip(label: 'Creator-Led Brand'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Expanded(
                                child: _InfoCard(
                                  title: 'ABOUT',
                                  body: _aboutIntro,
                                  icon: Icons.auto_awesome,
                                ),
                              ),
                              SizedBox(width: 18),
                              Expanded(
                                child: _InfoCard(
                                  title: 'LET\'S BUILD',
                                  body: _letsBuild,
                                  icon: Icons.campaign,
                                ),
                              ),
                            ],
                          )
                        else
                          const Column(
                            children: [
                              _InfoCard(
                                title: 'ABOUT',
                                body: _aboutIntro,
                                icon: Icons.auto_awesome,
                              ),
                              SizedBox(height: 16),
                              _InfoCard(
                                title: 'LET\'S BUILD',
                                body: _letsBuild,
                                icon: Icons.campaign,
                              ),
                            ],
                          ),
                        const SizedBox(height: 18),
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Expanded(
                                child: _InfoCard(
                                  title: 'FIND ME EVERYWHERE',
                                  body:
                                      'Instagram @sharikh_naveed\nPrimary platform with a high-engagement audience.\n\nLinktree\nlinktr.ee/sharikh_naveed',
                                  icon: Icons.public,
                                ),
                              ),
                              SizedBox(width: 18),
                              Expanded(
                                child: _InfoCard(
                                  title: 'CONTACT / MANAGEMENT',
                                  body:
                                      'Managed by @saadahmedbhatti and @juggernautmediapr\n\nFor campaign collaborations and brand partnerships, reach out through management.',
                                  icon: Icons.alternate_email,
                                ),
                              ),
                            ],
                          )
                        else
                          const Column(
                            children: [
                              _InfoCard(
                                title: 'FIND ME EVERYWHERE',
                                body:
                                    'Instagram @sharikh_naveed\nPrimary platform with a high-engagement audience.\n\nLinktree\nlinktr.ee/sharikh_naveed',
                                icon: Icons.public,
                              ),
                              SizedBox(height: 16),
                              _InfoCard(
                                title: 'CONTACT / MANAGEMENT',
                                body:
                                    'Managed by @saadahmedbhatti and @juggernautmediapr\n\nFor campaign collaborations and brand partnerships, reach out through management.',
                                icon: Icons.alternate_email,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? AppColors.ink950 : AppColors.amber100,
        border: Border.all(
          color: isDark ? AppColors.amber700 : AppColors.ink950,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.amber900 : AppColors.ink950,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Text(
        'CREATOR   PAKISTAN   EST. CUZZY CREW',
        style: theme.textTheme.labelMedium?.copyWith(
          letterSpacing: 1.3,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.amber400 : AppColors.ink950,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.amber100,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: isDark ? AppColors.amber200 : AppColors.ink950,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bodyColor = isDark ? AppColors.darkText : AppColors.lightText;
    final softColor =
        isDark ? AppColors.amber300.withValues(alpha: 0.86) : AppColors.ink700;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.amber900 : AppColors.ink950,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: bodyColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: softColor,
              height: 1.65,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PinstripePainter extends CustomPainter {
  const _PinstripePainter({
    required this.stripeColor,
    required this.weaveColor,
  });

  final Color stripeColor;
  final Color weaveColor;

  @override
  void paint(Canvas canvas, Size size) {
    final stripePaint = Paint()..color = stripeColor;
    final weavePaint =
        Paint()
          ..color = weaveColor
          ..strokeWidth = 1;

    const stripeGap = 22.0;
    for (double x = 0; x <= size.width; x += stripeGap) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 1, size.height), stripePaint);
    }

    const weaveGap = 36.0;
    for (double x = -size.height; x < size.width; x += weaveGap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        weavePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PinstripePainter oldDelegate) {
    return oldDelegate.stripeColor != stripeColor ||
        oldDelegate.weaveColor != weaveColor;
  }
}

const String _aboutIntro =
    'Sharikh Naveed is a Pakistani content creator with a growing community of nearly 70K followers on Instagram — built on authentic personality, sharp style, and a vibe that\'s unmistakably his own. Known for his signature catchphrase "Hayadun, cuzzy?", Sharikh has cultivated a loyal community around the Cuzzy Crew — a brand identity as bold and distinctive as the creator himself.';

const String _letsBuild =
    'Got a brand, product, or campaign you want to push to a real, engaged Pakistani audience? Let\'s talk. The Cuzzy Crew doesn\'t take just any deal — it takes the right ones.';
