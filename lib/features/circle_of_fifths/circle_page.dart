import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:theorypocket/app/theme.dart';
import 'package:theorypocket/features/circle_of_fifths/circle_data.dart';
import 'package:theorypocket/features/circle_of_fifths/circle_painter.dart';
import 'package:theorypocket/features/circle_of_fifths/circle_provider.dart';

// ── Page ──────────────────────────────────────────────────────────────────────

class CirclePage extends ConsumerWidget {
  const CirclePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(circleOfFifthsProvider);
    final notifier = ref.read(circleOfFifthsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [AppColors.primaryLight, AppColors.secondary],
          ).createShader(b),
          child: Text(
            'Circle of Fifths',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          AnimatedOpacity(
            opacity: selection != null ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: TextButton(
              onPressed: notifier.clear,
              child: Text(
                'Clear',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: selection != null
                  ? _KeyBanner(key: ValueKey(selection.index), selection: selection)
                  : _HintBanner(key: const ValueKey('hint')),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = min(constraints.maxWidth, constraints.maxHeight);
                      return _CircleWidget(
                        size: size,
                        selection: selection,
                        onTap: (i, r) => notifier.select(i, r),
                      );
                    },
                  ),
                ),
              ),
            ),
            _DiatonicPanel(selection: selection),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CircleWidget extends StatelessWidget {
  final double size;
  final CircleSelection? selection;
  final void Function(int index, CircleRing ring) onTap;

  const _CircleWidget({
    required this.size,
    required this.selection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final hit = hitTest(details.localPosition, Size(size, size));
        if (hit != null) onTap(hit.index, hit.ring);
      },
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: CircleOfFifthsPainter(selection: selection),
        ),
      ),
    );
  }
}

class _KeyBanner extends StatelessWidget {
  final CircleSelection selection;

  const _KeyBanner({super.key, required this.selection});

  @override
  Widget build(BuildContext context) {
    final isMajor = selection.ring == CircleRing.major;
    final isMinor = selection.ring == CircleRing.minor;

    final keyName = isMajor
        ? '${majorKeys[selection.index]} Major'
        : isMinor
            ? minorKeys[selection.index]
            : dimKeys[selection.index];

    final subtitle = isMajor
        ? 'Relative minor: ${minorKeys[selection.index]}'
        : isMinor
            ? 'Relative major: ${majorKeys[selection.index]}'
            : 'Diminished chord';

    final color = isMajor
        ? AppColors.primary
        : isMinor
            ? AppColors.secondary
            : AppColors.teal;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.30)),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  keyName,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isMajor ? 'MAJOR' : isMinor ? 'MINOR' : 'DIM',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HintBanner extends StatelessWidget {
  const _HintBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👆', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            'Tap any segment to explore',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _DiatonicPanel extends StatelessWidget {
  final CircleSelection? selection;

  const _DiatonicPanel({required this.selection});

  @override
  Widget build(BuildContext context) {
    if (selection == null) return _EmptyPanel();

    final keyIndex = selection!.index;
    final chords = diatonicChords[keyIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(
            children: [
              Text(
                'Diatonic Chords',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '— ${majorKeys[keyIndex]} Major',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 68,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: 7,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final type = chordTypes[i];
              final Color chipColor = type == 0
                  ? AppColors.primary
                  : type == 1
                      ? AppColors.teal
                      : AppColors.rose;
              return _ChordChip(
                numeral: romanNumerals[i],
                chord: chords[i],
                color: chipColor,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Center(
          child: Text(
            'Select a key to see its diatonic chords',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}

class _ChordChip extends StatelessWidget {
  final String numeral;
  final String chord;
  final Color color;

  const _ChordChip({
    required this.numeral,
    required this.chord,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            numeral,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            chord,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
