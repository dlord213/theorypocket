import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theorypocket/app/theme.dart';

class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key});

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  double _bpm = 120;
  bool _isPlaying = false;
  Timer? _timer;

  // ── Tap tempo ──────────────────────────────────────────────────────────────
  final List<DateTime> _tapTimes = [];
  static const int _maxTaps = 8;

  // ── Animations ─────────────────────────────────────────────────────────────
  late AnimationController _pulseCtrl;   // outer ring pulse on beat
  late AnimationController _glowCtrl;    // glow fade on beat
  late AnimationController _pendulumCtrl; // pendulum swing left-right
  late Animation<double> _pulseAnim;
  late Animation<double> _glowAnim;

  bool _beatActive = false; // true for 80ms after each beat

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
    _pulseCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) _pulseCtrl.reverse();
    });

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut),
    );
    _glowCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) _glowCtrl.reverse();
    });

    _pendulumCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (60000 / _bpm).round()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    _glowCtrl.dispose();
    _pendulumCtrl.dispose();
    super.dispose();
  }

  // ── Metronome control ──────────────────────────────────────────────────────

  Duration get _beatDuration =>
      Duration(milliseconds: (60000 / _bpm).round());

  void _startMetronome() {
    _timer?.cancel();
    _pendulumCtrl.duration = _beatDuration;
    _pendulumCtrl.repeat(reverse: true);

    _tick(); // immediate first beat
    _timer = Timer.periodic(_beatDuration, (_) => _tick());
  }

  void _stopMetronome() {
    _timer?.cancel();
    _timer = null;
    _pendulumCtrl.stop();
    _pendulumCtrl.animateTo(0.5, duration: const Duration(milliseconds: 300));
  }

  void _tick() {
    if (!mounted) return;
    HapticFeedback.lightImpact();
    _pulseCtrl.forward(from: 0);
    _glowCtrl.forward(from: 0);
    setState(() => _beatActive = true);
    Future.delayed(const Duration(milliseconds: 80),
        () => mounted ? setState(() => _beatActive = false) : null);
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _startMetronome();
    } else {
      _stopMetronome();
    }
  }

  void _updateBpm(double newBpm) {
    setState(() => _bpm = newBpm);
    if (_isPlaying) _startMetronome(); // restart with new tempo
    else {
      _pendulumCtrl.duration = _beatDuration;
    }
  }

  void _nudgeBpm(int delta) => _updateBpm((_bpm + delta).clamp(20, 300));

  // ── Tap Tempo ──────────────────────────────────────────────────────────────

  void _onTap() {
    final now = DateTime.now();
    _tapTimes.add(now);

    // Keep only the last N taps
    if (_tapTimes.length > _maxTaps) _tapTimes.removeAt(0);

    // Need at least 2 taps to compute a tempo
    if (_tapTimes.length >= 2) {
      final intervals = <int>[];
      for (int i = 1; i < _tapTimes.length; i++) {
        intervals.add(
            _tapTimes[i].difference(_tapTimes[i - 1]).inMilliseconds);
      }
      final avgMs = intervals.reduce((a, b) => a + b) / intervals.length;
      final tappedBpm = (60000 / avgMs).clamp(20.0, 300.0);
      _updateBpm(tappedBpm);
    }

    // Reset tap buffer if too long since last tap (> 2.5 seconds)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (_tapTimes.isNotEmpty) {
        final last = _tapTimes.last;
        if (DateTime.now().difference(last).inMilliseconds >= 2500) {
          _tapTimes.clear();
        }
      }
    });
  }

  // ── Tempo label ────────────────────────────────────────────────────────────

  String get _tempoLabel {
    final b = _bpm;
    if (b < 60) return 'Largo';
    if (b < 66) return 'Larghetto';
    if (b < 76) return 'Adagio';
    if (b < 108) return 'Andante';
    if (b < 120) return 'Moderato';
    if (b < 156) return 'Allegro';
    if (b < 176) return 'Vivace';
    if (b < 200) return 'Presto';
    return 'Prestissimo';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: () {
            _stopMetronome();
            Navigator.of(context).pop();
          },
        ),
        title: ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [AppColors.textPrimary, AppColors.primaryLight],
            stops: [0.4, 1.0],
          ).createShader(b),
          child: Text(
            'Metronome',
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
            const SizedBox(height: 8),

            // ── Pendulum & Beat Orb ─────────────────────────────────────────
            Expanded(
              flex: 5,
              child: _BeatVisual(
                pulseAnim: _pulseAnim,
                glowAnim: _glowAnim,
                pendulumCtrl: _pendulumCtrl,
                bpm: _bpm,
                isPlaying: _isPlaying,
                beatActive: _beatActive,
                tempoLabel: _tempoLabel,
              ),
            ),

            // ── BPM Display & slider ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
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
                              fontSize: 64,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'BPM',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
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
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.surfaceBorder,
                      thumbColor: AppColors.primaryLight,
                      overlayColor: AppColors.primary.withOpacity(0.14),
                      trackHeight: 3,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 7),
                    ),
                    child: Slider(
                      value: _bpm,
                      min: 20,
                      max: 300,
                      onChanged: _updateBpm,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('20', style: _labelStyle),
                      Text(
                        _tempoLabel,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text('300', style: _labelStyle),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Play / Stop ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _PlayStopButton(
                isPlaying: _isPlaying,
                onTap: _togglePlay,
              ),
            ),

            const SizedBox(height: 14),

            // ── Tap Tempo ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: _TapTempoButton(onTap: _onTap),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _labelStyle => GoogleFonts.inter(
        fontSize: 11,
        color: AppColors.textMuted,
      );
}

// ── Beat Visual ───────────────────────────────────────────────────────────────

class _BeatVisual extends StatelessWidget {
  final Animation<double> pulseAnim;
  final Animation<double> glowAnim;
  final AnimationController pendulumCtrl;
  final double bpm;
  final bool isPlaying;
  final bool beatActive;
  final String tempoLabel;

  const _BeatVisual({
    required this.pulseAnim,
    required this.glowAnim,
    required this.pendulumCtrl,
    required this.bpm,
    required this.isPlaying,
    required this.beatActive,
    required this.tempoLabel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth.clamp(0.0, 280.0);

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring (animates on beat)
                AnimatedBuilder(
                  animation: glowAnim,
                  builder: (context, _) {
                    return Container(
                      width: size * 0.80,
                      height: size * 0.80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary
                                .withOpacity(0.38 * glowAnim.value),
                            blurRadius: 50,
                            spreadRadius: 12,
                          ),
                          BoxShadow(
                            color: AppColors.primaryLight
                                .withOpacity(0.18 * glowAnim.value),
                            blurRadius: 80,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Pendulum arc (visible track)
                CustomPaint(
                  size: Size(size * 0.78, size * 0.78),
                  painter: _PendulumArcPainter(),
                ),

                // Pendulum needle
                AnimatedBuilder(
                  animation: pendulumCtrl,
                  builder: (context, _) {
                    final angle = math.pi *
                        0.35 *
                        math.sin(pendulumCtrl.value * math.pi);
                    return Transform.rotate(
                      angle: angle - math.pi * 0.35,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 2.5,
                        height: size * 0.36,
                        margin: EdgeInsets.only(bottom: size * 0.08),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.2),
                              AppColors.primary,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),

                // Centre beat orb
                AnimatedBuilder(
                  animation: pulseAnim,
                  builder: (context, _) {
                    return Transform.scale(
                      scale: pulseAnim.value,
                      child: Container(
                        width: size * 0.32,
                        height: size * 0.32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: beatActive
                                ? [
                                    AppColors.primaryLight,
                                    AppColors.primary,
                                    AppColors.primaryDark,
                                  ]
                                : [
                                    AppColors.surfaceElevated,
                                    AppColors.surface,
                                    AppColors.background,
                                  ],
                          ),
                          border: Border.all(
                            color: beatActive
                                ? AppColors.primaryLight.withOpacity(0.7)
                                : AppColors.surfaceBorder,
                            width: 1.5,
                          ),
                        ),
                        child: isPlaying && beatActive
                            ? const Center(
                                child: Icon(
                                  Icons.music_note_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Pendulum arc painter ──────────────────────────────────────────────────────

class _PendulumArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.44;

    final paint = Paint()
      ..color = AppColors.surfaceBorder.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Dotted arc from -35° to +35° from bottom-center
    // bottom-center = 90° in standard coords; we want ±35° around it
    const startAngle = math.pi / 2 - math.pi * 0.35;
    const sweepAngle = math.pi * 0.70;

    // Draw as dashes
    const dashCount = 24;
    const dashSweep = sweepAngle / (dashCount * 2 - 1);
    for (int i = 0; i < dashCount; i++) {
      final a = startAngle + i * dashSweep * 2;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        a,
        dashSweep,
        false,
        paint,
      );
    }

    // Pivot dot
    canvas.drawCircle(
      Offset(cx, cy),
      4.5,
      Paint()
        ..shader = const RadialGradient(
          colors: [AppColors.primaryLight, AppColors.primaryDark],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 4.5)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Nudge Button ─────────────────────────────────────────────────────────────

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
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}

// ── Play / Stop Button ────────────────────────────────────────────────────────

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
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isPlaying
                  ? [const Color(0xFFF43F5E), const Color(0xFFBE123C)]
                  : AppColors.gradientPrimary,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: (widget.isPlaying ? AppColors.rose : AppColors.primary)
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
                size: 26,
              ),
              const SizedBox(width: 8),
              Text(
                widget.isPlaying ? 'Stop' : 'Start',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
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

// ── Tap Tempo Button ──────────────────────────────────────────────────────────

class _TapTempoButton extends StatefulWidget {
  final VoidCallback onTap;
  const _TapTempoButton({required this.onTap});

  @override
  State<_TapTempoButton> createState() => _TapTempoButtonState();
}

class _TapTempoButtonState extends State<_TapTempoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
        onTapDown: (_) {
          _ctrl.forward();
          widget.onTap();
        },
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.surfaceBorder,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TAP',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Tap repeatedly to set tempo',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
