import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:theorypocket/shared/providers/app_state_provider.dart';

/// Root provider for the entire application state
final appStateProvider = ChangeNotifierProvider<AppStateNotifier>((ref) {
  return AppStateNotifier();
});

/// Convenience providers for individual slices of state
final userNameProvider = Provider<String>((ref) {
  return ref.watch(appStateProvider).userName;
});

final statsProvider = Provider<FeatureStats>((ref) {
  return ref.watch(appStateProvider).stats;
});

final recentActivityProvider = Provider<List<ActivityItem>>((ref) {
  return ref.watch(appStateProvider).recentActivity;
});
