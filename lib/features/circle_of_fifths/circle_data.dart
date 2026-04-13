// ── Circle of Fifths Data ─────────────────────────────────────────────────────

const List<String> majorKeys = [
  'C', 'G', 'D', 'A', 'E', 'B', 'F♯', 'D♭', 'A♭', 'E♭', 'B♭', 'F',
];

const List<String> minorKeys = [
  'Am', 'Em', 'Bm', 'F♯m', 'C♯m', 'G♯m', 'D♯m', 'B♭m', 'Fm', 'Cm', 'Gm', 'Dm',
];

const List<String> dimKeys = [
  'B°', 'F♯°', 'C♯°', 'G♯°', 'D♯°', 'A♯°', 'F°', 'C°', 'G°', 'D°', 'A°', 'E°',
];

const List<String> romanNumerals = ['I', 'ii', 'iii', 'IV', 'V', 'vi', 'vii°'];

/// 0 = major, 1 = minor, 2 = diminished
const List<int> chordTypes = [0, 1, 1, 0, 0, 1, 2];

/// Diatonic chords for each key position (I ii iii IV V vi vii°)
const List<List<String>> diatonicChords = [
  // C
  ['C', 'Dm', 'Em', 'F', 'G', 'Am', 'Bdim'],
  // G
  ['G', 'Am', 'Bm', 'C', 'D', 'Em', 'F♯dim'],
  // D
  ['D', 'Em', 'F♯m', 'G', 'A', 'Bm', 'C♯dim'],
  // A
  ['A', 'Bm', 'C♯m', 'D', 'E', 'F♯m', 'G♯dim'],
  // E
  ['E', 'F♯m', 'G♯m', 'A', 'B', 'C♯m', 'D♯dim'],
  // B
  ['B', 'C♯m', 'D♯m', 'E', 'F♯', 'G♯m', 'A♯dim'],
  // F#
  ['F♯', 'G♯m', 'A♯m', 'B', 'C♯', 'D♯m', 'Edim'],
  // Db
  ['D♭', 'E♭m', 'Fm', 'G♭', 'A♭', 'B♭m', 'Cdim'],
  // Ab
  ['A♭', 'B♭m', 'Cm', 'D♭', 'E♭', 'Fm', 'Gdim'],
  // Eb
  ['E♭', 'Fm', 'Gm', 'A♭', 'B♭', 'Cm', 'Ddim'],
  // Bb
  ['B♭', 'Cm', 'Dm', 'E♭', 'F', 'Gm', 'Adim'],
  // F
  ['F', 'Gm', 'Am', 'B♭', 'C', 'Dm', 'Edim'],
];
