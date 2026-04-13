import 'package:chord_diagrams/chord_diagrams.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:theorypocket/features/chord_dictionary/chord_provider.dart';
import 'package:theorypocket/features/chord_dictionary/chord_theory.dart';

class ChordPage extends ConsumerWidget {
  const ChordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRoot = ref.watch(selectedRootProvider);
    final selectedSuffix = ref.watch(selectedSuffixProvider);
    final chordName = ref.watch(chordNameProvider);
    final chordNotes = ref.watch(chordNotesProvider);
    final description = ref.watch(chordDescriptionProvider);
    final voicingIdx = ref.watch(voicingIndexProvider);

    // Voicing count from the package catalog
    final posCount = ChordDiagrams.getPositionCount(chordName);
    final safeVoicing = posCount > 0 ? voicingIdx.clamp(0, posCount - 1) : 0;

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: colorScheme.onSurface,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: [colorScheme.onSurface, colorScheme.primary],
            stops: const [0.4, 1.0],
          ).createShader(b),
          child: Text(
            'Chord Dictionary',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 8),

            // ── Root note grid ──────────────────────────────────────────────
            _SectionLabel('Root Note'),
            const SizedBox(height: 10),
            _NoteGrid(
              notes: chromaticScale,
              selected: selectedRoot,
              onSelect: (n) {
                ref.read(selectedRootProvider.notifier).state = n;
                ref.read(voicingIndexProvider.notifier).state = 0;
              },
            ),
            const SizedBox(height: 20),

            // ── Quality / suffix selector ───────────────────────────────────
            _SectionLabel('Quality'),
            const SizedBox(height: 10),
            _QualitySelector(
              selected: selectedSuffix,
              onSelect: (s) {
                ref.read(selectedSuffixProvider.notifier).state = s;
                ref.read(voicingIndexProvider.notifier).state = 0;
              },
            ),
            const SizedBox(height: 24),

            // ── Chord info card ─────────────────────────────────────────────
            _ChordInfoCard(
              chordName: chordName,
              chordNotes: chordNotes,
              description: description,
            ),
            const SizedBox(height: 16),

            // ── Diagram + voicing stepper ───────────────────────────────────
            _DiagramSection(
              chordName: chordName,
              posCount: posCount,
              voicingIdx: safeVoicing,
              onVoicingChanged: (v) =>
                  ref.read(voicingIndexProvider.notifier).state = v,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Note grid ─────────────────────────────────────────────────────────────────

class _NoteGrid extends StatelessWidget {
  final List<String> notes;
  final String selected;
  final void Function(String) onSelect;

  const _NoteGrid({
    required this.notes,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (_, i) {
        final note = notes[i];
        final isSelected = note == selected;
        return GestureDetector(
          onTap: () => onSelect(note),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16), // Material 3 rounding
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
            ),
            child: Center(
              child: Text(
                note,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Quality selector ──────────────────────────────────────────────────────────

class _QualitySelector extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;

  const _QualitySelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: primarySuffixes.map((s) {
        final label = suffixDisplayName[s] ?? (s.isEmpty ? 'Major' : s);
        final isSel = s == selected;
        return GestureDetector(
          onTap: () => onSelect(s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: isSel
                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.18)
                  : Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSel ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                width: isSel ? 1.5 : 1,
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                color: isSel ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Chord info card ───────────────────────────────────────────────────────────

class _ChordInfoCard extends StatelessWidget {
  final String chordName;
  final List<String> chordNotes;
  final String description;

  const _ChordInfoCard({
    required this.chordName,
    required this.chordNotes,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.14),
            Theme.of(context).colorScheme.primary.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chord name + play button row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chordName.isEmpty ? '—' : chordName,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.0,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
              const Spacer(),
              // Play button — placeholder for future audio
              _PlayButton(),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: Theme.of(context).colorScheme.outline.withOpacity(0.5), height: 1),
          const SizedBox(height: 14),

          // Notes row
          Text(
            'Notes',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...chordNotes.asMap().entries.map((e) {
                final isRoot = e.key == 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isRoot
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.22)
                          : Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isRoot
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                            : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      e.value,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isRoot
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Play button (placeholder) ─────────────────────────────────────────────────

class _PlayButton extends StatefulWidget {
  const _PlayButton();

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) async {
          await _ctrl.reverse();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 2),
                content: Row(
                  children: [
                    const Text('🔇', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      'Audio coming soon — add files manually',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: Theme.of(context).colorScheme.onSecondary,
            size: 28,
          ),
        ),
      ),
    );
  }
}

// ── Diagram section ───────────────────────────────────────────────────────────

class _DiagramSection extends StatelessWidget {
  final String chordName;
  final int posCount;
  final int voicingIdx;
  final void Function(int) onVoicingChanged;

  const _DiagramSection({
    required this.chordName,
    required this.posCount,
    required this.voicingIdx,
    required this.onVoicingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiagram = posCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SectionLabel('Guitar Diagram'),
            const Spacer(),
            if (hasDiagram && posCount > 1) ...[
              Text(
                'Voicing ${voicingIdx + 1} / $posCount',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              _VoicingArrow(
                icon: Icons.chevron_left_rounded,
                enabled: voicingIdx > 0,
                onTap: () => onVoicingChanged(voicingIdx - 1),
              ),
              const SizedBox(width: 4),
              _VoicingArrow(
                icon: Icons.chevron_right_rounded,
                enabled: voicingIdx < posCount - 1,
                onTap: () => onVoicingChanged(voicingIdx + 1),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
          ),
          child: hasDiagram
              ? Center(
                  child: ChordDiagram(
                    chord: chordName,
                    instrument: Instrument.guitar,
                    position: voicingIdx,
                    width: MediaQuery.of(context).size.width * 0.55,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('🎸', style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        'No diagram available for $chordName',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _VoicingArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _VoicingArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled ? Theme.of(context).colorScheme.surfaceContainerHigh : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
        ),
      ),
    );
  }
}

// ── Shared label ──────────────────────────────────────────────────────────────

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
