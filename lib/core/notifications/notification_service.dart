import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de notificaciones locales
class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();

  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // IDs de notificaciones
  static const int dailyReminderId = 1;
  static const int streakWarningId = 2;
  static const int streakLostId = 3;
  static const int assignmentReminderId = 100; // 100+ para tareas

  // Keys de preferencias
  static const String _dailyReminderEnabledKey = 'daily_reminder_enabled';
  static const String _dailyReminderHourKey = 'daily_reminder_hour';
  static const String _dailyReminderMinuteKey = 'daily_reminder_minute';
  static const String _streakReminderEnabledKey = 'streak_reminder_enabled';

  /// Inicializar el servicio
  Future<void> init() async {
    if (_initialized) return;

    // Inicializar timezone
    tz_data.initializeTimeZones();

    // Configuración Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canal de notificaciones para Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    _initialized = true;

    // Restaurar notificaciones programadas
    await _restoreScheduledNotifications();
  }

  /// Crear canales de notificación (Android 8+)
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Canal para recordatorios diarios
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_reminder',
          'Recordatorio Diario',
          description: 'Notificaciones de recordatorio para practicar',
          importance: Importance.high,
        ),
      );

      // Canal para alertas de racha
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'streak_alerts',
          'Alertas de Racha',
          description: 'Notificaciones sobre tu racha de aprendizaje',
          importance: Importance.high,
        ),
      );

      // Canal para tareas
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'assignments',
          'Tareas',
          description: 'Notificaciones sobre tareas pendientes',
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  /// Callback cuando se toca una notificación
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    debugPrint('Notificación tocada: $payload');
    // Aquí se puede navegar a pantallas específicas según el payload
  }

  /// Solicitar permisos (iOS principalmente)
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }

    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final result = await androidPlugin?.requestNotificationsPermission();
      return result ?? false;
    }

    return true;
  }

  // ============================================
  // NOTIFICACIONES INMEDIATAS
  // ============================================

  /// Mostrar notificación simple
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'daily_reminder',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == 'daily_reminder' 
          ? 'Recordatorio Diario' 
          : channelId == 'streak_alerts'
              ? 'Alertas de Racha'
              : 'Tareas',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Mostrar notificación de racha en peligro
  Future<void> showStreakWarning(int currentStreak) async {
    await showNotification(
      id: streakWarningId,
      title: '🔥 ¡Tu racha está en peligro!',
      body: 'Tienes una racha de $currentStreak días. ¡Practica hoy para no perderla!',
      payload: 'streak_warning',
      channelId: 'streak_alerts',
    );
  }

  /// Mostrar notificación de racha perdida
  Future<void> showStreakLost(int previousStreak) async {
    await showNotification(
      id: streakLostId,
      title: '💔 Racha perdida',
      body: 'Perdiste tu racha de $previousStreak días. ¡Empieza una nueva hoy!',
      payload: 'streak_lost',
      channelId: 'streak_alerts',
    );
  }

  /// Mostrar notificación de tarea pendiente
  Future<void> showAssignmentReminder({
    required String assignmentId,
    required String title,
    required int daysRemaining,
  }) async {
    final body = daysRemaining == 0
        ? '⚠️ La tarea "$title" vence hoy'
        : daysRemaining == 1
            ? '⏰ La tarea "$title" vence mañana'
            : '📝 La tarea "$title" vence en $daysRemaining días';

    await showNotification(
      id: assignmentReminderId + assignmentId.hashCode % 100,
      title: 'Tarea pendiente',
      body: body,
      payload: 'assignment:$assignmentId',
      channelId: 'assignments',
    );
  }

  // ============================================
  // NOTIFICACIONES PROGRAMADAS
  // ============================================

  /// Programar recordatorio diario
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await cancelNotification(dailyReminderId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Si ya pasó la hora hoy, programar para mañana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final androidDetails = const AndroidNotificationDetails(
      'daily_reminder',
      'Recordatorio Diario',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Mensajes variados para no ser repetitivo
    final messages = [
      ('🎯 ¡Hora de practicar!', 'Dedica unos minutos a aprender lengua de señas'),
      ('👋 ¡Hola!', 'Tu práctica diaria te espera'),
      ('🌟 ¡Sigue aprendiendo!', 'Cada día cuentas con una nueva oportunidad'),
      ('📚 Momento de aprender', 'Practica hoy y mantén tu racha'),
      ('🚀 ¡Vamos!', 'Un poco de práctica hace la diferencia'),
    ];

    final messageIndex = DateTime.now().day % messages.length;
    final (title, body) = messages[messageIndex];

    await _notifications.zonedSchedule(
      dailyReminderId,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repetir diariamente
      payload: 'daily_reminder',
    );

    // Guardar preferencias
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyReminderEnabledKey, true);
    await prefs.setInt(_dailyReminderHourKey, hour);
    await prefs.setInt(_dailyReminderMinuteKey, minute);

    debugPrint('Recordatorio diario programado para $hour:$minute');
  }

  /// Programar alerta de racha (ejecutar al final del día)
  Future<void> scheduleStreakReminder({
    required int currentStreak,
    bool hasActivityToday = false,
  }) async {
    if (hasActivityToday) {
      // Si ya practicó hoy, cancelar la alerta
      await cancelNotification(streakWarningId);
      return;
    }

    if (currentStreak == 0) return;

    // Programar para las 8pm si no ha practicado
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      20, // 8pm
      0,
    );

    // Si ya pasó las 8pm, mostrar inmediatamente
    if (scheduledDate.isBefore(now)) {
      await showStreakWarning(currentStreak);
      return;
    }

    final androidDetails = const AndroidNotificationDetails(
      'streak_alerts',
      'Alertas de Racha',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      streakWarningId,
      '🔥 ¡Tu racha está en peligro!',
      'Tienes una racha de $currentStreak días. ¡Practica hoy para no perderla!',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'streak_warning',
    );

    // Guardar preferencia
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_streakReminderEnabledKey, true);
  }

  /// Programar recordatorio de tarea
  Future<void> scheduleAssignmentReminder({
    required String assignmentId,
    required String title,
    required DateTime dueDate,
  }) async {
    final now = DateTime.now();
    final daysUntilDue = dueDate.difference(now).inDays;

    // Programar recordatorio 1 día antes si es posible
    if (daysUntilDue > 1) {
      final reminderDate = tz.TZDateTime.from(
        dueDate.subtract(const Duration(days: 1)),
        tz.local,
      );

      if (reminderDate.isAfter(tz.TZDateTime.now(tz.local))) {
        final androidDetails = const AndroidNotificationDetails(
          'assignments',
          'Tareas',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        );

        const iosDetails = DarwinNotificationDetails();

        final details = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        await _notifications.zonedSchedule(
          assignmentReminderId + assignmentId.hashCode % 100,
          '📝 Tarea pendiente',
          'La tarea "$title" vence mañana',
          reminderDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'assignment:$assignmentId',
        );
      }
    }
  }

  // ============================================
  // CANCELACIÓN
  // ============================================

  /// Cancelar notificación por ID
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancelar recordatorio diario
  Future<void> cancelDailyReminder() async {
    await cancelNotification(dailyReminderId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyReminderEnabledKey, false);
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // ============================================
  // PREFERENCIAS
  // ============================================

  /// Verificar si el recordatorio diario está activo
  Future<bool> isDailyReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dailyReminderEnabledKey) ?? false;
  }

  /// Obtener hora del recordatorio diario
  Future<TimeOfDay?> getDailyReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_dailyReminderHourKey);
    final minute = prefs.getInt(_dailyReminderMinuteKey);
    
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Restaurar notificaciones programadas después de reiniciar
  Future<void> _restoreScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Restaurar recordatorio diario
    final dailyEnabled = prefs.getBool(_dailyReminderEnabledKey) ?? false;
    if (dailyEnabled) {
      final hour = prefs.getInt(_dailyReminderHourKey) ?? 18;
      final minute = prefs.getInt(_dailyReminderMinuteKey) ?? 0;
      await scheduleDailyReminder(hour: hour, minute: minute);
    }
  }

  /// Obtener notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
