import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressionAnalyzerPage extends StatefulWidget {
  const ProgressionAnalyzerPage({super.key});

  @override
  State<ProgressionAnalyzerPage> createState() => _ProgressionAnalyzerPageState();
}

class _ProgressionAnalyzerPageState extends State<ProgressionAnalyzerPage> {
  final List<String> _sequence = [];
  bool _analyzing = false;
  
  // Available chords for the prototype (G Major context + borrowed chords)
  final List<String> _availableChords = ['G', 'Am', 'Bm', 'B', 'B7', 'C', 'Cm', 'D', 'Em', 'F', 'F#m7b5'];

  // Analysis Engine logic mocked for the scope
  Map<String, String> _analyzeChord(String chord) {
    switch (chord) {
      case 'G':
        return {'numeral': 'I', 'desc': 'Standard diatonic tonic chord. Establishes the key.'};
      case 'Am':
        return {'numeral': 'ii', 'desc': 'Standard diatonic supertonic. Often leads to V.'};
      case 'Bm':
        return {'numeral': 'iii', 'desc': 'Standard diatonic mediant.'};
      case 'B':
      case 'B7':
        return {'numeral': 'V/vi', 'desc': 'Secondary Dominant: This is the V chord of the vi chord (Em), creating tension.'};
      case 'C':
        return {'numeral': 'IV', 'desc': 'Standard diatonic subdominant. A bright, stable resting point.'};
      case 'Cm':
        return {'numeral': 'iv', 'desc': 'Minor Plagal Cadence: Borrowed from the parallel minor (G minor) to create a melancholic resolution.'};
      case 'D':
        return {'numeral': 'V', 'desc': 'Standard diatonic dominant. Strongest pull back to the tonic.'};
      case 'Em':
        return {'numeral': 'vi', 'desc': 'Standard diatonic submediant. The relative minor.'};
      case 'F':
        return {'numeral': 'bVII', 'desc': 'Borrowed Chord: Taken from the Mixolydian mode or parallel minor for a rocky feel.'};
      default:
        return {'numeral': '?', 'desc': 'Unanalyzed chord.'};
    }
  }

  void _addChord(String chord) {
    if (_sequence.length < 6 && !_analyzing) {
      setState(() {
        _sequence.add(chord);
      });
    }
  }

  void _removeLast() {
    if (_sequence.isNotEmpty && !_analyzing) {
      setState(() {
        _sequence.removeLast();
      });
    }
  }

  void _runAnalysis() {
    if (_sequence.isNotEmpty) {
      setState(() {
        _analyzing = true;
      });
    }
  }

  void _reset() {
    setState(() {
      _sequence.clear();
      _analyzing = false;
    });
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
            'Progression Analyzer',
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
                'Why Does This Work?',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Input a progression (Key: G Major) to see its functional analysis.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Sequence Display
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _sequence.isEmpty 
                    ? [
                        Text(
                          'Tap chords below to build sequence',
                          style: GoogleFonts.inter(
                            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      ]
                    : _sequence.map((c) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            c,
                            style: GoogleFonts.spaceGrotesk(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      )).toList(),
                ),
              ),
              
              const SizedBox(height: 16),
              
              if (!_analyzing) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _removeLast,
                      icon: const Icon(Icons.undo),
                      label: const Text('Undo'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: _sequence.isNotEmpty ? _runAnalysis : null,
                      icon: const Icon(Icons.analytics),
                      label: const Text('Analyze'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Keyboard / Chord Picker Area
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1.5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: _availableChords.length,
                    itemBuilder: (context, index) {
                      final chord = _availableChords[index];
                      // Highlight common borrowed chords slightly differently
                      final isBorrowed = ['B', 'B7', 'Cm', 'F'].contains(chord);
                      return InkWell(
                        onTap: () => _addChord(chord),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isBorrowed ? colorScheme.tertiaryContainer : colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isBorrowed ? colorScheme.tertiary : colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            chord,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: isBorrowed ? colorScheme.onTertiaryContainer : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                // Analysis Results
                Expanded(
                  child: ListView.builder(
                    itemCount: _sequence.length,
                    itemBuilder: (context, index) {
                      final chord = _sequence[index];
                      final analysis = _analyzeChord(chord);
                      final isSpecial = ['iv', 'V/vi', 'bVII'].contains(analysis['numeral']);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSpecial ? colorScheme.tertiaryContainer : colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSpecial ? colorScheme.tertiary : colorScheme.outline.withOpacity(0.3),
                          ),
                          boxShadow: isSpecial ? [
                            BoxShadow(
                              color: colorScheme.tertiary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ] : [],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 60,
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Text(
                                    chord,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isSpecial ? colorScheme.onTertiaryContainer : colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    analysis['numeral']!,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w800,
                                      color: isSpecial ? colorScheme.tertiary : colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isSpecial ? 'Theory Highlight' : 'Diatonic Function',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                      color: isSpecial ? colorScheme.tertiary : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    analysis['desc']!,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: isSpecial ? colorScheme.onTertiaryContainer : colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Analyze Another'),
                    ),
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
