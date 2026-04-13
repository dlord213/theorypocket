import 'package:flutter/foundation.dart';

// ── Models ──────────────────────────────────────────────────────────────────

enum ActivityType { chord, circle, progression }

class ActivityItem {
  final String label;
  final String detail;
  final ActivityType type;
  final DateTime timestamp;

  const ActivityItem({
    required this.label,
    required this.detail,
    required this.type,
    required this.timestamp,
  });
}

class FeatureStats {
  final int chordsExplored;
  final int keysLearned;
  final int progressionsSaved;

  const FeatureStats({
    required this.chordsExplored,
    required this.keysLearned,
    required this.progressionsSaved,
  });
}

// ── Notifiers ────────────────────────────────────────────────────────────────

class AppStateNotifier extends ChangeNotifier {
  String _userName = 'Musician';
  FeatureStats _stats = const FeatureStats(
    chordsExplored: 24,
    keysLearned: 7,
    progressionsSaved: 5,
  );

  List<ActivityItem> _recentActivity = [
    ActivityItem(
      label: 'Looked up C Major 7',
      detail: 'Chord Dictionary',
      type: ActivityType.chord,
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    ActivityItem(
      label: 'Explored G → D → Am → F',
      detail: 'Progression Builder',
      type: ActivityType.progression,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ActivityItem(
      label: 'Navigated to A minor',
      detail: 'Circle of Fifths',
      type: ActivityType.circle,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    ActivityItem(
      label: 'Looked up Dm7♭5',
      detail: 'Chord Dictionary',
      type: ActivityType.chord,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    ActivityItem(
      label: 'Built jazz ii-V-I in Bb',
      detail: 'Progression Builder',
      type: ActivityType.progression,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  String get userName => _userName;
  FeatureStats get stats => _stats;
  List<ActivityItem> get recentActivity => List.unmodifiable(_recentActivity);

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void addActivity(ActivityItem item) {
    _recentActivity = [item, ..._recentActivity.take(9)];
    notifyListeners();
  }

  void incrementChords() {
    _stats = FeatureStats(
      chordsExplored: _stats.chordsExplored + 1,
      keysLearned: _stats.keysLearned,
      progressionsSaved: _stats.progressionsSaved,
    );
    notifyListeners();
  }
}
