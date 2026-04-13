import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:theorypocket/features/circle_of_fifths/circle_page.dart';
import 'package:theorypocket/features/chord_dictionary/chord_page.dart';
import 'package:theorypocket/features/dashboard/dashboard_page.dart';
import 'package:theorypocket/features/progression_builder/progression_page.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String circle = '/circle';
  static const String chords = '/chords';
  static const String progression = '/progression';
}

final goRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppRoutes.dashboard,
      name: 'dashboard',
      pageBuilder: (context, state) => _buildPage(
        context,
        state,
        const DashboardPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.circle,
      name: 'circle',
      pageBuilder: (context, state) => _buildPage(
        context,
        state,
        const CirclePage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.chords,
      name: 'chords',
      pageBuilder: (context, state) => _buildPage(
        context,
        state,
        const ChordPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.progression,
      name: 'progression',
      pageBuilder: (context, state) => _buildPage(
        context,
        state,
        const ProgressionPage(),
      ),
    ),
  ],
);

CustomTransitionPage<void> _buildPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
