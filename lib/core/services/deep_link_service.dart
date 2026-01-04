import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart'; // <--- Nueva librería
import '../../features/auth/domain/repositories/auth_repository.dart';

class DeepLinkService {
  final AuthRepository _authRepository;
  StreamSubscription? _sub;
  final _appLinks = AppLinks(); // <--- Instancia de AppLinks

  DeepLinkService(this._authRepository);

  Future<void> initDeepLinks(BuildContext context) async {
    // 1. Manejar link inicial (App cerrada)
    try {
      final initialUri = await _appLinks.getInitialLink(); // <--- Cambio aquí
      if (initialUri != null && context.mounted) {
        _handleDeepLink(initialUri, context);
      }
    } catch (e) {
      debugPrint('Error getting initial URI: $e');
    }

    // 2. Escuchar links (App abierta/segundo plano)
    _sub = _appLinks.uriLinkStream.listen( // <--- Cambio aquí
      (Uri uri) {
        if (context.mounted) {
          _handleDeepLink(uri, context);
        }
      },
      onError: (err) {
        debugPrint('Error listening to URI stream: $err');
      },
    );
  }

  // --- El resto del código es IDÉNTICO al que tenías ---

  void _handleDeepLink(Uri uri, BuildContext context) {
    debugPrint('Deep link received: $uri');

    // Verificar el esquema (mingo://)
    if (uri.scheme != 'mingo') {
      debugPrint('Invalid scheme: ${uri.scheme}');
      return;
    }

    switch (uri.host) {
      case 'verify-email':
        final token = uri.queryParameters['token'];
        if (token != null) {
          _verifyEmail(token, context);
        } else {
          _showError(context, 'Token de verificación no encontrado');
        }
        break;

      case 'reset-password':
        final token = uri.queryParameters['token'];
        if (token != null) {
          _navigateToResetPassword(token, context);
        } else {
          _showError(context, 'Token de reset no encontrado');
        }
        break;

      default:
        debugPrint('Unknown deep link host: ${uri.host}');
    }
  }

  Future<void> _verifyEmail(String token, BuildContext context) async {
    _showLoading(context, 'Verificando email...');
    try {
      final result = await _authRepository.verifyEmail(token);
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Cerrar loading

      result.fold(
        (failure) => _showError(context, 'Error: ${failure.message}'),
        (response) {
          _showSuccess(context, response.message);
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
            }
          });
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      _showError(context, 'Error inesperado: $e');
    }
  }

  void _navigateToResetPassword(String token, BuildContext context) {
    Navigator.of(context).pushNamed('/reset-password', arguments: token);
  }

  void _showLoading(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Row(children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Expanded(child: Text(message)),
        ]),
      ),
    );
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  void dispose() {
    _sub?.cancel();
  }
}