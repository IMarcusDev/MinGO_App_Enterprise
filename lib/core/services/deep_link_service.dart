import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

import '../config/routes.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

class DeepLinkService {
  final AuthRepository _authRepository;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  /// 🔐 Flag GLOBAL para bloquear navegación del Splash
  static bool hasPendingDeepLink = false;

  DeepLinkService(this._authRepository);

  Future<void> initDeepLinks(BuildContext context) async {
    // 1️⃣ App cerrada
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null && context.mounted) {
        hasPendingDeepLink = true;
        _handleDeepLink(uri, context);
      }
    } catch (e) {
      debugPrint('Initial deep link error: $e');
    }

    // 2️⃣ App abierta / background
    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        if (context.mounted) {
          hasPendingDeepLink = true;
          _handleDeepLink(uri, context);
        }
      },
      onError: (e) => debugPrint('Deep link stream error: $e'),
    );
  }

  void _handleDeepLink(Uri uri, BuildContext context) {
    debugPrint('Deep link recibido: $uri');

    if (uri.scheme != 'mingo') {
      hasPendingDeepLink = false;
      return;
    }

    switch (uri.host) {
      case 'verify-email':
        final token = uri.queryParameters['token'];
        if (token != null) {
          AppNavigator.pushNamed(
            AppRoutes.verifyEmail,
            arguments: token,
          );
        }
        hasPendingDeepLink = false;
        break;

      case 'reset-password':
        final token = uri.queryParameters['token'];
        if (token != null) {
          AppNavigator.pushNamed(
            AppRoutes.resetPassword,
            arguments: token,
          );
        }
        hasPendingDeepLink = false;
        break;

      default:
        debugPrint('Deep link no reconocido: ${uri.host}');
        hasPendingDeepLink = false;
    }
  }

  Future<void> _verifyEmail(String token, BuildContext context) async {
    _loading(context, 'Verificando email...');

    final result = await _authRepository.verifyEmail(token);

    if (!context.mounted) return;
    Navigator.of(context).pop();

    result.fold(
      (failure) {
        _error(context, failure.message);
        hasPendingDeepLink = false;
      },
      (success) {
        _success(context, success.message);
        Future.delayed(const Duration(seconds: 2), () {
          AppNavigator.pushNamedAndRemoveUntil(
            AppRoutes.login,
            (r) => false,
          );
          hasPendingDeepLink = false;
        });
      },
    );
  }

  void _loading(BuildContext context, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(msg)),
          ],
        ),
      ),
    );
  }

  void _error(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _success(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  void dispose() {
    _sub?.cancel();
  }
}
