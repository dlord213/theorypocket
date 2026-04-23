import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ScaleConstructorPage extends StatefulWidget {
  const ScaleConstructorPage({super.key});

  @override
  State<ScaleConstructorPage> createState() => _ScaleConstructorPageState();
}

class _ScaleConstructorPageState extends State<ScaleConstructorPage> {
  final List<String> _targetFormula = ['W', 'W', 'H', 'W', 'W', 'W', 'H'];
  final List<String> _currentFormula = [];
  bool _isSuccess = false;
  bool _showFretboard = false; // toggles between keyboard and fretboard when successful

  void _addStep(String step) {
    if (_currentFormula.length < _targetFormula.length && !_isSuccess) {
      setState(() {
        _currentFormula.add(step);
      });
      _checkFormula();
    }
  }

  void _removeLastStep() {
    if (_currentFormula.isNotEmpty && !_isSuccess) {
      setState(() {
        _currentFormula.removeLast();
      });
    }
  }

  void _checkFormula() {
    if (_currentFormula.length == _targetFormula.length) {
      bool isMatch = true;
      for (int i = 0; i < _targetFormula.length; i++) {
        if (_currentFormula[i] != _targetFormula[i]) {
          isMatch = false;
          break;
        }
      }
      
      if (isMatch) {
        setState(() {
          _isSuccess = true;
        });
      } else {
        // Automatically shake or clear
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _currentFormula.clear();
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: colorScheme.onSurface,
          onPressed: () => context.pop(),
        ),
        title: ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: [colorScheme.onSurface, colorScheme.primary],
            stops: const [0.4, 1.0],
          ).createShader(b),
          child: Text(
            'Scale Constructor',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Build a Major Scale',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Arrange the specific sequence of Whole (W) and Half (H) steps.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Slots row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_targetFormula.length, (index) {
                  final hasValue = index < _currentFormula.length;
                  final val = hasValue ? _currentFormula[index] : '';
                  final isW = val == 'W';

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: isW ? 42 : 32, // W is larger than H in real life, so visual cue
                    height: 48,
                    decoration: BoxDecoration(
                      color: hasValue 
                          ? (isW ? colorScheme.primary : colorScheme.secondary)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasValue ? Colors.transparent : colorScheme.outline.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: hasValue && _isSuccess ? [
                        BoxShadow(
                          color: (isW ? colorScheme.primary : colorScheme.secondary).withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      ] : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      val,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: hasValue ? colorScheme.onPrimary : Colors.transparent,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),
              
              if (!_isSuccess) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StepButton(
                      label: 'W',
                      subtext: 'Whole Step',
                      color: colorScheme.primary,
                      onTap: () => _addStep('W'),
                    ),
                    const SizedBox(width: 24),
                    _StepButton(
                      label: 'H',
                      subtext: 'Half Step',
                      color: colorScheme.secondary,
                      onTap: () => _addStep('H'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton.icon(
                    onPressed: _removeLastStep,
                    icon: Icon(Icons.undo, color: colorScheme.onSurfaceVariant),
                    label: Text(
                      'Undo',
                      style: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ] else ...[
                AnimatedOpacity(
                  opacity: _isSuccess ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      Text(
                        'Perfect! C Major Scale Generated 🎯',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.tertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text('Keyboard'),
                            selected: !_showFretboard,
                            onSelected: (val) => setState(() => _showFretboard = false),
                          ),
                          const SizedBox(width: 12),
                          ChoiceChip(
                            label: const Text('Fretboard'),
                            selected: _showFretboard,
                            onSelected: (val) => setState(() => _showFretboard = true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _showFretboard 
                            ? CustomPaint(painter: _FretboardPainter(colorScheme: colorScheme))
                            : CustomPaint(painter: _KeyboardPainter(colorScheme: colorScheme)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final String label;
  final String subtext;
  final Color color;
  final VoidCallback onTap;

  const _StepButton({
    required this.label,
    required this.subtext,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              subtext,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Simple Visualizers ────────────────────────────────────────────────────────
class _KeyboardPainter extends CustomPainter {
  final ColorScheme colorScheme;
  _KeyboardPainter({required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = colorScheme.onSurface;
    final whiteKeyPaint = Paint()..color = colorScheme.surface;
    final blackKeyPaint = Paint()..color = colorScheme.onSurface;
    final selectedPaint = Paint()..color = colorScheme.primary..style = PaintingStyle.fill;
    
    // Draw simple 1-octave keyboard outline
    final whiteKeyWidth = size.width / 7;
    for (int i = 0; i < 7; i++) {
      final rect = Rect.fromLTWH(i * whiteKeyWidth, 0, whiteKeyWidth, size.height);
      // Fill white key
      canvas.drawRect(rect, whiteKeyPaint);
      canvas.drawRect(rect, paint..style = PaintingStyle.stroke..strokeWidth = 2);
      
      // Since it's C Major, all white keys are in the scale!
      canvas.drawCircle(Offset(rect.center.dx, size.height - 20), 8, selectedPaint);
    }

    // Draw black keys (none in C Major, but just for the keyboard look)
    for (int i = 0; i < 7; i++) {
      if (i == 2 || i == 6) continue; // No black key after E and B
      final rect = Rect.fromLTWH((i * whiteKeyWidth) + (whiteKeyWidth * 0.7), 0, whiteKeyWidth * 0.6, size.height * 0.6);
      canvas.drawRect(rect, blackKeyPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FretboardPainter extends CustomPainter {
  final ColorScheme colorScheme;
  _FretboardPainter({required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    final stringPaint = Paint()..color = colorScheme.onSurface.withOpacity(0.5)..strokeWidth = 2;
    final fretPaint = Paint()..color = colorScheme.onSurface.withOpacity(0.3)..strokeWidth = 3;
    final dotPaint = Paint()..color = colorScheme.tertiary..style = PaintingStyle.fill;

    // Draw 6 strings
    for (int i = 0; i < 6; i++) {
      final y = size.height * (i + 1) / 7;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), stringPaint);
    }

    // Draw frets (first 5 frets)
    for (int i = 0; i < 6; i++) {
      final x = size.width * i / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), fretPaint);
    }

    // Highlight C Major notes on first 5 frets loosely
    // e.g. A string 3rd fret (C)
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 5 / 7), 10, dotPaint);
    // D string 2nd fret (E)
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 4 / 7), 10, dotPaint);
    // D string 3rd fret (F)
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 4 / 7), 10, dotPaint);
    // G string open (G)
    canvas.drawCircle(Offset(size.width * 0.05, size.height * 3 / 7), 10, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
