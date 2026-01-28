import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_links/app_links.dart';

import 'core/config/routes.dart';
import 'core/config/app_theme.dart';
import 'core/deeplink/deep_link_handler.dart';
import 'core/deeplink/deep_link_state.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/settings/presentation/bloc/theme_bloc.dart';
import 'features/assessment/presentation/bloc/assessment_bloc.dart';
import 'features/content/presentation/bloc/content_import_bloc.dart';
import 'features/premium/presentation/bloc/membership_bloc.dart';
import 'features/premium/presentation/bloc/translator_bloc.dart';
import 'features/hand_tracking/presentation/bloc/hand_tracking_bloc.dart';

import 'injection_container.dart';

class MingoApp extends StatefulWidget {
  const MingoApp({super.key});

  @override
  State<MingoApp> createState() => _MingoAppState();
}

class _MingoAppState extends State<MingoApp> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // 🔹 Manejo de deep link con app CERRADA (initial link)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error getting initial deep link: $e');
    }

    // 🔹 Manejo de deep link con app ABIERTA (stream)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleDeepLink(uri),
      onError: (e) => debugPrint('Deep link stream error: $e'),
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Deep link recibido: $uri');
    if (uri.scheme != 'mingo') return;

    DeepLinkState.isHandling = true;

    final context = AppNavigator.navigatorKey.currentContext;
    if (context != null) {
      DeepLinkHandler.handleUri(context, uri);
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckStatusEvent()),
        ),
        BlocProvider<ThemeBloc>(
          create: (_) => sl<ThemeBloc>()..add(const LoadThemeEvent()),
        ),
        BlocProvider<AssessmentBloc>(
          create: (_) => sl<AssessmentBloc>(),
        ),
        BlocProvider<ContentImportBloc>(
          create: (_) => sl<ContentImportBloc>(),
        ),
        BlocProvider<MembershipBloc>(
          create: (_) => sl<MembershipBloc>()..add(const LoadMembershipEvent()),
        ),
        BlocProvider<TranslatorBloc>(
          create: (_) => sl<TranslatorBloc>(),
        ),
        BlocProvider<HandTrackingBloc>(
          create: (_) => sl<HandTrackingBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'MinGO',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            navigatorKey: AppNavigator.navigatorKey,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
