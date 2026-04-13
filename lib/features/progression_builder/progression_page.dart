import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:theorypocket/app/theme.dart';
import 'package:theorypocket/features/progression_builder/providers/progression_provider.dart';
import 'package:theorypocket/features/progression_builder/song_editor_page.dart';
import 'package:theorypocket/features/progression_builder/widgets/song_card.dart';

class ProgressionPage extends ConsumerWidget {
  const ProgressionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsProvider);
    final notifier = ref.read(songsProvider.notifier);

    void openEditor({song}) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SongEditorPage(existing: song),
          fullscreenDialog: true,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [AppColors.textPrimary, AppColors.primaryLight],
            stops: [0.4, 1.0],
          ).createShader(b),
          child: Text(
            'Progression Builder',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openEditor(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'New Song',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: songsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text(
            'Error loading songs:\n$e',
            style: GoogleFonts.inter(color: AppColors.rose),
            textAlign: TextAlign.center,
          ),
        ),
        data: (songs) {
          if (songs.isEmpty) {
            return _EmptyState(onTap: () => openEditor());
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            physics: const BouncingScrollPhysics(),
            itemCount: songs.length,
            itemBuilder: (context, i) {
              final song = songs[i];
              return SongCard(
                song: song,
                onEdit: () => openEditor(song: song),
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.surfaceElevated,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                      title: Text(
                        'Delete "${song.title}"?',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      content: Text(
                        'This progression will be permanently removed.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            'Delete',
                            style: GoogleFonts.inter(
                              color: AppColors.rose,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && song.id != null) {
                    await notifier.deleteSong(song.id!);
                  }
                },
                onTranspose: (halfSteps) async {
                  await notifier.transposeSong(song, halfSteps);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.teal.withOpacity(0.9),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                        content: Text(
                          halfSteps > 0
                              ? '▲ Transposed up ½ step'
                              : '▼ Transposed down ½ step',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.teal.withOpacity(0.3)),
              ),
              child: const Center(
                child: Text('🎼', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No progressions yet',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start building your first chord progression. '
              'Set a key, string chords together, and save.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.gradientPrimary,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Create first progression',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
