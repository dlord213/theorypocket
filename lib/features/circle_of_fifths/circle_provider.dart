import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

enum CircleRing { major, minor, dim }

class CircleSelection {
  final int index;
  final CircleRing ring;

  const CircleSelection({required this.index, required this.ring});

  @override
  bool operator ==(Object other) =>
      other is CircleSelection &&
      other.index == index &&
      other.ring == ring;

  @override
  int get hashCode => Object.hash(index, ring);
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class CircleOfFifthsNotifier extends Notifier<CircleSelection?> {
  @override
  CircleSelection? build() => null;

  void select(int index, CircleRing ring) {
    final next = CircleSelection(index: index, ring: ring);
    state = (state == next) ? null : next;
    HapticFeedback.selectionClick();
  }

  void clear() => state = null;
}

final circleOfFifthsProvider =
    NotifierProvider<CircleOfFifthsNotifier, CircleSelection?>(
  CircleOfFifthsNotifier.new,
);
