enum Note {
  c, cSharp, d, dSharp, e, f, fSharp, g, gSharp, a, aSharp, b;

  String get label {
    switch (this) {
      case Note.c: return 'C';
      case Note.cSharp: return 'C#';
      case Note.d: return 'D';
      case Note.dSharp: return 'D#';
      case Note.e: return 'E';
      case Note.f: return 'F';
      case Note.fSharp: return 'F#';
      case Note.g: return 'G';
      case Note.gSharp: return 'G#';
      case Note.a: return 'A';
      case Note.aSharp: return 'A#';
      case Note.b: return 'B';
    }
  }

  // Returns intervals from C
  int get value => index;
}

enum ChordQuality {
  major, 
  minor, 
  diminished, 
  augmented, 
  dom7, 
  maj7, 
  min7, 
  m7b5;

  String get symbol {
    switch (this) {
      case ChordQuality.major: return '';
      case ChordQuality.minor: return 'm';
      case ChordQuality.diminished: return 'dim';
      case ChordQuality.augmented: return 'aug';
      case ChordQuality.dom7: return '7';
      case ChordQuality.maj7: return 'maj7';
      case ChordQuality.min7: return 'm7';
      case ChordQuality.m7b5: return 'm7b5';
    }
  }
}

enum AnalysisTag {
  diatonic,
  secondaryDominant,
  modalInterchange,
  passingChord,
  unknown
}

class Chord {
  final Note root;
  final ChordQuality quality;

  const Chord(this.root, this.quality);

  String get name => '${root.label}${quality.symbol}';
}

class ChordAnalysisResult {
  final Chord chord;
  final String romanNumeral;
  final AnalysisTag tag;
  final String pedagogyExplanation;

  const ChordAnalysisResult({
    required this.chord,
    required this.romanNumeral,
    required this.tag,
    required this.pedagogyExplanation,
  });
}

class HarmonicAnalyzer {
  static int _getInterval(Note start, Note end) {
    int diff = end.value - start.value;
    if (diff < 0) diff += 12;
    return diff;
  }

  static List<ChordAnalysisResult> analyzeProgression(Note key, List<Chord> progression) {
    List<ChordAnalysisResult> results = [];

    // Major scale diatonic expected qualities (per semitone interval from root)
    // 0: I (maj, maj7)
    // 2: ii (min, min7)
    // 4: iii (min, min7)
    // 5: IV (maj, maj7)
    // 7: V (maj, dom7)
    // 9: vi (min, min7)
    // 11: vii° (dim, m7b5)

    final Map<int, List<ChordQuality>> diatonicQualities = {
      0: [ChordQuality.major, ChordQuality.maj7],
      2: [ChordQuality.minor, ChordQuality.min7],
      4: [ChordQuality.minor, ChordQuality.min7],
      5: [ChordQuality.major, ChordQuality.maj7],
      7: [ChordQuality.major, ChordQuality.dom7],
      9: [ChordQuality.minor, ChordQuality.min7],
      11: [ChordQuality.diminished, ChordQuality.m7b5],
    };

    final Map<int, String> diatonicNumerals = {
      0: 'I', 2: 'ii', 4: 'iii', 5: 'IV', 7: 'V', 9: 'vi', 11: 'vii°'
    };

    final Map<int, String> diatonicDescriptions = {
      0: 'Standard diatonic tonic chord. Establishes the key.',
      2: 'Standard diatonic supertonic. Acts as a predominant, often leading to V.',
      4: 'Standard diatonic mediant. Provides a gentle departure from the tonic.',
      5: 'Standard diatonic subdominant. A bright, stable resting point.',
      7: 'Standard diatonic dominant. Creates the strongest pull back to the tonic.',
      9: 'Standard diatonic submediant. The relative minor, providing dark contrast.',
      11: 'Standard diatonic leading-tone chord. Highly tense, points strongly to I.',
    };

    for (int i = 0; i < progression.length; i++) {
      final chord = progression[i];
      final interval = _getInterval(key, chord.root);
      
      // 1. Check Diatonic match
      if (diatonicQualities.containsKey(interval) && diatonicQualities[interval]!.contains(chord.quality)) {
        results.add(ChordAnalysisResult(
          chord: chord,
          romanNumeral: diatonicNumerals[interval]!,
          tag: AnalysisTag.diatonic,
          pedagogyExplanation: diatonicDescriptions[interval]!,
        ));
        continue;
      }

      // 2. Check Secondary Dominant
      // A secondary dominant is typically a Major or Dom7 chord 
      // whose root is a Perfect 5th (7 semitones) above a diatonic target.
      // So, if interval is X, target is (X + 5) % 12
      if (chord.quality == ChordQuality.major || chord.quality == ChordQuality.dom7) {
        int targetInterval = (interval + 5) % 12;
        if (diatonicQualities.containsKey(targetInterval) && targetInterval != 0) { // Should not be targeting I (that's just V)
          String targetNumeral = diatonicNumerals[targetInterval]!;
          
          bool resolves = false;
          // Check resolution if next chord exists
          if (i + 1 < progression.length) {
             int nextInterval = _getInterval(key, progression[i+1].root);
             if (nextInterval == targetInterval) {
               resolves = true;
             }
          }

          String explanation = 'Secondary Dominant (V of $targetNumeral). This chord temporarily shifts the tonal center to $targetNumeral, creating a localized tension.';
          if (!resolves && i + 1 < progression.length) {
            explanation += ' However, it demonstrates a deceptive resolution here, as it does not immediately resolve to its expected target!';
          }

          results.add(ChordAnalysisResult(
            chord: chord,
            romanNumeral: 'V/$targetNumeral',
            tag: AnalysisTag.secondaryDominant,
            pedagogyExplanation: explanation,
          ));
          continue;
        }
      }

      // 3. Check Modal Interchange
      // Common major key borrowed chords: minor iv (5), flat III (3), flat VI (8), flat VII (10)
      if (interval == 5 && (chord.quality == ChordQuality.minor || chord.quality == ChordQuality.min7)) {
        results.add(ChordAnalysisResult(
          chord: chord,
          romanNumeral: 'iv',
          tag: AnalysisTag.modalInterchange,
          pedagogyExplanation: 'Modal Interchange: The "Minor Plagal" chord. Borrowed from the parallel minor key to create a melancholic, dramatic resolution.',
        ));
        continue;
      }

      if (interval == 3 && (chord.quality == ChordQuality.major || chord.quality == ChordQuality.maj7)) {
        results.add(ChordAnalysisResult(
          chord: chord,
          romanNumeral: '♭III',
          tag: AnalysisTag.modalInterchange,
          pedagogyExplanation: 'Modal Interchange: Borrowed from the parallel minor, giving a heavy or bluesy sound.',
        ));
        continue;
      }
      
      if (interval == 8 && (chord.quality == ChordQuality.major || chord.quality == ChordQuality.maj7)) {
        results.add(ChordAnalysisResult(
          chord: chord,
          romanNumeral: '♭VI',
          tag: AnalysisTag.modalInterchange,
          pedagogyExplanation: 'Modal Interchange: Borrowed from the parallel minor, often used to create a majestic or surprise lift.',
        ));
        continue;
      }
      
      if (interval == 10 && (chord.quality == ChordQuality.major || chord.quality == ChordQuality.dom7)) {
        results.add(ChordAnalysisResult(
          chord: chord,
          romanNumeral: '♭VII',
          tag: AnalysisTag.modalInterchange,
          pedagogyExplanation: 'Modal Interchange: Borrowed from Mixolydian or parallel minor. Very common in rock music (the "rock dominant").',
        ));
        continue;
      }

      // Unknown / Unmapped
      results.add(ChordAnalysisResult(
        chord: chord,
        romanNumeral: '?',
        tag: AnalysisTag.unknown,
        pedagogyExplanation: 'Outside the standard diatonic and common borrowed chords mappings. Could be chromatic planing or a complex modulation.',
      ));
    }

    return results;
  }
}
