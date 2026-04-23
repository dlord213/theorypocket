import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:theorypocket/app/router.dart';
import 'package:theorypocket/features/dashboard/widgets/daily_tip_card.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
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
                backgroundColor: colorScheme.surface.withOpacity(0.88),
                surfaceTintColor: Colors.transparent,
                title: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.45),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(child: Icon(LucideIcons.music)),
                    ),
                    const SizedBox(width: 10),
                    ShaderMask(
                      shaderCallback: (b) => LinearGradient(
                        colors: [
                          colorScheme.onSurface,
                          colorScheme.primaryContainer,
                        ],
                        stops: const [0.4, 1.0],
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
                          gradientColors: [
                            colorScheme.primary,
                            colorScheme.secondary,
                          ],
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
                                  gradientColors: [
                                    colorScheme.tertiary,
                                    colorScheme.secondary,
                                  ],
                                  onTap: () => context.push(AppRoutes.chords),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _CompactCard(
                                  title: 'Progression\nBuilder',
                                  subtitle: 'Compose & save sequences',
                                  emoji: '🎼',
                                  gradientColors: [
                                    colorScheme.secondary,
                                    colorScheme.primary,
                                  ],
                                  onTap: () =>
                                      context.push(AppRoutes.progression),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Metronome — full-width compact card
                    FadeTransition(
                      opacity: _fade(0.55, 0.90),
                      child: SlideTransition(
                        position: _slide(0.55, 0.90),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _MetronomeCard(
                            onTap: () => context.push(AppRoutes.metronome),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Polyrhythm — full-width compact card
                    FadeTransition(
                      opacity: _fade(0.65, 0.95),
                      child: SlideTransition(
                        position: _slide(0.65, 0.95),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _PolyrhythmCard(
                            onTap: () => context.push(AppRoutes.polyrhythm),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tuner — full-width compact card
                    // FadeTransition(
                    //   opacity: _fade(0.75, 1.0),
                    //   child: SlideTransition(
                    //     position: _slide(0.75, 1.0),
                    //     child: Padding(
                    //       padding: const EdgeInsets.symmetric(horizontal: 20),
                    //       child: _TunerCard(
                    //         onTap: () => context.push(AppRoutes.tuner),
                    //       ),
                    //     ),
                    //   ),
                    // ),
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

// ── Metronome Card ────────────────────────────────────────────────────────────

class _MetronomeCard extends StatefulWidget {
  final VoidCallback onTap;
  const _MetronomeCard({required this.onTap});

  @override
  State<_MetronomeCard> createState() => _MetronomeCardState();
}

class _MetronomeCardState extends State<_MetronomeCard>
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
          height: 82,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF43F5E), Color(0xFF7C3AED)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF43F5E).withOpacity(0.32),
                blurRadius: 20,
                offset: const Offset(0, 6),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative orb
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.access_time_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Metronome & Tap Tempo',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Set BPM with a slider or tap to feel the beat',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.70),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Polyrhythm Card ───────────────────────────────────────────────────────────

class _PolyrhythmCard extends StatefulWidget {
  final VoidCallback onTap;
  const _PolyrhythmCard({required this.onTap});

  @override
  State<_PolyrhythmCard> createState() => _PolyrhythmCardState();
}

class _PolyrhythmCardState extends State<_PolyrhythmCard>
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
          height: 82,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.tertiary,
                Theme.of(context).colorScheme.primary,
              ], // Teal to deep cyan/blue
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.32),
                blurRadius: 20,
                offset: const Offset(0, 6),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative orb
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.blur_circular_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Polyrhythm Generator',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Layer rhythms and visualize complex meters',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.70),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tuner Card ──────────────────────────────────────────────────────────────────

class _TunerCard extends StatefulWidget {
  final VoidCallback onTap;
  const _TunerCard({required this.onTap});

  @override
  State<_TunerCard> createState() => _TunerCardState();
}

class _TunerCardState extends State<_TunerCard>
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
          height: 82,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFEAB308),
                Color(0xFF10B981),
              ], // Yellow to Emerald
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.32),
                blurRadius: 20,
                offset: const Offset(0, 6),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative orb
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.mic_external_on_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chromatic Tuner',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Instantly check pitch perfectly',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.70),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
            child: _Blob(
              size: 300,
              color: Theme.of(context).colorScheme.primary,
              opacity: 0.16,
            ),
          ),
          Positioned(
            top: 130,
            right: -90,
            child: _Blob(
              size: 240,
              color: Theme.of(context).colorScheme.secondary,
              opacity: 0.10,
            ),
          ),
          Positioned(
            bottom: 200,
            left: -60,
            child: _Blob(
              size: 200,
              color: Theme.of(context).colorScheme.tertiary,
              opacity: 0.07,
            ),
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
                Text(
                  'Learn theory\nthe smart way.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Interactive tools for every musician.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.8),
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
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
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
              color: Theme.of(context).colorScheme.onSurface,
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
