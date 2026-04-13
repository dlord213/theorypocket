import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:theorypocket/features/progression_builder/models/song_model.dart';
import 'package:theorypocket/features/progression_builder/providers/progression_provider.dart';

class SongEditorPage extends ConsumerStatefulWidget {
  final Song? existing;

  const SongEditorPage({super.key, this.existing});

  @override
  ConsumerState<SongEditorPage> createState() => _SongEditorPageState();
}

class _SongEditorPageState extends ConsumerState<SongEditorPage> {
  late TextEditingController _titleCtrl;

  static const _roots = [
    'C', 'C#', 'Db', 'D', 'D#', 'Eb', 'E',
    'F', 'F#', 'Gb', 'G', 'G#', 'Ab', 'A', 'A#', 'Bb', 'B',
  ];

  static const _qualities = [
    '', 'm', '7', 'maj7', 'm7', 'dim', 'aug', 'sus2', 'sus4',
  ];

  static const _qualityLabels = [
    'maj', 'min', 'dom7', 'maj7', 'min7', 'dim', 'aug', 'sus2', 'sus4',
  ];

  static const _allKeys = [
    'C', 'G', 'D', 'A', 'E', 'B', 'F#', 'Db', 'Ab', 'Eb', 'Bb', 'F',
  ];

  String _selectedRoot = 'C';
  String _selectedQuality = '';

  @override
  void initState() {
    super.initState();
    final song = widget.existing;
    _titleCtrl = TextEditingController(text: song?.title ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(editorProvider.notifier);
      if (song != null) {
        notifier.load(song);
      } else {
        notifier.reset();
      }
      _titleCtrl.addListener(
        () => ref.read(editorProvider.notifier).setTitle(_titleCtrl.text),
      );
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final editor = ref.read(editorProvider);
    if (!editor.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Text(
            'Add a title and at least one chord.',
            style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onError),
          ),
        ),
      );
      return;
    }

    final notifier = ref.read(songsProvider.notifier);
    final now = DateTime.now();

    if (widget.existing != null) {
      await notifier.updateSong(
        widget.existing!.copyWith(
          title: editor.title.trim(),
          key: editor.key,
          chords: editor.chords,
        ),
      );
    } else {
      await notifier.addSong(
        Song(
          title: editor.title.trim(),
          key: editor.key,
          chords: editor.chords,
          createdAt: now,
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(editorProvider);
    final isEdit = widget.existing != null;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEdit ? 'Edit Song' : 'New Song',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AnimatedOpacity(
              opacity: editor.isValid ? 1 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: _save,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 8),

            _SectionLabel('Song Title'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              style: GoogleFonts.spaceGrotesk(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              cursorColor: Theme.of(context).colorScheme.primary,
              decoration: InputDecoration(
                hintText: 'e.g. Autumn Leaves, My Song...',
                hintStyle: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8), fontSize: 14),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel('Key'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allKeys.map((k) {
                final sel = editor.key == k;
                return GestureDetector(
                  onTap: () => ref.read(editorProvider.notifier).setKey(k),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                      ),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      k,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: sel ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                _SectionLabel('Progression'),
                const Spacer(),
                if (editor.chords.isNotEmpty)
                  GestureDetector(
                    onTap: () => ref.read(editorProvider.notifier).clearChords(),
                    child: Text(
                      'Clear all',
                      style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).colorScheme.error),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            editor.chords.isEmpty
                ? Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                    ),
                    child: Center(
                      child: Text(
                        'Pick chords below to build your progression',
                        style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8)),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 52,
                    child: ReorderableListView.builder(
                      scrollDirection: Axis.horizontal,
                      buildDefaultDragHandles: true,
                      proxyDecorator: (child, index, animation) => child,
                      onReorder: (o, n) =>
                          ref.read(editorProvider.notifier).reorderChords(o, n),
                      itemCount: editor.chords.length,
                      itemBuilder: (_, i) => _ChordSequenceChip(
                        key: ValueKey('$i-${editor.chords[i]}'),
                        chord: editor.chords[i],
                        onRemove: () =>
                            ref.read(editorProvider.notifier).removeChord(i),
                      ),
                    ),
                  ),

            const SizedBox(height: 24),

            _SectionLabel('Add Chord'),
            const SizedBox(height: 12),

            Text(
              'Root',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _roots.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final r = _roots[i];
                  final sel = _selectedRoot == r;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedRoot = r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      width: 44,
                      decoration: BoxDecoration(
                        color: sel ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          r,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: sel ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Quality',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_qualities.length, (i) {
                final q = _qualities[i];
                final label = _qualityLabels[i];
                final sel = _selectedQuality == q;
                return GestureDetector(
                  onTap: () => setState(() => _selectedQuality = q),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? Theme.of(context).colorScheme.tertiary.withOpacity(0.2) : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                        color: sel ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                final chord = '$_selectedRoot$_selectedQuality';
                ref.read(editorProvider.notifier).addChord(chord);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Add  $_selectedRoot$_selectedQuality',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _ChordSequenceChip extends StatelessWidget {
  final String chord;
  final VoidCallback onRemove;

  const _ChordSequenceChip({
    super.key,
    required this.chord,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              chord,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
