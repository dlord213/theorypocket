import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:theorypocket/features/chord_dictionary/chord_theory.dart';

// ── Selected root note ────────────────────────────────────────────────────────

final selectedRootProvider = StateProvider<String>((ref) => 'C');

// ── Selected suffix / quality ─────────────────────────────────────────────────

final selectedSuffixProvider = StateProvider<String>((ref) => '');

// ── Current voicing index ─────────────────────────────────────────────────────

final voicingIndexProvider = StateProvider<int>((ref) => 0);

// ── Derived: chord name ───────────────────────────────────────────────────────

final chordNameProvider = Provider<String>((ref) {
  final root = ref.watch(selectedRootProvider);
  final suffix = ref.watch(selectedSuffixProvider);
  return buildChordName(root, suffix);
});

// ── Derived: chord notes ──────────────────────────────────────────────────────

final chordNotesProvider = Provider<List<String>>((ref) {
  final root = ref.watch(selectedRootProvider);
  final suffix = ref.watch(selectedSuffixProvider);
  return getChordNotes(root, suffix);
});

// ── Derived: description ──────────────────────────────────────────────────────

final chordDescriptionProvider = Provider<String>((ref) {
  final suffix = ref.watch(selectedSuffixProvider);
  return suffixDescription(suffix);
});
