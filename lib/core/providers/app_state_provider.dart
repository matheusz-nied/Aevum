import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aevum/core/services/app_preferences.dart';
import 'package:aevum/features/tasks/providers/task_providers.dart';

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  throw UnimplementedError('appPreferencesProvider must be initialized');
});

class AppExperienceState {
  const AppExperienceState({
    required this.onboardingCompleted,
    this.shouldCreateFirstHabit = false,
  });

  final bool onboardingCompleted;
  final bool shouldCreateFirstHabit;

  AppExperienceState copyWith({
    bool? onboardingCompleted,
    bool? shouldCreateFirstHabit,
  }) {
    return AppExperienceState(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      shouldCreateFirstHabit:
          shouldCreateFirstHabit ?? this.shouldCreateFirstHabit,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppExperienceState> {
  AppStateNotifier(this._preferences, this._tasks, this._sessions)
    : super(
        AppExperienceState(
          onboardingCompleted: _preferences.onboardingCompleted,
        ),
      );

  final AppPreferences _preferences;
  final TaskListNotifier _tasks;
  final SessionListNotifier _sessions;

  Future<void> completeOnboarding() async {
    await _preferences.setOnboardingCompleted(true);
    state = const AppExperienceState(
      onboardingCompleted: true,
      shouldCreateFirstHabit: true,
    );
  }

  void consumeFirstHabitRequest() {
    if (!state.shouldCreateFirstHabit) return;
    state = state.copyWith(shouldCreateFirstHabit: false);
  }

  Future<void> resetAllData() async {
    await _tasks.clearAll();
    await _sessions.clearAll();
    await _preferences.reset();
    state = const AppExperienceState(onboardingCompleted: false);
  }
}

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppExperienceState>((ref) {
      return AppStateNotifier(
        ref.watch(appPreferencesProvider),
        ref.read(taskListProvider.notifier),
        ref.read(sessionListProvider.notifier),
      );
    });
