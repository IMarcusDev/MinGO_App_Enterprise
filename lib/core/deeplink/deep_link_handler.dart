import 'package:flutter/material.dart';
import '../config/routes.dart';
import 'deep_link_state.dart';

class DeepLinkHandler {
  static void handleUri(BuildContext context, Uri uri) {
    if (uri.scheme != 'mingo') return;

    debugPrint('Deep link recibido: $uri');

    if (uri.host == 'verify-email') {
      final token = uri.queryParameters['token'];

      if (token == null || token.isEmpty) return;

      DeepLinkState.isHandling = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.verifyEmail,
          (route) => false,
          arguments: token,
        );
      });
    }
  }
}
