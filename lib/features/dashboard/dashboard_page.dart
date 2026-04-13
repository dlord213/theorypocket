import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:theorypocket/app/router.dart';
import 'package:theorypocket/app/theme.dart';
import 'package:theorypocket/features/dashboard/widgets/feature_card.dart';


class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: AppColors.background.withOpacity(0.92),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: AppColors.background),
            ),
            title: Row(
              children: [
                Text(
                  'TheoryPocket',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [],
          ),

          // ── Content ──────────────────────────────────────────────
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),

              // Feature cards — large main card (Circle of Fifths)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FeatureCard(
                  title: 'Circle of Fifths',
                  subtitle:
                      'Visualize key relationships & navigate tonality interactively',
                  badge: 'INTERACTIVE',
                  emoji: '🎡',
                  gradientColors: AppColors.gradientCard1,
                  animationIndex: 0,
                  onTap: () => context.push(AppRoutes.circle),
                ),
              ),
              const SizedBox(height: 12),

              // Two smaller cards side-by-side
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _SmallFeatureCard(
                        title: 'Chord\nDictionary',
                        subtitle: 'Lookup & hear any chord',
                        badge: '🎸',
                        gradientColors: AppColors.gradientCard2,
                        onTap: () => context.push(AppRoutes.chords),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SmallFeatureCard(
                        title: 'Progression\nBuilder',
                        subtitle: 'Compose & save sequences',
                        badge: '🎼',
                        gradientColors: AppColors.gradientCard3,
                        onTap: () => context.push(AppRoutes.progression),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Daily tip
              _DailyTipCard(),
              const SizedBox(height: 28),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Small Feature Card ────────────────────────────────────────────────────────

class _SmallFeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String badge;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _SmallFeatureCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_SmallFeatureCard> createState() => _SmallFeatureCardState();
}

class _SmallFeatureCardState extends State<_SmallFeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) async {
          await _pressCtrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.first.withOpacity(0.3),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -10,
                right: -10,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.badge, style: const TextStyle(fontSize: 24)),
                  const Spacer(),
                  Text(
                    widget.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.72),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Daily Tip Card ────────────────────────────────────────────────────────────

class _DailyTipCard extends StatelessWidget {
  const _DailyTipCard();

  static const _tips = [
    'The Circle of Fifths helps you find closely related keys — adjacent keys share 6 out of 7 notes!',
    'A ii-V-I progression is the most common sequence in jazz. Try it in C: Dm7 → G7 → Cmaj7.',
    'The relative minor key shares the same key signature as its major. C major → A minor.',
    'Suspended chords (sus2, sus4) create tension perfect for dramatic moments in progressions.',
  ];

  String get _tip {
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year))
        .inDays;
    return _tips[dayOfYear % _tips.length];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.15),
              AppColors.primaryDark.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('💡', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Theory Tip',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLight,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _tip,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
