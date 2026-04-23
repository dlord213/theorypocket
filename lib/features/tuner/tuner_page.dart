import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Note: requested fftea package included for future manual FFT analysis.
import 'package:fftea/fftea.dart';

class TunerPage extends StatefulWidget {
  const TunerPage({super.key});

  @override
  State<TunerPage> createState() => _TunerPageState();
}

class _TunerPageState extends State<TunerPage> {
  StreamSubscription<double>? _pitchSubscription;
  double _currentFreq = 0.0;
  // ignore: unused_field
  bool _isListening = false;

  // ignore: unused_field
  final FFT _dummyFft = FFT(1024); // Kept initialized as per requirements

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _pitchSubscription?.cancel();
    super.dispose();
  }

  void _startListening() {
    setState(() => _isListening = true);
  }

  // ── Pitch Math ─────────────────────────────────────────────────────────────

  static const List<String> _noteNames = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];

  _PitchData _calculatePitch(double frequency) {
    if (frequency <= 0) {
      return _PitchData(noteName: '--', octave: 0, cents: 0, freq: 0);
    }

    // n = 12 * log2(f/440) + 69
    final double noteFull = 12 * (math.log(frequency / 440) / math.ln2) + 69;
    final int noteRounded = noteFull.round();
    final double cents = (noteFull - noteRounded) * 100;

    final int pitchClass = noteRounded % 12;
    // MIDI note 12 = C0, so octave is floor(n / 12) - 1
    final int octave = (noteRounded / 12).floor() - 1;

    // Handle out of bounds safely
    final validClass = pitchClass < 0 ? 0 : pitchClass;

    return _PitchData(
      noteName: _noteNames[validClass],
      octave: octave,
      cents: cents.round(), // Rounded to nearest cent
      freq: frequency,
    );
  }

  // ── UI Logic ───────────────────────────────────────────────────────────────

  Color _getColorForOffset(int cents, BuildContext context) {
    if (cents == 0 && _currentFreq == 0)
      return Theme.of(context).colorScheme.outline.withOpacity(0.5);

    final absCents = cents.abs();

    if (absCents <= 5) {
      // Massive satisfying GREEN for perfect tune
      return const Color(0xFF10B981); // Emerald Green
    } else if (absCents <= 20) {
      // Yellow for getting close
      return const Color(0xFFF59E0B); // Amber
    } else {
      // Red for out of tune
      return const Color(0xFFEF4444); // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    final pitch = _calculatePitch(_currentFreq);
    final themeColor = _getColorForOffset(pitch.cents, context);

    // Provide a smooth needle value
    final needleValue = (pitch.cents / 50.0).clamp(-1.0, 1.0); // -1.0 to 1.0

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: Theme.of(context).colorScheme.onSurface,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Chromatic Tuner',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music_rounded),
            color: Theme.of(context).colorScheme.onSurface,
            tooltip: 'Alternate Tunings',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const _TuningsModal(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.5,
              colors: [
                themeColor.withOpacity(0.15),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // ── Dial Indicator ──────────────────────────────────────────────
              SizedBox(
                height: 250,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: needleValue),
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutCirc,
                  builder: (context, value, child) {
                    return CustomPaint(
                      size: const Size(double.infinity, 250),
                      painter: _TunerDialPainter(
                        needleValue: value,
                        color: themeColor,
                        colorScheme: Theme.of(context).colorScheme,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ── Target Note Display ───────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pitch.noteName,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 120,
                      fontWeight: FontWeight.w800,
                      color: pitch.freq > 0
                          ? themeColor
                          : Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                      height: 1.0,
                    ),
                  ),
                  if (pitch.freq > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        pitch.octave.toString(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: themeColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Cents ─────────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: pitch.freq > 0
                      ? themeColor.withOpacity(0.1)
                      : Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: pitch.freq > 0
                        ? themeColor.withOpacity(0.3)
                        : Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  pitch.freq > 0
                      ? '${pitch.cents > 0 ? '+' : ''}${pitch.cents} cents'
                      : 'Waiting for sound...',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: pitch.freq > 0
                        ? themeColor
                        : Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Frequency readout
              Text(
                pitch.freq > 0 ? '${pitch.freq.toStringAsFixed(1)} Hz' : '',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pitch Data Model ─────────────────────────────────────────────────────────

class _PitchData {
  final String noteName;
  final int octave;
  final int cents;
  final double freq;

  _PitchData({
    required this.noteName,
    required this.octave,
    required this.cents,
    required this.freq,
  });
}

// ── Dial Painter ─────────────────────────────────────────────────────────────

class _TunerDialPainter extends CustomPainter {
  final double needleValue; // -1 (flat) to +1 (sharp)
  final Color color;
  final ColorScheme colorScheme;

  _TunerDialPainter({
    required this.needleValue,
    required this.color,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height; // Pivot at the bottom of the canvas
    final radius = size.height * 0.9;

    // Background track
    final trackPaint = Paint()
      ..color = colorScheme.surfaceContainerHigh
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Draw arc from -60 degrees to +60 degrees
    const startAngle = -math.pi / 2 - math.pi / 3;
    const sweepAngle = (2 * math.pi) / 3;

    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);

    // Draw little tick marks
    for (int i = -50; i <= 50; i += 10) {
      final valFrac = i / 50.0;
      final angle = -math.pi / 2 + (valFrac * math.pi / 3);

      final isMajor = i == 0 || i == -50 || i == 50;
      final length = isMajor ? 20.0 : 10.0;
      final tColor = isMajor
          ? colorScheme.onSurfaceVariant
          : colorScheme.outline.withOpacity(0.5);

      final p1 = Offset(
        cx + (radius - length) * math.cos(angle),
        cy + (radius - length) * math.sin(angle),
      );
      final p2 = Offset(
        cx + (radius + 5) * math.cos(angle),
        cy + (radius + 5) * math.sin(angle),
      );

      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = tColor
          ..strokeWidth = isMajor ? 3.0 : 2.0
          ..strokeCap = StrokeCap.round,
      );
    }

    // Needle
    final needleAngle = -math.pi / 2 + (needleValue * math.pi / 3);
    final needlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(cx, cy),
      Offset(
        cx + (radius - 15) * math.cos(needleAngle),
        cy + (radius - 15) * math.sin(needleAngle),
      ),
      needlePaint,
    );

    // Pivot dot
    canvas.drawCircle(Offset(cx, cy), 12.0, Paint()..color = color);
    canvas.drawCircle(
      Offset(cx, cy),
      6.0,
      Paint()..color = colorScheme.surface,
    );
  }

  @override
  bool shouldRepaint(covariant _TunerDialPainter old) {
    return needleValue != old.needleValue || color != old.color;
  }
}

// ── Alternate Tunings Database ───────────────────────────────────────────────

class GuitarTuning {
  final String name;
  final String category;
  final List<String> notes; // Low E string to High E string

  const GuitarTuning({
    required this.name,
    required this.category,
    required this.notes,
  });
}

const List<GuitarTuning> _guitarTunings = [
  // Standard & Drops
  GuitarTuning(
    name: 'Standard E',
    category: 'Standard & Drop',
    notes: ['E2', 'A2', 'D3', 'G3', 'B3', 'E4'],
  ),
  GuitarTuning(
    name: 'Drop D',
    category: 'Standard & Drop',
    notes: ['D2', 'A2', 'D3', 'G3', 'B3', 'E4'],
  ),
  GuitarTuning(
    name: 'Drop C',
    category: 'Standard & Drop',
    notes: ['C2', 'G2', 'C3', 'F3', 'A3', 'D4'],
  ),
  GuitarTuning(
    name: 'Drop B',
    category: 'Standard & Drop',
    notes: ['B1', 'F#2', 'B2', 'E3', 'G#3', 'C#4'],
  ),
  GuitarTuning(
    name: 'D Standard',
    category: 'Standard & Drop',
    notes: ['D2', 'G2', 'C3', 'F3', 'A3', 'D4'],
  ),
  GuitarTuning(
    name: 'Eb Standard',
    category: 'Standard & Drop',
    notes: ['D#2', 'G#2', 'C#3', 'F#3', 'A#3', 'D#4'],
  ),
  // Open
  GuitarTuning(
    name: 'Open D',
    category: 'Open',
    notes: ['D2', 'A2', 'D3', 'F#3', 'A3', 'D4'],
  ),
  GuitarTuning(
    name: 'Open G',
    category: 'Open',
    notes: ['D2', 'G2', 'D3', 'G3', 'B3', 'D4'],
  ),
  GuitarTuning(
    name: 'Open C',
    category: 'Open',
    notes: ['C2', 'G2', 'C3', 'G3', 'C4', 'E4'],
  ),
  GuitarTuning(
    name: 'Open E',
    category: 'Open',
    notes: ['E2', 'B2', 'E3', 'G#3', 'B3', 'E4'],
  ),
  GuitarTuning(
    name: 'Open A',
    category: 'Open',
    notes: ['E2', 'A2', 'C#3', 'E3', 'A3', 'E4'],
  ),
  // Modal & Others
  GuitarTuning(
    name: 'DADGAD',
    category: 'Modal',
    notes: ['D2', 'A2', 'D3', 'G3', 'A3', 'D4'],
  ),
  GuitarTuning(
    name: 'DADDAD',
    category: 'Modal',
    notes: ['D2', 'A2', 'D3', 'D4', 'A4', 'D5'],
  ),
  GuitarTuning(
    name: 'CGCGCE',
    category: 'Modal',
    notes: ['C2', 'G2', 'C3', 'G3', 'C4', 'E4'],
  ),
  GuitarTuning(
    name: 'All Fourths',
    category: 'Modal',
    notes: ['E2', 'A2', 'D3', 'G3', 'C4', 'F4'],
  ),
];

// ── Alternate Tunings UI ─────────────────────────────────────────────────────

class _TuningsModal extends StatefulWidget {
  const _TuningsModal();

  @override
  State<_TuningsModal> createState() => _TuningsModalState();
}

class _TuningsModalState extends State<_TuningsModal> {
  String _searchQuery = '';
  GuitarTuning _selectedTuning = _guitarTunings.first;

  @override
  Widget build(BuildContext context) {
    final filteredTunings = _guitarTunings
        .where((t) => t.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // Grouping
    final Map<String, List<GuitarTuning>> grouped = {};
    for (var t in filteredTunings) {
      grouped.putIfAbsent(t.category, () => []).add(t);
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alternate Tunings',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: GoogleFonts.inter(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search tunings...',
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.8),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.8),
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Fretboard Visualizer
                  _FretboardVisualizer(tuning: _selectedTuning),

                  const SizedBox(height: 24),
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.5),
                  ),

                  // List of tunings
                  Expanded(
                    child: ListView.builder(
                      itemCount: grouped.keys.length,
                      itemBuilder: (context, index) {
                        final category = grouped.keys.elementAt(index);
                        final tunings = grouped[category]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                category,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            ...tunings.map(
                              (t) => _TuningTile(
                                tuning: t,
                                isSelected: _selectedTuning == t,
                                onTap: () =>
                                    setState(() => _selectedTuning = t),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TuningTile extends StatelessWidget {
  final GuitarTuning tuning;
  final bool isSelected;
  final VoidCallback onTap;

  const _TuningTile({
    required this.tuning,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.surfaceContainerHigh
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                tuning.name,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              tuning.notes.join(' - '),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.8),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              )
            else
              const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}

class _FretboardVisualizer extends StatelessWidget {
  final GuitarTuning tuning;

  const _FretboardVisualizer({required this.tuning});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Dark wood-like tint
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Nut
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: Container(
              width: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB), // Bone nut
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Fret wires (decorative)
          for (int i = 1; i <= 3; i++)
            Positioned(
              left: 20 + i * 80.0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                color: const Color(0xFF4B5563), // Steel fret
              ),
            ),

          // Strings and Notes
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              // Usually the list is Low E to High E.
              // To display them like reading tabs (high string on top), we reverse the logic.
              final strIndex = 5 - index;
              final strWeight =
                  1.0 + (strIndex * 0.6); // Lower strings are thicker
              final noteStr = tuning.notes[strIndex];

              return Expanded(
                child: Row(
                  children: [
                    // Note label pill
                    Container(
                      width: 48,
                      margin: const EdgeInsets.only(left: 36),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (w, anim) =>
                            ScaleTransition(scale: anim, child: w),
                        child: Container(
                          key: ValueKey<String>('\${strIndex}_\$noteStr'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            noteStr,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                    // The String
                    Expanded(
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: strWeight,
                            color: Colors.white.withOpacity(0.4),
                          ),
                          // Subtle shadow to make the string pop
                          Container(
                            height: strWeight,
                            margin: const EdgeInsets.only(top: 1.5),
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
