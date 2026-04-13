import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theorypocket/app/theme.dart';
import 'package:theorypocket/shared/providers/app_state_provider.dart';

class QuickStatsRow extends StatefulWidget {
  final FeatureStats stats;

  const QuickStatsRow({super.key, required this.stats});

  @override
  State<QuickStatsRow> createState() => _QuickStatsRowState();
}

class _QuickStatsRowState extends State<QuickStatsRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _StatTile(
            label: 'Chords',
            sublabel: 'Explored',
            value: widget.stats.chordsExplored,
            icon: '🎸',
            color: AppColors.primary,
            delay: 0.0,
            controller: _controller,
          ),
          const SizedBox(width: 10),
          _StatTile(
            label: 'Keys',
            sublabel: 'Learned',
            value: widget.stats.keysLearned,
            icon: '🎹',
            color: AppColors.secondary,
            delay: 0.15,
            controller: _controller,
          ),
          const SizedBox(width: 10),
          _StatTile(
            label: 'Progressions',
            sublabel: 'Saved',
            value: widget.stats.progressionsSaved,
            icon: '🎼',
            color: AppColors.teal,
            delay: 0.3,
            controller: _controller,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String sublabel;
  final int value;
  final String icon;
  final Color color;
  final double delay;
  final AnimationController controller;

  const _StatTile({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(delay, delay + 0.7, curve: Curves.easeOutCubic),
    );

    return Expanded(
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(animation),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) {
                    final displayed = (value * animation.value).round();
                    return Text(
                      '$displayed',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  sublabel,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.textMuted,
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
