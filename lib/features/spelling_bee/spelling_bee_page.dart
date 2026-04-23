import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SpellingBeePage extends StatefulWidget {
  const SpellingBeePage({super.key});

  @override
  State<SpellingBeePage> createState() => _SpellingBeePageState();
}

class _SpellingBeePageState extends State<SpellingBeePage> {
  // We constrain the prompt to D7 for the pedagogical demo
  final List<String> _targetNotes = ['D', 'F#', 'A', 'C'];
  final List<String> _currentNotes = [];
  
  String? _feedbackMessage;
  bool _isSuccess = false;

  final Map<String, String> _keyboardNotes = {
    'C': 'white', 'C#': 'black', 'D': 'white', 'D#': 'black',
    'E': 'white', 'F': 'white', 'F#': 'black', 'G': 'white',
    'G#': 'black', 'A': 'white', 'A#': 'black', 'B': 'white',
    'C2': 'white'
  };

  void _tapNote(String note) {
    if (_isSuccess) return;
    if (_currentNotes.length < 4) {
      setState(() {
        _currentNotes.add(note);
        _feedbackMessage = null; // Clear old feedback
      });
      if (_currentNotes.length == 4) {
        _checkSpelling();
      }
    }
  }

  void _removeNote() {
    if (_currentNotes.isNotEmpty && !_isSuccess) {
      setState(() {
        _currentNotes.removeLast();
        _feedbackMessage = null;
      });
    }
  }

  void _checkSpelling() {
    bool correct = true;
    for (int i = 0; i < 4; i++) {
        if (_currentNotes[i] != _targetNotes[i]) {
            correct = false;
            break;
        }
    }

    if (correct) {
      setState(() {
        _isSuccess = true;
        _feedbackMessage = "Perfect! You spelled a D Dominant 7th.";
      });
    } else {
      // Pedagogy Engine Mocked responses
      // Check if they spelled D minor 7 (D, F, A, C)
      if (_currentNotes[0] == 'D' && _currentNotes[1] == 'F' && 
          _currentNotes[2] == 'A' && _currentNotes[3] == 'C') {
        setState(() {
          _feedbackMessage = "You spelled a D minor 7. A Dominant 7 requires a Major 3rd. Raise the F to an F#.";
          _currentNotes.clear();
        });
      } else if (_currentNotes[0] == 'D' && _currentNotes[1] == 'F#' && 
                 _currentNotes[2] == 'A' && _currentNotes[3] == 'C#') {
        setState(() {
          _feedbackMessage = "You spelled a D Major 7. A Dominant 7 requires a flat (minor) 7th. Lower the C# to a C.";
          _currentNotes.clear();
        });
      } else {
        setState(() {
          _feedbackMessage = "Not quite. Remember, a Dominant 7 chord is built using Root, Major 3rd, Perfect 5th, and minor 7th.";
          _currentNotes.clear();
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
            'Chord Spelling Bee',
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
                'Spell a D Dominant 7th (D7)',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Tap the correct notes in order on the keyboard below.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),

              // Slots row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final hasValue = index < _currentNotes.length;
                  final val = hasValue ? _currentNotes[index] : '';

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: hasValue ? colorScheme.secondary : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasValue ? Colors.transparent : colorScheme.outline.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: hasValue && _isSuccess ? [
                        BoxShadow(
                          color: colorScheme.secondary.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      ] : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      val,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: hasValue ? colorScheme.onSecondary : Colors.transparent,
                      ),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 12),
              Center(
                  child: TextButton.icon(
                    onPressed: _removeNote,
                    icon: Icon(Icons.undo, color: colorScheme.onSurfaceVariant),
                    label: Text(
                      'Undo Note',
                      style: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              if (_feedbackMessage != null) 
                 AnimatedContainer(
                   duration: const Duration(milliseconds: 300),
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: _isSuccess 
                        ? colorScheme.tertiary.withOpacity(0.15) 
                        : colorScheme.errorContainer.withOpacity(0.4),
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(
                       color: _isSuccess ? colorScheme.tertiary : colorScheme.error,
                     ),
                   ),
                   child: Row(
                     children: [
                       Icon(
                         _isSuccess ? Icons.check_circle : Icons.lightbulb,
                         color: _isSuccess ? colorScheme.tertiary : colorScheme.error,
                       ),
                       const SizedBox(width: 12),
                       Expanded(
                         child: Text(
                           _feedbackMessage!,
                           style: GoogleFonts.inter(
                             fontWeight: FontWeight.w500,
                             color: colorScheme.onSurface,
                             height: 1.4,
                           ),
                         ),
                       )
                     ],
                   ),
                 ),

              const Spacer(),
              
              // Interactive Keyboard
              SizedBox(
                height: 160,
                child: _buildKeyboard(colorScheme),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard(ColorScheme colorScheme) {
    // Generate white keys
    final whiteKeys = _keyboardNotes.entries.where((e) => e.value == 'white').toList();
    final Map<int, MapEntry<String, String>> blackKeys = {}; // index of white key -> black key
    
    int wIndex = 0;
    for (var entry in _keyboardNotes.entries) {
      if (entry.value == 'white') {
        wIndex++;
      } else {
        blackKeys[wIndex - 1] = entry; 
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final keyWidth = constraints.maxWidth / whiteKeys.length;

        return Stack(
          children: [
            // White Keys
            Row(
              children: whiteKeys.map((entry) {
                return GestureDetector(
                  onTap: () => _tapNote(entry.key.replaceAll('2', '')),
                  child: Container(
                    width: keyWidth,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border.all(color: colorScheme.outline, width: 1),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                    ),
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      entry.key.replaceAll('2', ''),
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Black Keys
            for (var entry in blackKeys.entries)
              Positioned(
                left: (entry.key * keyWidth) + (keyWidth * 0.65),
                top: 0,
                child: GestureDetector(
                  onTap: () => _tapNote(entry.value.key),
                  child: Container(
                    width: keyWidth * 0.7,
                    height: constraints.maxHeight * 0.6,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
                    ),
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      entry.value.key,
                      style: TextStyle(
                        color: colorScheme.surface,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }
    );
  }
}
