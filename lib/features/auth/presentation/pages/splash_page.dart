import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/routes.dart';
import '../../../../core/deeplink/deep_link_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // ⛔ NO navegar si hay deep link activo
        if (DeepLinkState.isHandling) return;

        if (state is AuthAuthenticatedState) {
          AppNavigator.goToHome();
        } else if (state is AuthUnauthenticatedState) {
          AppNavigator.goToLogin();
        } else if (state is AuthEmailVerificationPendingState) {
          AppNavigator.pushReplacementNamed(
            AppRoutes.emailVerificationPending,
            arguments: state.email,
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🤟', style: TextStyle(fontSize: 60)),
                SizedBox(height: 24),
                Text(
                  'MinGO',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 48),
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
