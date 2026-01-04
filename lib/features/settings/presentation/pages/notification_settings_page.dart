import 'package:flutter/material.dart';
import 'package:mingo/core/constants/app_colors.dart';
import 'package:mingo/core/constants/app_dimensions.dart';
import 'package:mingo/core/constants/app_typography.dart';
import 'package:mingo/core/notifications/notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final _notificationService = NotificationService.instance;
  
  bool _dailyReminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 18, minute: 0);
  bool _streakReminderEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final dailyEnabled = await _notificationService.isDailyReminderEnabled();
    final time = await _notificationService.getDailyReminderTime();

    setState(() {
      _dailyReminderEnabled = dailyEnabled;
      if (time != null) _reminderTime = time;
      _isLoading = false;
    });
  }

  Future<void> _toggleDailyReminder(bool value) async {
    setState(() => _dailyReminderEnabled = value);

    if (value) {
      // Solicitar permisos si es necesario
      final granted = await _notificationService.requestPermissions();
      if (!granted) {
        setState(() => _dailyReminderEnabled = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Necesitas permitir notificaciones'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      await _notificationService.scheduleDailyReminder(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recordatorio programado para las ${_formatTime(_reminderTime)}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      await _notificationService.cancelDailyReminder();
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      helpText: 'Selecciona la hora del recordatorio',
    );

    if (picked != null && picked != _reminderTime) {
      setState(() => _reminderTime = picked);

      if (_dailyReminderEnabled) {
        await _notificationService.scheduleDailyReminder(
          hour: picked.hour,
          minute: picked.minute,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Recordatorio actualizado para las ${_formatTime(picked)}',
              ),
            ),
          );
        }
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _testNotification() async {
    await _notificationService.showNotification(
      id: 999,
      title: '🎉 ¡Notificación de prueba!',
      body: 'Las notificaciones están funcionando correctamente',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.space),
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radius),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mantén tu motivación',
                              style: AppTypography.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Los recordatorios te ayudan a mantener una práctica constante',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spaceL),

                // Recordatorio diario
                _buildSection(
                  title: 'Recordatorio Diario',
                  icon: Icons.alarm,
                  children: [
                    SwitchListTile(
                      title: const Text('Activar recordatorio'),
                      subtitle: Text(
                        _dailyReminderEnabled
                            ? 'Te recordaremos practicar cada día'
                            : 'Recibe un recordatorio diario para practicar',
                      ),
                      value: _dailyReminderEnabled,
                      onChanged: _toggleDailyReminder,
                      activeColor: AppColors.primary,
                    ),
                    if (_dailyReminderEnabled) ...[
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('Hora del recordatorio'),
                        subtitle: Text(_formatTime(_reminderTime)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _selectTime,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: AppDimensions.space),

                // Alertas de racha
                _buildSection(
                  title: 'Alertas de Racha',
                  icon: Icons.local_fire_department,
                  children: [
                    SwitchListTile(
                      title: const Text('Alerta de racha en peligro'),
                      subtitle: const Text(
                        'Te avisamos si estás por perder tu racha',
                      ),
                      value: _streakReminderEnabled,
                      onChanged: (value) {
                        setState(() => _streakReminderEnabled = value);
                      },
                      activeColor: AppColors.warning,
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.space),

                // Otras notificaciones
                _buildSection(
                  title: 'Otras Notificaciones',
                  icon: Icons.notifications,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.assignment),
                      title: const Text('Recordatorios de tareas'),
                      subtitle: const Text('Para estudiantes con tareas pendientes'),
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeColor: AppColors.secondary,
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.emoji_events),
                      title: const Text('Logros y celebraciones'),
                      subtitle: const Text('Cuando completes niveles o lecciones'),
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeColor: AppColors.secondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spaceXL),

                // Botón de prueba
                OutlinedButton.icon(
                  onPressed: _testNotification,
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar notificación de prueba'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(AppDimensions.space),
                  ),
                ),

                const SizedBox(height: AppDimensions.space),

                // Info
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.textHint, size: 20),
                      const SizedBox(width: AppDimensions.spaceS),
                      Expanded(
                        child: Text(
                          'Las notificaciones se envían localmente y no requieren conexión a internet',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
