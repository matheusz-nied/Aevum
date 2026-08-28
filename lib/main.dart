import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/tasks/data/session_repository.dart';
import 'features/tasks/data/task_repository.dart';
import 'features/tasks/presentation/screens/home_screen.dart';
import 'features/tasks/providers/task_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive para armazenamento local NoSQL
  await Hive.initFlutter();
  final taskRepo = await TaskRepository.init();
  final sessionRepo = await SessionRepository.init();

  // Inicializar serviço de notificações locais
  await NotificationService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(taskRepo),
        sessionRepositoryProvider.overrideWithValue(sessionRepo),
      ],
      child: const TimingApp(),
    ),
  );
}

class TimingApp extends StatelessWidget {
  const TimingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Tema "Floresta Nebulosa" fixo
      home: const HomeScreen(),
    );
  }
}
