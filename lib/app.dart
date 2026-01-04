import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mingo/features/auth/presentation/bloc/auth_event.dart';

import 'core/config/routes.dart';
import 'core/config/app_theme.dart';
import 'core/services/deep_link_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
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
  late final DeepLinkService _deepLinkService;

  @override
  void initState() {
    super.initState();
    _deepLinkService = sl<DeepLinkService>();

    // Inicializar deep links después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _deepLinkService.initDeepLinks(context);
      }
    });
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
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
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.generateRoute,
            navigatorKey: AppNavigator.navigatorKey,
          );
        },
      ),
    );
  }
}
