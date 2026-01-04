import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

/// Servicio para manejar deep links en la aplicación
///
/// Maneja los enlaces de verificación de email y reset de contraseña
/// que llegan desde el backend en formato: mingo://verify-email?token=xxx
class DeepLinkService {
  final AuthRepository _authRepository;
  StreamSubscription? _sub;

  DeepLinkService(this._authRepository);

  /// Inicializar deep links
  ///
  /// Debe llamarse cuando la app arranca para capturar:
  /// 1. Links cuando la app se abre desde cerrada (getInitialUri)
  /// 2. Links mientras la app está abierta (uriLinkStream)
  Future<void> initDeepLinks(BuildContext context) async {
    // Manejar cuando la app se abre desde un link (app cerrada)
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null && context.mounted) {
        _handleDeepLink(initialUri, context);
      }
    } catch (e) {
      debugPrint('Error getting initial URI: $e');
    }

    // Escuchar links mientras la app está abierta
    _sub = uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null && context.mounted) {
          _handleDeepLink(uri, context);
        }
      },
      onError: (err) {
        debugPrint('Error listening to URI stream: $err');
      },
    );
  }

  /// Manejar el deep link recibido
  void _handleDeepLink(Uri uri, BuildContext context) {
    debugPrint('Deep link received: $uri');

    // Verificar el esquema
    if (uri.scheme != 'mingo') {
      debugPrint('Invalid scheme: ${uri.scheme}');
      return;
    }

    // Manejar según el host (ruta)
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

  /// Verificar email con token
  Future<void> _verifyEmail(String token, BuildContext context) async {
    // Mostrar loading
    _showLoading(context, 'Verificando email...');

    try {
      final result = await _authRepository.verifyEmail(token);

      if (!context.mounted) return;

      // Cerrar loading
      Navigator.of(context).pop();

      result.fold(
        (failure) {
          _showError(
            context,
            'Error al verificar email: ${failure.message}',
          );
        },
        (response) {
          _showSuccess(
            context,
            response.message,
          );

          // Navegar al login después de 2 segundos
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
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

  /// Navegar a la pantalla de reset de contraseña
  void _navigateToResetPassword(String token, BuildContext context) {
    Navigator.of(context).pushNamed(
      '/reset-password',
      arguments: token,
    );
  }

  /// Mostrar diálogo de loading
  void _showLoading(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  /// Mostrar mensaje de error
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Mostrar mensaje de éxito
  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Limpiar recursos
  void dispose() {
    _sub?.cancel();
  }
}
