import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PolyrhythmPage extends StatefulWidget {
  const PolyrhythmPage({super.key});

  @override
  State<PolyrhythmPage> createState() => _PolyrhythmPageState();
}

class _PolyrhythmPageState extends State<PolyrhythmPage>
    with SingleTickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  double _bpm = 30; // Cycles per minute
  bool _isPlaying = false;

  int _innerBeats = 3;
  int _outerBeats = 4;

  int _lastInnerBeat = -1;
  int _lastOuterBeat = -1;

  final AudioPlayer _outerPlayer = AudioPlayer();
  final AudioPlayer _innerPlayer = AudioPlayer();

  // ── Animations ─────────────────────────────────────────────────────────────
  late AnimationController _sweepCtrl;

  @override
  void initState() {
    super.initState();

    _sweepCtrl = AnimationController(vsync: this, duration: _cycleDuration);

    _sweepCtrl.addListener(_onTick);
    _sweepCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _lastInnerBeat = -1;
        _lastOuterBeat = -1;
        if (_isPlaying) {
          _sweepCtrl.forward(from: 0.0);
        }
      }
    });
  }

  @override
  void dispose() {
    _sweepCtrl.dispose();
    _outerPlayer.dispose();
    _innerPlayer.dispose();
    super.dispose();
  }

  Duration get _cycleDuration => Duration(milliseconds: (60000 / _bpm).round());

  void _onTick() {
    if (!_isPlaying) return;

    final val = _sweepCtrl.value;

    // Check outer beats
    final outerBeat = (val * _outerBeats).floor();
    if (outerBeat > _lastOuterBeat) {
      _lastOuterBeat = outerBeat;
      HapticFeedback.lightImpact();
      _outerPlayer.play(AssetSource('sounds/low_beep.wav'));
    }

    // Check inner beats
    final innerBeat = (val * _innerBeats).floor();
    if (innerBeat > _lastInnerBeat) {
      _lastInnerBeat = innerBeat;
      // Slightly heavier impact for inner beat to distinguish (if supported),
      // otherwise standard light impact. Using medium for variety.
      HapticFeedback.mediumImpact();
      _innerPlayer.play(AssetSource('sounds/high_beep.wav'));
    }
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _lastInnerBeat = -1;
      _lastOuterBeat = -1;
      _sweepCtrl.duration = _cycleDuration;
      _sweepCtrl.forward(from: 0.0);
    } else {
      _sweepCtrl.stop();
      // Optionally reset position: _sweepCtrl.value = 0.0;
    }
  }

  void _updateBpm(double newBpm) {
    setState(() => _bpm = newBpm);
    _sweepCtrl.duration = _cycleDuration;
    if (_isPlaying) {
      // Scale current position so sudden jump in value doesn't happen
      final currentPos = _sweepCtrl.value;
      _sweepCtrl.forward(from: currentPos);
    }
  }

  void _nudgeBpm(int delta) => _updateBpm((_bpm + delta).clamp(10, 120));

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: colorScheme.onSurface,
          onPressed: () {
            _sweepCtrl.stop();
            Navigator.of(context).pop();
          },
        ),
        title: ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: [colorScheme.onSurface, colorScheme.tertiary],
            stops: const [0.4, 1.0],
          ).createShader(b),
          child: Text(
            'Polyrhythms',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Explanation Label ──────────────────────────────────────────
            Text(
              '$_outerBeats over $_innerBeats',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Cycles per minute (CPM)',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant.withOpacity(0.8),
              ),
            ),

            const SizedBox(height: 24),

            // ── Radar Visualizer ───────────────────────────────────────────
            Expanded(
              flex: 5,
              child: AnimatedBuilder(
                animation: _sweepCtrl,
                builder: (context, _) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final size = constraints.maxWidth.clamp(0.0, 320.0);
                      return Center(
                        child: CustomPaint(
                          size: Size(size, size),
                          painter: _PolyrhythmPainter(
                            progress: _sweepCtrl.value,
                            innerBeats: _innerBeats,
                            outerBeats: _outerBeats,
                            isPlaying: _isPlaying,
                            colorScheme: colorScheme,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // ── Controls ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Layer pickers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _LayerPicker(
                        label: 'Outer Layer',
                        value: _outerBeats,
                        color: colorScheme.tertiary,
                        onChanged: (v) {
                          setState(() => _outerBeats = v.clamp(1, 16));
                          _lastOuterBeat = -1;
                        },
                      ),
                      Container(
                        width: 1.5,
                        height: 48,
                        color: colorScheme.outline.withOpacity(0.5),
                      ),
                      _LayerPicker(
                        label: 'Inner Layer',
                        value: _innerBeats,
                        color: colorScheme.primary,
                        onChanged: (v) {
                          setState(() => _innerBeats = v.clamp(1, 16));
                          _lastInnerBeat = -1;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // BPM readout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _NudgeButton(
                        icon: Icons.remove_rounded,
                        onTap: () => _nudgeBpm(-1),
                        onLongPress: () => _nudgeBpm(-5),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          Text(
                            _bpm.round().toString(),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 54,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'CPM',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.8,
                              ),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      _NudgeButton(
                        icon: Icons.add_rounded,
                        onTap: () => _nudgeBpm(1),
                        onLongPress: () => _nudgeBpm(5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: colorScheme.tertiary,
                      inactiveTrackColor: colorScheme.outline.withOpacity(0.5),
                      thumbColor: colorScheme.onTertiary,
                      overlayColor: colorScheme.tertiary.withOpacity(0.14),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7,
                      ),
                    ),
                    child: Slider(
                      value: _bpm,
                      min: 10,
                      max: 120,
                      onChanged: _updateBpm,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Play / Stop
                  _PlayStopButton(isPlaying: _isPlaying, onTap: _togglePlay),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Radar Visualizer Painter ──────────────────────────────────────────────────

class _PolyrhythmPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final int innerBeats;
  final int outerBeats;
  final bool isPlaying;
  final ColorScheme colorScheme;

  _PolyrhythmPainter({
    required this.progress,
    required this.innerBeats,
    required this.outerBeats,
    required this.isPlaying,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final maxRadius = size.width / 2;
    final rOuter = maxRadius * 0.85;
    final rInner = maxRadius * 0.55;

    // Draw base ring tracks
    final trackPaint = Paint()
      ..color = colorScheme.outline.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(cx, cy), rOuter, trackPaint);
    canvas.drawCircle(Offset(cx, cy), rInner, trackPaint);

    final currentAngle = progress * 2 * math.pi - math.pi / 2;

    // Draw radar sweep fill
    if (isPlaying || progress > 0) {
      final sweepPaint = Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: -math.pi / 2,
          endAngle: 2 * math.pi - math.pi / 2,
          colors: [
            colorScheme.tertiary.withOpacity(0.0),
            colorScheme.tertiary.withOpacity(0.2),
          ],
          stops: [progress == 0 ? 0.0 : progress - 0.2, progress],
          transform: GradientRotation(-math.pi / 2),
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: rOuter));

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: rOuter),
        -math.pi / 2,
        progress * 2 * math.pi,
        true,
        sweepPaint,
      );

      // Radar line
      final linePaint = Paint()
        ..color = colorScheme.tertiary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawLine(
        Offset(cx, cy),
        Offset(
          cx + rOuter * math.cos(currentAngle),
          cy + rOuter * math.sin(currentAngle),
        ),
        linePaint,
      );
    }

    // Function to calculate pulse fade
    double getFade(double beatFrac) {
      if (!isPlaying && progress == 0) return 0.0;
      double diff = progress - beatFrac;
      if (diff < 0) diff += 1.0;
      return math.max(0.0, 1.0 - (diff * 5.0)); // Fades out over 20% of circle
    }

    // Draw inner beats
    for (int i = 0; i < innerBeats; i++) {
      final beatFrac = i / innerBeats;
      final angle = beatFrac * 2 * math.pi - math.pi / 2;
      final bx = cx + rInner * math.cos(angle);
      final by = cy + rInner * math.sin(angle);

      final fade = getFade(beatFrac);

      // Base dot
      canvas.drawCircle(
        Offset(bx, by),
        5.0,
        Paint()..color = colorScheme.primary,
      );

      // Pulse glow
      if (fade > 0) {
        canvas.drawCircle(
          Offset(bx, by),
          5.0 + (fade * 8.0),
          Paint()..color = colorScheme.primaryContainer.withOpacity(fade * 0.8),
        );
      }
    }

    // Draw outer beats
    for (int i = 0; i < outerBeats; i++) {
      final beatFrac = i / outerBeats;
      final angle = beatFrac * 2 * math.pi - math.pi / 2;
      final bx = cx + rOuter * math.cos(angle);
      final by = cy + rOuter * math.sin(angle);

      final fade = getFade(beatFrac);

      // Base dot
      canvas.drawCircle(
        Offset(bx, by),
        6.0,
        Paint()..color = colorScheme.tertiary,
      );

      // Pulse glow
      if (fade > 0) {
        canvas.drawCircle(
          Offset(bx, by),
          6.0 + (fade * 10.0),
          Paint()
            ..color = colorScheme.tertiaryContainer.withOpacity(fade * 0.8),
        );
      }
    }

    // Center pivot
    canvas.drawCircle(Offset(cx, cy), 4.0, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _PolyrhythmPainter old) {
    return progress != old.progress ||
        innerBeats != old.innerBeats ||
        outerBeats != old.outerBeats ||
        isPlaying != old.isPlaying;
  }
}

// ── Controls ──────────────────────────────────────────────────────────────────

class _LayerPicker extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final ValueChanged<int> onChanged;

  const _LayerPicker({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => onChanged(value - 1),
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.transparent,
                child: Icon(
                  Icons.remove_circle_outline,
                  color: color,
                  size: 24,
                ),
              ),
            ),
            SizedBox(
              width: 32,
              child: Center(
                child: Text(
                  value.toString(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => onChanged(value + 1),
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.transparent,
                child: Icon(Icons.add_circle_outline, color: color, size: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NudgeButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _NudgeButton({
    required this.icon,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }
}

class _PlayStopButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const _PlayStopButton({required this.isPlaying, required this.onTap});

  @override
  State<_PlayStopButton> createState() => _PlayStopButtonState();
}

class _PlayStopButtonState extends State<_PlayStopButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isPlaying
                  ? [const Color(0xFFF43F5E), const Color(0xFFBE123C)]
                  : [
                      Theme.of(context).colorScheme.tertiary,
                      const Color(0xFF0D9488),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color:
                    (widget.isPlaying
                            ? const Color(0xFFF43F5E)
                            : Theme.of(context).colorScheme.tertiary)
                        .withOpacity(0.40),
                blurRadius: 22,
                offset: const Offset(0, 6),
                spreadRadius: -3,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isPlaying
                    ? Icons.stop_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                widget.isPlaying ? 'Stop' : 'Start',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
