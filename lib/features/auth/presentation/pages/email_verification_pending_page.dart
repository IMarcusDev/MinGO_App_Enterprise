import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class EmailVerificationPendingPage extends StatelessWidget {
  final String? email;

  const EmailVerificationPendingPage({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthVerificationResentState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spaceL),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 80,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXL),
                
                // Título
                Text(
                  'Verifica tu email',
                  style: AppTypography.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spaceM),
                
                // Mensaje
                Text(
                  'Hemos enviado un enlace de verificación a:',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spaceS),
                
                // Email
                Text(
                  email ?? 'tu email',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spaceXL),
                
                // Instrucciones
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildStep('1', 'Revisa tu bandeja de entrada'),
                      const Divider(),
                      _buildStep('2', 'Haz clic en el enlace de verificación'),
                      const Divider(),
                      _buildStep('3', 'Regresa a la app e inicia sesión'),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXL),
                
                // Reenviar
                Text(
                  '¿No recibiste el email?',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceS),
                
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoadingState;
                    return TextButton.icon(
                      onPressed: isLoading || email == null
                          ? null
                          : () {
                              context.read<AuthBloc>().add(
                                    AuthResendVerificationEvent(email: email!),
                                  );
                            },
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(isLoading ? 'Enviando...' : 'Reenviar email'),
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.spaceXL),
                
                // Volver al login
                OutlinedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutEvent());
                    AppNavigator.goToLogin();
                  },
                  child: const Text('Volver al login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceS),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: AppTypography.labelMedium.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child: Text(text, style: AppTypography.bodyMedium),
          ),
        ],
      ),
    );
  }
}
