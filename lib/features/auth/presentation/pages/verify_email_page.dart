import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyEmailPage extends StatefulWidget {
  final String? token;

  const VerifyEmailPage({super.key, this.token});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      // Verificar automáticamente al cargar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AuthBloc>().add(AuthVerifyEmailEvent(token: widget.token!));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthEmailVerifiedState) {
          // Esperar un momento y redirigir
          Future.delayed(const Duration(seconds: 2), () {
            AppNavigator.goToLogin();
          });
        } else if (state is AuthErrorState) {
          // Mantener en la página para mostrar error
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceXL),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthLoadingState) {
                  return _buildLoadingView();
                } else if (state is AuthEmailVerifiedState) {
                  return _buildSuccessView(state.message);
                } else if (state is AuthErrorState) {
                  return _buildErrorView(state.message);
                }
                return _buildLoadingView();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: AppColors.primary),
        const SizedBox(height: AppDimensions.spaceXL),
        Text(
          'Verificando tu email...',
          style: AppTypography.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccessView(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.spaceL),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, size: 80, color: AppColors.success),
        ),
        const SizedBox(height: AppDimensions.spaceXL),
        Text(
          '¡Email verificado!',
          style: AppTypography.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spaceM),
        Text(
          message,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spaceXL),
        Text(
          'Redirigiendo al login...',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textHint),
        ),
      ],
    );
  }

  Widget _buildErrorView(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.spaceL),
          decoration: BoxDecoration(
            color: AppColors.errorLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline, size: 80, color: AppColors.error),
        ),
        const SizedBox(height: AppDimensions.spaceXL),
        Text(
          'Error de verificación',
          style: AppTypography.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spaceM),
        Text(
          message,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spaceXL),
        ElevatedButton(
          onPressed: () => AppNavigator.goToLogin(),
          child: const Text('Ir al login'),
        ),
      ],
    );
  }
}
