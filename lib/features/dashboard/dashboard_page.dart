import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theorypocket/app/router.dart';
import 'package:theorypocket/app/theme.dart';

// ── Page ──────────────────────────────────────────────────────────────────────

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _entry;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  Animation<double> _fade(double from, double to) => CurvedAnimation(
    parent: _entry,
    curve: Interval(from, to, curve: Curves.easeOut),
  );

  Animation<Offset> _slide(double from, double to) =>
      Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _entry,
          curve: Interval(from, to, curve: Curves.easeOut),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background glows ─────────────────────────────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App Bar ───────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                expandedHeight: 0,
                backgroundColor: AppColors.background.withOpacity(0.88),
                surfaceTintColor: Colors.transparent,
                title: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.gradientPrimary,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.45),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '♩',
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: [AppColors.textPrimary, AppColors.primaryLight],
                        stops: [0.4, 1.0],
                      ).createShader(b),
                      child: Text(
                        'TheoryPocket',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ──────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 48),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Hero banner
                    FadeTransition(
                      opacity: _fade(0.0, 0.5),
                      child: SlideTransition(
                        position: _slide(0.0, 0.55),
                        child: const _HeroBanner(),
                      ),
                    ),

                    // Section label
                    FadeTransition(
                      opacity: _fade(0.2, 0.65),
                      child: const _SectionHeader(label: 'Explore'),
                    ),

                    // Circle of Fifths — hero card
                    FadeTransition(
                      opacity: _fade(0.3, 0.75),
                      child: SlideTransition(
                        position: _slide(0.3, 0.75),
                        child: _HeroFeatureCard(
                          title: 'Circle of Fifths',
                          subtitle:
                              'Visualize key relationships & navigate tonality interactively',
                          emoji: '🎡',
                          badge: 'INTERACTIVE',
                          gradientColors: AppColors.gradientCard1,
                          onTap: () => context.push(AppRoutes.circle),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Two compact cards
                    FadeTransition(
                      opacity: _fade(0.45, 0.85),
                      child: SlideTransition(
                        position: _slide(0.45, 0.85),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: _CompactCard(
                                  title: 'Chord\nDictionary',
                                  subtitle: 'Lookup & hear any chord',
                                  emoji: '🎸',
                                  gradientColors: AppColors.gradientCard2,
                                  onTap: () => context.push(AppRoutes.chords),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _CompactCard(
                                  title: 'Progression\nBuilder',
                                  subtitle: 'Compose & save sequences',
                                  emoji: '🎼',
                                  gradientColors: AppColors.gradientCard3,
                                  onTap: () =>
                                      context.push(AppRoutes.progression),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Daily tip
                    FadeTransition(
                      opacity: _fade(0.6, 1.0),
                      child: const _DailyTipCard(),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Ambient background glows ──────────────────────────────────────────────────

class _AmbientGlows extends StatelessWidget {
  const _AmbientGlows();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -90,
            left: -70,
            child: _Blob(size: 300, color: AppColors.primary, opacity: 0.16),
          ),
          Positioned(
            top: 130,
            right: -90,
            child: _Blob(size: 240, color: AppColors.secondary, opacity: 0.10),
          ),
          Positioned(
            bottom: 200,
            left: -60,
            child: _Blob(size: 200, color: AppColors.teal, opacity: 0.07),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _Blob({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), Colors.transparent],
        ),
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pill label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.32),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'MUSIC THEORY',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryLight,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Learn theory\nthe smart way.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Interactive tools for every musician.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Decorative mini circle of fifths
          SizedBox(
            width: 92,
            height: 92,
            child: CustomPaint(painter: _MiniCirclePainter()),
          ),
        ],
      ),
    );
  }
}

// ── Mini decorative circle painter ───────────────────────────────────────────

class _MiniCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const notes = 12;

    for (int i = 0; i < notes; i++) {
      final angle = (2 * math.pi / notes) * i - math.pi / 2;
      final frac = i / notes;
      final color = Color.lerp(
        const Color(0xFF7C3AED),
        const Color(0xFFF59E0B),
        frac,
      )!;

      // Outer ring dots
      final r1 = size.width * 0.44;
      final x1 = cx + r1 * math.cos(angle);
      final y1 = cy + r1 * math.sin(angle);
      canvas.drawCircle(
        Offset(x1, y1),
        4.5,
        Paint()..color = color.withOpacity(0.85),
      );

      // Inner ring dots (offset by half a step)
      final r2 = size.width * 0.27;
      final ia = angle + (math.pi / notes);
      final x2 = cx + r2 * math.cos(ia);
      final y2 = cy + r2 * math.sin(ia);
      canvas.drawCircle(
        Offset(x2, y2),
        2.6,
        Paint()..color = color.withOpacity(0.4),
      );
    }

    // Center glow dot
    final centerPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF9D5FF5), Color(0xFF5B21B6)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 6));
    canvas.drawCircle(Offset(cx, cy), 6, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          Container(
            width: 3.5,
            height: 17,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.gradientPrimary,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Feature Card (Circle of Fifths) ──────────────────────────────────────

class _HeroFeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final String badge;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _HeroFeatureCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.badge,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_HeroFeatureCard> createState() => _HeroFeatureCardState();
}

class _HeroFeatureCardState extends State<_HeroFeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown: (_) => _ctrl.forward(),
          onTapUp: (_) async {
            await _ctrl.reverse();
            widget.onTap();
          },
          onTapCancel: () => _ctrl.reverse(),
          child: Container(
            height: 192,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.gradientColors.first.withOpacity(0.45),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative orbs
                Positioned(
                  right: -45,
                  top: -45,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.07),
                    ),
                  ),
                ),
                Positioned(
                  right: 15,
                  bottom: -55,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.04),
                    ),
                  ),
                ),
                // Mini circle of fifths decorative graphic top-right
                Positioned(
                  right: 18,
                  top: 14,
                  child: Opacity(
                    opacity: 0.5,
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: CustomPaint(painter: _MiniCirclePainter()),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          widget.badge,
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Emoji + title
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.subtitle,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.70),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 0.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ],
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

// ── Compact Card ──────────────────────────────────────────────────────────────

class _CompactCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _CompactCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_CompactCard> createState() => _CompactCardState();
}

class _CompactCardState extends State<_CompactCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) async {
          await _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          height: 152,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.first.withOpacity(0.38),
                blurRadius: 20,
                offset: const Offset(0, 7),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.emoji, style: const TextStyle(fontSize: 26)),
                    const Spacer(),
                    Text(
                      widget.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.70),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 11,
                right: 11,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
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
    'The Circle of Fifths shows which keys are closely related — adjacent keys share 6 out of 7 notes!',
    'A ii–V–I progression is the backbone of jazz. Try it in C: Dm7 → G7 → Cmaj7.',
    'The relative minor shares the same key signature as its major. C major ↔ A minor.',
    'Suspended chords (sus2, sus4) create unresolved tension — perfect for cinematic moments.',
  ];

  String get _tip {
    final day = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return _tips[day % _tips.length];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 18, 18, 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient left stripe
            Container(
              width: 4,
              height: 56,
              margin: const EdgeInsets.only(left: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.gradientSecondary,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(
                        'DAILY TIP',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _tip,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.55,
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
