import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:theorypocket/features/progression_builder/models/song_model.dart';
import 'package:theorypocket/features/progression_builder/services/song_database.dart';
import 'package:theorypocket/features/progression_builder/services/transpose_helper.dart';

// ── Songs list (persisted) ───────────────────────────────────────────────────

class SongsNotifier extends AsyncNotifier<List<Song>> {
  @override
  Future<List<Song>> build() => SongDatabase.instance.fetchAll();

  Future<void> addSong(Song song) async {
    final inserted = await SongDatabase.instance.insert(song);
    final prev = state.value ?? [];
    state = AsyncData([inserted, ...prev]);
  }

  Future<void> updateSong(Song song) async {
    await SongDatabase.instance.update(song);
    state = AsyncData(
      (state.value ?? []).map((s) => s.id == song.id ? song : s).toList(),
    );
  }

  Future<void> deleteSong(int id) async {
    await SongDatabase.instance.delete(id);
    state = AsyncData(
      (state.value ?? []).where((s) => s.id != id).toList(),
    );
  }

  Future<void> transposeSong(Song song, int halfSteps) async {
    final transposed = song.copyWith(
      chords: song.chords.map((c) => transposeChord(c, halfSteps)).toList(),
      key: transposeNote(song.key, halfSteps),
    );
    await updateSong(transposed);
  }
}

final songsProvider = AsyncNotifierProvider<SongsNotifier, List<Song>>(
  SongsNotifier.new,
);

// ── Editor state (in-memory while editing) ───────────────────────────────────

class EditorState {
  final String title;
  final String key;
  final List<String> chords;

  const EditorState({
    this.title = '',
    this.key = 'C',
    this.chords = const [],
  });

  EditorState copyWith({String? title, String? key, List<String>? chords}) =>
      EditorState(
        title: title ?? this.title,
        key: key ?? this.key,
        chords: chords ?? this.chords,
      );

  bool get isValid => title.trim().isNotEmpty && chords.isNotEmpty;
}

class EditorNotifier extends Notifier<EditorState> {
  @override
  EditorState build() => const EditorState();

  void load(Song song) {
    state = EditorState(
      title: song.title,
      key: song.key,
      chords: List.from(song.chords),
    );
  }

  void reset() => state = const EditorState();

  void setTitle(String v) => state = state.copyWith(title: v);
  void setKey(String v) => state = state.copyWith(key: v);

  void addChord(String chord) =>
      state = state.copyWith(chords: [...state.chords, chord]);

  void removeChord(int index) {
    final updated = List<String>.from(state.chords)..removeAt(index);
    state = state.copyWith(chords: updated);
  }

  void reorderChords(int oldIndex, int newIndex) {
    final list = List<String>.from(state.chords);
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = state.copyWith(chords: list);
  }

  void clearChords() => state = state.copyWith(chords: []);
}

final editorProvider = NotifierProvider<EditorNotifier, EditorState>(
  EditorNotifier.new,
);
