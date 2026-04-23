import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'harmonic_analyzer.dart';

class ProgressionAnalyzerPage extends StatefulWidget {
  const ProgressionAnalyzerPage({super.key});

  @override
  State<ProgressionAnalyzerPage> createState() => _ProgressionAnalyzerPageState();
}

class _ProgressionAnalyzerPageState extends State<ProgressionAnalyzerPage> {
  final List<Chord> _sequence = [];
  List<ChordAnalysisResult>? _results;
  
  Note _selectedKey = Note.c; // Default Key C Major
  Note _currentRoot = Note.c;
  ChordQuality _currentQuality = ChordQuality.major;

  void _addChord() {
    if (_results == null) {
      setState(() {
        _sequence.add(Chord(_currentRoot, _currentQuality));
      });
    }
  }

  void _removeLast() {
    if (_sequence.isNotEmpty && _results == null) {
      setState(() {
        _sequence.removeLast();
      });
    }
  }

  void _runAnalysis() {
    if (_sequence.isNotEmpty) {
      setState(() {
        _results = HarmonicAnalyzer.analyzeProgression(_selectedKey, _sequence);
      });
    }
  }

  void _reset() {
    setState(() {
      _sequence.clear();
      _results = null;
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
              
              // Key Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Anchor Key:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<Note>(
                    value: _selectedKey,
                    dropdownColor: colorScheme.surfaceContainerHigh,
                    underline: Container(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                    items: Note.values.map((n) {
                      return DropdownMenuItem(
                        value: n,
                        child: Text('${n.label} Major'),
                      );
                    }).toList(),
                    onChanged: _results == null ? (Note? value) {
                      if (value != null) {
                        setState(() => _selectedKey = value);
                      }
                    } : null, // Disable key change during analysis result view
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Sequence Display (Responsive horizontally scrolling list)
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                ),
                alignment: Alignment.center,
                child: _sequence.isEmpty 
                  ? Text(
                      'Build a sequence below',
                      style: GoogleFonts.inter(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: _sequence.map((c) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              c.name,
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
              ),
              
              const SizedBox(height: 16),
              
              if (_results == null) ...[
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
                const SizedBox(height: 24),
                
                // Active Chord Builder Area
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Select Root Note',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: Note.values.map((n) {
                              final isSelected = _currentRoot == n;
                              return ChoiceChip(
                                label: Text(n.label),
                                selected: isSelected,
                                onSelected: (_) => setState(() => _currentRoot = n),
                                selectedColor: colorScheme.secondary,
                                labelStyle: TextStyle(
                                  color: isSelected ? colorScheme.onSecondary : colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Select Chord Quality',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ChordQuality.values.map((q) {
                              final isSelected = _currentQuality == q;
                              // A user-friendly string for the quality name
                              String qName = q.name.toUpperCase();
                              if (q == ChordQuality.dom7) qName = 'DOMINANT 7';
                              if (q == ChordQuality.maj7) qName = 'MAJOR 7';
                              if (q == ChordQuality.min7) qName = 'MINOR 7';
                              
                              return ChoiceChip(
                                label: Text(qName),
                                selected: isSelected,
                                onSelected: (_) => setState(() => _currentQuality = q),
                                selectedColor: colorScheme.tertiary,
                                labelStyle: TextStyle(
                                  color: isSelected ? colorScheme.onTertiary : colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),
                          OutlinedButton.icon(
                            onPressed: _addChord, 
                            icon: const Icon(Icons.add),
                            label: Text('Add ${_currentRoot.label}${_currentQuality.symbol}'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Analysis Results
                Expanded(
                  child: ListView.builder(
                    itemCount: _results!.length,
                    itemBuilder: (context, index) {
                      final result = _results![index];
                      // Highlight non-diatonic chords as special
                      final isSpecial = result.tag != AnalysisTag.diatonic;
                      
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
                              width: 65,
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Text(
                                    result.chord.name,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isSpecial ? colorScheme.onTertiaryContainer : colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    result.romanNumeral,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
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
                                    result.pedagogyExplanation,
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
