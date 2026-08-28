import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(
        settings: initializationSettings,
      );
    } catch (_) {
      // Graceful fallback se as notificações não forem suportadas na plataforma
    }
  }

  static Future<void> showTimerCompletedNotification({
    required String taskTitle,
    int? durationMinutes,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'timer_channel_id',
        'Notificações de Timer',
        channelDescription: 'Alertas de conclusão de tarefas e hábitos',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      final subtitle = durationMinutes != null
          ? 'Você concluiu seus $durationMinutes minutos de foco!'
          : 'Sessão de foco concluída!';

      await _notificationsPlugin.show(
        id: 0,
        title: 'Tempo Concluído: $taskTitle 🎉',
        body: subtitle,
        notificationDetails: platformDetails,
      );
    } catch (_) {}
  }
}
