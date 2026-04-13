/// Chromatic transpose helpers
library;

const _sharps = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
const _flats = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];

/// All valid root notes (sharp + flat variants)
const List<String> chromaticRoots = [
  'C', 'C#', 'Db', 'D', 'D#', 'Eb', 'E', 'F',
  'F#', 'Gb', 'G', 'G#', 'Ab', 'A', 'A#', 'Bb', 'B',
];

/// Common chord qualities shown in the picker
const List<String> chordQualities = [
  '', 'm', '7', 'maj7', 'm7', 'dim', 'aug', 'sus2', 'sus4',
];

/// Display label for a quality
String qualityLabel(String q) {
  const labels = {
    '': 'maj',
    'm': 'min',
    '7': 'dom7',
    'maj7': 'maj7',
    'm7': 'min7',
    'dim': 'dim',
    'aug': 'aug',
    'sus2': 'sus2',
    'sus4': 'sus4',
  };
  return labels[q] ?? q;
}

/// Transpose a note name up/down by [halfSteps].
String transposeNote(String root, int halfSteps) {
  final useFlats = root.contains('b');
  final scale = useFlats ? _flats : _sharps;
  final idx = scale.indexOf(root);
  if (idx == -1) return root;
  return scale[(idx + halfSteps + 12) % 12];
}

/// Transpose a full chord string (e.g. "F#m7", "Bb", "Cdim") by [halfSteps].
/// Positive = up, negative = down.
String transposeChord(String chord, int halfSteps) {
  if (chord.isEmpty) return chord;

  String root;
  String quality;

  // Two-char root: C#, Db, etc.
  if (chord.length >= 2 && (chord[1] == '#' || chord[1] == 'b')) {
    root = chord.substring(0, 2);
    quality = chord.substring(2);
  } else {
    root = chord.substring(0, 1);
    quality = chord.substring(1);
  }

  return transposeNote(root, halfSteps) + quality;
}

/// Determine whether a key name uses flats or sharps.
bool keyUsesFlats(String key) {
  const flatKeys = {'F', 'Bb', 'Eb', 'Ab', 'Db', 'Gb', 'Cb'};
  return flatKeys.contains(key.replaceAll(' Major', '').replaceAll(' minor', '').trim());
}
