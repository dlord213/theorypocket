/// Music theory helpers for computing chord note names.
library;

/// The chromatic scale used by chord_diagrams (matches getNotes() output).
const List<String> chromaticScale = [
  'C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B',
];

/// Interval sets (in semitones) for each chord suffix.
const Map<String, List<int>> _intervals = {
  '': [0, 4, 7],
  'm': [0, 3, 7],
  '7': [0, 4, 7, 10],
  'maj7': [0, 4, 7, 11],
  'm7': [0, 3, 7, 10],
  '6': [0, 4, 7, 9],
  'm6': [0, 3, 7, 9],
  'dim': [0, 3, 6],
  'dim7': [0, 3, 6, 9],
  'aug': [0, 4, 8],
  'sus2': [0, 2, 7],
  'sus4': [0, 5, 7],
  '7sus4': [0, 5, 7, 10],
  '9': [0, 4, 7, 10, 14],
  'm9': [0, 3, 7, 10, 14],
  'maj9': [0, 4, 7, 11, 14],
  'add9': [0, 4, 7, 14],
  '11': [0, 4, 7, 10, 14, 17],
  '13': [0, 4, 7, 10, 14, 21],
  'm7b5': [0, 3, 6, 10],
  '7b5': [0, 4, 6, 10],
  '7b9': [0, 4, 7, 10, 13],
  '7#9': [0, 4, 7, 10, 15],
  'alt': [0, 4, 6, 10, 13, 15],
};

/// Human-friendly display names for suffixes shown in the quality picker.
const Map<String, String> suffixDisplayName = {
  '': 'Major',
  'm': 'Minor',
  '7': 'Dom 7',
  'maj7': 'Maj 7',
  'm7': 'Min 7',
  '6': 'Maj 6',
  'm6': 'Min 6',
  'dim': 'Dim',
  'dim7': 'Dim 7',
  'aug': 'Aug',
  'sus2': 'Sus 2',
  'sus4': 'Sus 4',
  '7sus4': '7sus4',
  '9': 'Dom 9',
  'm9': 'Min 9',
  'maj9': 'Maj 9',
  'add9': 'Add 9',
  'm7b5': 'Half-Dim',
};

/// Ordered list of suffixes shown in the primary quality picker.
const List<String> primarySuffixes = [
  '', 'm', '7', 'maj7', 'm7', '6', 'm6',
  'dim', 'dim7', 'aug', 'sus2', 'sus4', '9', 'm9', 'maj9', 'add9', 'm7b5',
];

/// Compute the note names for a chord given its root and suffix.
List<String> getChordNotes(String root, String suffix) {
  final intervals = _intervals[suffix];
  if (intervals == null) return [root];

  final rootIdx = chromaticScale.indexOf(root);
  if (rootIdx == -1) return [root];

  return intervals.map((semitones) {
    final idx = (rootIdx + semitones) % 12;
    return chromaticScale[idx];
  }).toList();
}

/// Returns the full chord symbol, e.g. 'Cmaj7', 'Dm', 'G'.
String buildChordName(String root, String suffix) => '$root$suffix';

/// Returns a short description of the chord quality.
String suffixDescription(String suffix) {
  const desc = {
    '': 'Root – Major 3rd – Perfect 5th',
    'm': 'Root – Minor 3rd – Perfect 5th',
    '7': 'Root – Major 3rd – P5 – Minor 7th',
    'maj7': 'Root – Major 3rd – P5 – Major 7th',
    'm7': 'Root – Minor 3rd – P5 – Minor 7th',
    '6': 'Root – Major 3rd – P5 – Major 6th',
    'm6': 'Root – Minor 3rd – P5 – Major 6th',
    'dim': 'Root – Minor 3rd – Dim 5th',
    'dim7': 'Root – Minor 3rd – Dim 5th – Dim 7th',
    'aug': 'Root – Major 3rd – Aug 5th',
    'sus2': 'Root – Major 2nd – Perfect 5th',
    'sus4': 'Root – Perfect 4th – Perfect 5th',
    '9': 'Root – M3 – P5 – m7 – Major 9th',
    'maj9': 'Root – M3 – P5 – M7 – Major 9th',
    'm9': 'Root – m3 – P5 – m7 – Major 9th',
    'add9': 'Root – M3 – P5 – Major 9th',
    'm7b5': 'Root – Minor 3rd – Dim 5th – Minor 7th',
    '7sus4': 'Root – P4 – P5 – Minor 7th',
  };
  return desc[suffix] ?? '';
}
