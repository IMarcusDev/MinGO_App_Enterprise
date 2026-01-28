import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/config/app_config.dart';
import 'core/cache/cache_service.dart';
import 'core/network/api_client.dart';
import 'core/network/network_info.dart';
import 'core/services/deep_link_service.dart';

// Auth
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Content
import 'features/content/data/datasources/content_remote_datasource.dart';
import 'features/content/data/datasources/content_local_datasource.dart';
import 'features/content/data/repositories/content_repository_impl.dart';
import 'features/content/domain/repositories/content_repository.dart';
import 'features/content/domain/usecases/content_usecases.dart';
import 'features/content/presentation/bloc/content_bloc.dart';

// Children
import 'features/children/data/datasources/children_remote_datasource.dart';
import 'features/children/data/repositories/children_repository_impl.dart';
import 'features/children/domain/repositories/children_repository.dart';
import 'features/children/domain/usecases/children_usecases.dart';
import 'features/children/presentation/bloc/children_bloc.dart';

// Progress
import 'features/progress/data/datasources/progress_remote_datasource.dart';
import 'features/progress/data/datasources/progress_local_datasource.dart';
import 'features/progress/data/repositories/progress_repository_impl.dart';
import 'features/progress/domain/repositories/progress_repository.dart';
import 'features/progress/domain/usecases/progress_usecases.dart';
import 'features/progress/presentation/bloc/progress_bloc.dart';

// Classes
import 'features/classes/data/datasources/class_remote_datasource.dart';
import 'features/classes/data/repositories/class_repository_impl.dart';
import 'features/classes/domain/repositories/class_repository.dart';
import 'features/classes/domain/usecases/class_usecases.dart';
import 'features/classes/presentation/bloc/class_bloc.dart';

// Notifications
import 'features/settings/presentation/bloc/notification_bloc.dart';
import 'features/settings/presentation/bloc/theme_bloc.dart';

// Assessment
import 'features/assessment/presentation/bloc/assessment_bloc.dart';

// Content Import
import 'features/content/presentation/bloc/content_import_bloc.dart';

// Premium
import 'features/premium/presentation/bloc/membership_bloc.dart';
import 'features/premium/presentation/bloc/translator_bloc.dart';

// Hand Tracking
import 'features/hand_tracking/presentation/bloc/hand_tracking_bloc.dart';

// Achievements
import 'features/achievements/data/datasources/achievement_local_datasource.dart';
import 'features/achievements/data/repositories/achievement_repository_impl.dart';
import 'features/achievements/domain/repositories/achievement_repository.dart';
import 'features/achievements/presentation/bloc/achievement_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ============================================
  // External
  // ============================================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  sl.registerLazySingleton(() => secureStorage);
  
  sl.registerLazySingleton(() => Connectivity());

  // Cache Service (singleton ya inicializado en main.dart)
  sl.registerLazySingleton<CacheService>(() => CacheService.instance);

  // Dio
  sl.registerLazySingleton(() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.instance.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    return dio;
  });

  // ============================================
  // Core
  // ============================================
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(dio: sl(), secureStorage: sl()),
  );

  sl.registerLazySingleton<DeepLinkService>(
    () => DeepLinkService(sl()),
  );

  // ============================================
  // Auth Feature
  // ============================================
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: sl(),
      sharedPreferences: sl(),
    ),
  );
  
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Auth Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailUseCase(sl()));
  sl.registerLazySingleton(() => ResendVerificationUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => RefreshTokenUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));

  // Auth BLoC
  sl.registerFactory(() => AuthBloc(
    loginUseCase: sl(),
    registerUseCase: sl(),
    logoutUseCase: sl(),
    getCurrentUserUseCase: sl(),
    checkAuthStatusUseCase: sl(),
    verifyEmailUseCase: sl(),
    resendVerificationUseCase: sl(),
    forgotPasswordUseCase: sl(),
    resetPasswordUseCase: sl(),
    refreshTokenUseCase: sl(),
    updateProfileUseCase: sl(),
    changePasswordUseCase: sl(),
    deleteAccountUseCase: sl(),
  ));

  // ============================================
  // Content Feature
  // ============================================
  sl.registerLazySingleton<ContentRemoteDataSource>(
    () => ContentRemoteDataSourceImpl(apiClient: sl()),
  );
  
  sl.registerLazySingleton<ContentLocalDataSource>(
    () => ContentLocalDataSourceImpl(cacheService: sl()),
  );
  
  sl.registerLazySingleton<ContentRepository>(
    () => ContentRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Content Use Cases
  sl.registerLazySingleton(() => GetAgeCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetLevelSectionsUseCase(sl()));
  sl.registerLazySingleton(() => GetContentCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetModulesUseCase(sl()));
  sl.registerLazySingleton(() => GetLessonsUseCase(sl()));
  sl.registerLazySingleton(() => GetLessonDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetActivitiesUseCase(sl()));
  
  // Content BLoC
  sl.registerFactory(() => ContentBloc(
    getLevelSectionsUseCase: sl(),
    getModulesUseCase: sl(),
    getLessonsUseCase: sl(),
    getLessonDetailUseCase: sl(),
    getActivitiesUseCase: sl(),
    getContentCategoriesUseCase: sl(),
  ));

  // ============================================
  // Children Feature
  // ============================================
  sl.registerLazySingleton<ChildrenRemoteDataSource>(
    () => ChildrenRemoteDataSourceImpl(apiClient: sl()),
  );
  
  sl.registerLazySingleton<ChildrenRepository>(
    () => ChildrenRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Children Use Cases
  sl.registerLazySingleton(() => GetChildrenUseCase(sl()));
  sl.registerLazySingleton(() => CreateChildUseCase(sl()));
  sl.registerLazySingleton(() => GetChildByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateChildUseCase(sl()));
  sl.registerLazySingleton(() => DeleteChildUseCase(sl()));
  
  // Children BLoC
  sl.registerFactory(() => ChildrenBloc(
    getChildrenUseCase: sl(),
    createChildUseCase: sl(),
    updateChildUseCase: sl(),
    deleteChildUseCase: sl(),
  ));

  // ============================================
  // Progress Feature
  // ============================================
  sl.registerLazySingleton<ProgressRemoteDataSource>(
    () => ProgressRemoteDataSourceImpl(apiClient: sl()),
  );
  
  sl.registerLazySingleton<ProgressLocalDataSource>(
    () => ProgressLocalDataSourceImpl(cacheService: sl()),
  );
  
  sl.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Progress Use Cases
  sl.registerLazySingleton(() => RecordAttemptUseCase(sl()));
  sl.registerLazySingleton(() => CompleteLessonUseCase(sl()));
  sl.registerLazySingleton(() => GetUserProgressUseCase(sl()));
  sl.registerLazySingleton(() => GetUserStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetStreakUseCase(sl()));
  sl.registerLazySingleton(() => GetDailyActivityUseCase(sl()));
  
  // Progress BLoC
  sl.registerFactory(() => ProgressBloc(
    recordAttemptUseCase: sl(),
    completeLessonUseCase: sl(),
    getUserProgressUseCase: sl(),
    getUserStatsUseCase: sl(),
    getStreakUseCase: sl(),
    getDailyActivityUseCase: sl(),
  ));

  // ============================================
  // Classes Feature
  // ============================================
  sl.registerLazySingleton<ClassRemoteDataSource>(
    () => ClassRemoteDataSourceImpl(apiClient: sl()),
  );
  
  sl.registerLazySingleton<ClassRepository>(
    () => ClassRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Classes Use Cases - Docente
  sl.registerLazySingleton(() => CreateClassUseCase(sl()));
  sl.registerLazySingleton(() => GetTeacherClassesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateClassUseCase(sl()));
  sl.registerLazySingleton(() => DeleteClassUseCase(sl()));
  sl.registerLazySingleton(() => CreateAssignmentUseCase(sl()));
  sl.registerLazySingleton(() => GetClassStudentsUseCase(sl()));
  
  // Classes Use Cases - Estudiante
  sl.registerLazySingleton(() => JoinClassUseCase(sl()));
  sl.registerLazySingleton(() => LeaveClassUseCase(sl()));
  sl.registerLazySingleton(() => GetEnrolledClassesUseCase(sl()));
  
  // Classes Use Cases - Común
  sl.registerLazySingleton(() => GetClassByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetClassAssignmentsUseCase(sl()));
  
  // Classes BLoC
  sl.registerFactory(() => ClassBloc(
    getTeacherClassesUseCase: sl(),
    getEnrolledClassesUseCase: sl(),
    getClassByIdUseCase: sl(),
    getClassAssignmentsUseCase: sl(),
    getClassStudentsUseCase: sl(),
    createClassUseCase: sl(),
    updateClassUseCase: sl(),
    deleteClassUseCase: sl(),
    joinClassUseCase: sl(),
    leaveClassUseCase: sl(),
    createAssignmentUseCase: sl(),
  ));

  // ============================================
  // Notifications Feature
  // ============================================
  sl.registerFactory(() => NotificationBloc());

  // ============================================
  // Theme
  // ============================================
  sl.registerFactory(() => ThemeBloc(prefs: sl()));

  // ============================================
  // Assessment Feature
  // ============================================
  sl.registerFactory(() => AssessmentBloc(prefs: sl()));

  // ============================================
  // Content Import Feature
  // ============================================
  sl.registerFactory(() => ContentImportBloc());

  // ============================================
  // Premium Feature
  // ============================================
  sl.registerFactory(() => MembershipBloc(prefs: sl()));
  sl.registerFactory(() => TranslatorBloc(prefs: sl()));

  // ============================================
  // Hand Tracking Feature
  // ============================================
  sl.registerFactory(() => HandTrackingBloc());

  // ============================================
  // Achievements Feature
  // ============================================
  sl.registerLazySingleton<AchievementLocalDataSource>(
    () => AchievementLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<AchievementRepository>(
    () => AchievementRepositoryImpl(localDataSource: sl()),
  );

  sl.registerFactory(() => AchievementBloc(repository: sl()));
}
