import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mingo/core/notifications/notification_service.dart';
import 'package:mingo/features/progress/domain/entities/progress_entities.dart';

// ============================================
// EVENTS
// ============================================
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class InitializeNotificationsEvent extends NotificationEvent {
  const InitializeNotificationsEvent();
}

class CheckStreakStatusEvent extends NotificationEvent {
  final Streak streak;
  const CheckStreakStatusEvent(this.streak);
  @override
  List<Object?> get props => [streak];
}

class ScheduleDailyReminderEvent extends NotificationEvent {
  final int hour;
  final int minute;
  const ScheduleDailyReminderEvent({required this.hour, required this.minute});
  @override
  List<Object?> get props => [hour, minute];
}

class CancelDailyReminderEvent extends NotificationEvent {
  const CancelDailyReminderEvent();
}

class ShowLessonCompletedEvent extends NotificationEvent {
  final String lessonTitle;
  final int accuracy;
  const ShowLessonCompletedEvent({
    required this.lessonTitle,
    required this.accuracy,
  });
  @override
  List<Object?> get props => [lessonTitle, accuracy];
}

class ShowLevelUnlockedEvent extends NotificationEvent {
  final String levelName;
  const ShowLevelUnlockedEvent(this.levelName);
  @override
  List<Object?> get props => [levelName];
}

class ScheduleAssignmentReminderEvent extends NotificationEvent {
  final String assignmentId;
  final String title;
  final DateTime dueDate;
  const ScheduleAssignmentReminderEvent({
    required this.assignmentId,
    required this.title,
    required this.dueDate,
  });
  @override
  List<Object?> get props => [assignmentId, title, dueDate];
}

// ============================================
// STATES
// ============================================
abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitialState extends NotificationState {
  const NotificationInitialState();
}

class NotificationReadyState extends NotificationState {
  final bool permissionsGranted;
  final bool dailyReminderEnabled;
  const NotificationReadyState({
    required this.permissionsGranted,
    required this.dailyReminderEnabled,
  });
  @override
  List<Object?> get props => [permissionsGranted, dailyReminderEnabled];
}

class NotificationScheduledState extends NotificationState {
  final String message;
  const NotificationScheduledState(this.message);
  @override
  List<Object?> get props => [message];
}

class NotificationErrorState extends NotificationState {
  final String message;
  const NotificationErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// ============================================
// BLOC
// ============================================
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService _notificationService;
  
  // Tracking para no mostrar notificaciones duplicadas
  int? _lastStreakNotified;

  NotificationBloc({
    NotificationService? notificationService,
  }) : _notificationService = notificationService ?? NotificationService.instance,
       super(const NotificationInitialState()) {
    on<InitializeNotificationsEvent>(_onInitialize);
    on<CheckStreakStatusEvent>(_onCheckStreakStatus);
    on<ScheduleDailyReminderEvent>(_onScheduleDailyReminder);
    on<CancelDailyReminderEvent>(_onCancelDailyReminder);
    on<ShowLessonCompletedEvent>(_onShowLessonCompleted);
    on<ShowLevelUnlockedEvent>(_onShowLevelUnlocked);
    on<ScheduleAssignmentReminderEvent>(_onScheduleAssignmentReminder);
  }

  Future<void> _onInitialize(
    InitializeNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationService.init();
      final permissionsGranted = await _notificationService.requestPermissions();
      final dailyEnabled = await _notificationService.isDailyReminderEnabled();

      emit(NotificationReadyState(
        permissionsGranted: permissionsGranted,
        dailyReminderEnabled: dailyEnabled,
      ));
    } catch (e) {
      emit(NotificationErrorState(e.toString()));
    }
  }

  Future<void> _onCheckStreakStatus(
    CheckStreakStatusEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final streak = event.streak;

    // Solo mostrar si la racha cambió significativamente
    if (_lastStreakNotified == streak.currentStreak) return;

    if (streak.currentStreak > 0 && !streak.isActiveToday) {
      // Racha en peligro
      await _notificationService.scheduleStreakReminder(
        currentStreak: streak.currentStreak,
        hasActivityToday: false,
      );
    } else if (streak.isActiveToday && streak.currentStreak > 0) {
      // Cancelar alerta si ya practicó hoy
      await _notificationService.cancelNotification(
        NotificationService.streakWarningId,
      );
    }

    _lastStreakNotified = streak.currentStreak;
  }

  Future<void> _onScheduleDailyReminder(
    ScheduleDailyReminderEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationService.scheduleDailyReminder(
        hour: event.hour,
        minute: event.minute,
      );
      emit(NotificationScheduledState(
        'Recordatorio programado para las ${event.hour}:${event.minute.toString().padLeft(2, '0')}',
      ));
    } catch (e) {
      emit(NotificationErrorState(e.toString()));
    }
  }

  Future<void> _onCancelDailyReminder(
    CancelDailyReminderEvent event,
    Emitter<NotificationState> emit,
  ) async {
    await _notificationService.cancelDailyReminder();
    emit(const NotificationScheduledState('Recordatorio cancelado'));
  }

  Future<void> _onShowLessonCompleted(
    ShowLessonCompletedEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final emoji = event.accuracy >= 80 ? '🌟' : event.accuracy >= 60 ? '👍' : '💪';
    
    await _notificationService.showNotification(
      id: 50,
      title: '$emoji ¡Lección completada!',
      body: '"${event.lessonTitle}" - ${event.accuracy}% de precisión',
      payload: 'lesson_completed',
    );
  }

  Future<void> _onShowLevelUnlocked(
    ShowLevelUnlockedEvent event,
    Emitter<NotificationState> emit,
  ) async {
    await _notificationService.showNotification(
      id: 51,
      title: '🎉 ¡Nuevo nivel desbloqueado!',
      body: 'Has desbloqueado: ${event.levelName}',
      payload: 'level_unlocked',
    );
  }

  Future<void> _onScheduleAssignmentReminder(
    ScheduleAssignmentReminderEvent event,
    Emitter<NotificationState> emit,
  ) async {
    await _notificationService.scheduleAssignmentReminder(
      assignmentId: event.assignmentId,
      title: event.title,
      dueDate: event.dueDate,
    );
  }
}
