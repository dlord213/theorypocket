import 'dart:io';

import 'package:chord_diagrams/chord_diagrams.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:theorypocket/app/router.dart';
import 'package:theorypocket/app/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── sqflite: use FFI on desktop (Linux / macOS / Windows) ─────────────────
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // ── Initialize chord_diagrams ──────────────────────────────────────────────
  await ChordDiagrams.ensureInitialized();

  // ── Style diagrams to match dark theme ────────────────────────────────────
  ChordDiagramsSettings.setBackgroundColor('#1A1133');
  ChordDiagramsSettings.setGridColor('#2D2050');
  ChordDiagramsSettings.setDotColor('#7C3AED');
  ChordDiagramsSettings.setDotStrokeColor('#9D5FF5');
  ChordDiagramsSettings.setFingerTextColor('#F8F7FF');
  ChordDiagramsSettings.setMutedColor('#6B5D8A');
  ChordDiagramsSettings.setFretNumberColor('#AA9EC7');
  ChordDiagramsSettings.setTuningColor('#6B5D8A');
  ChordDiagramsSettings.setTitleColor('#F8F7FF');

  // ── System UI ──────────────────────────────────────────────────────────────
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  runApp(
    const ProviderScope(
      child: TheoryPocketApp(),
    ),
  );
}

class TheoryPocketApp extends ConsumerWidget {
  const TheoryPocketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'TheoryPocket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: goRouter,
    );
  }
}
