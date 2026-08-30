import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/providers/app_state_provider.dart';
import 'core/debug/screenshot_fixtures.dart';
import 'core/services/app_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/tasks/data/session_repository.dart';
import 'features/tasks/data/task_repository.dart';
import 'features/tasks/presentation/screens/home_screen.dart';
import 'features/tasks/providers/task_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disponibiliza os nomes de dias e meses em português em todas as plataformas.
  await initializeDateFormatting('pt_BR');

  // Inicializar Hive para armazenamento local NoSQL
  await Hive.initFlutter();
  final taskRepo = await TaskRepository.init();
  final sessionRepo = await SessionRepository.init();

  final preferences = AppPreferences(await SharedPreferences.getInstance());

  const screenshotMode = bool.fromEnvironment('AEVUM_SCREENSHOT_MODE');
  if (kDebugMode && screenshotMode) {
    await ScreenshotFixtures.load(
      tasks: taskRepo,
      sessions: sessionRepo,
      preferences: preferences,
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(taskRepo),
        sessionRepositoryProvider.overrideWithValue(sessionRepo),
        appPreferencesProvider.overrideWithValue(preferences),
      ],
      child: const AevumApp(),
    ),
  );
}

class AevumApp extends StatelessWidget {
  const AevumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aevum',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Tema "Floresta Nebulosa" fixo
      builder: (context, child) => TickerMode(
        enabled: !MediaQuery.disableAnimationsOf(context),
        child: child ?? const SizedBox.shrink(),
      ),
      home: const AppGate(),
    );
  }
}

class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experience = ref.watch(appStateProvider);
    if (!experience.onboardingCompleted) {
      return const OnboardingScreen();
    }

    return HomeScreen(
      openCreateOnStart: experience.shouldCreateFirstHabit,
      onInitialCreateOpened: () =>
          ref.read(appStateProvider.notifier).consumeFirstHabitRequest(),
    );
  }
}
