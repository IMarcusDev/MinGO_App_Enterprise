import 'package:flutter/material.dart';

// Auth pages
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/auth/presentation/pages/email_verification_pending_page.dart';

// Content pages
import '../../features/content/presentation/pages/home_page.dart';
import '../../features/content/presentation/pages/teacher_home_page.dart';
import '../../features/content/presentation/pages/main_home_wrapper.dart';
import '../../features/content/presentation/pages/level_detail_page.dart';
import '../../features/content/presentation/pages/module_detail_page.dart';
import '../../features/content/presentation/pages/activity_page.dart';
import '../../features/content/presentation/pages/search_page.dart';

// Activities pages
import '../../features/activities/presentation/pages/interactive_activity_page.dart';
import '../../features/content/domain/entities/content_entities.dart';

// Children pages
import '../../features/children/presentation/pages/children_list_page.dart';
import '../../features/children/presentation/pages/child_form_page.dart';

// Progress pages
import '../../features/progress/presentation/pages/progress_page.dart';

// Classes pages
import '../../features/classes/presentation/pages/teacher_classes_page.dart';
import '../../features/classes/presentation/pages/student_classes_page.dart';
import '../../features/classes/presentation/pages/class_detail_page.dart';

// Settings pages
import '../../features/settings/presentation/pages/notification_settings_page.dart';
import '../../features/settings/presentation/pages/appearance_settings_page.dart';
import '../../features/settings/presentation/pages/animations_demo_page.dart';

// Assessment pages
import '../../features/assessment/presentation/pages/assessment_page.dart';
import '../../features/assessment/presentation/pages/assessment_result_page.dart';

// Onboarding pages
import '../../features/onboarding/presentation/pages/onboarding_page.dart';

// Content Import pages
import '../../features/content/presentation/pages/import_content_page.dart';

// Premium pages
import '../../features/premium/presentation/pages/membership_page.dart';
import '../../features/premium/presentation/pages/translator_page.dart';
import '../../features/premium/presentation/pages/dynamic_learning_page.dart';

// Hand Tracking pages
import '../../features/hand_tracking/presentation/pages/sign_practice_page.dart';

// Profile pages (dentro de auth por ahora)
import '../../features/auth/presentation/pages/profile_page.dart';

/// Rutas de la aplicación
class AppRoutes {
  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyEmail = '/verify-email';
  static const String emailVerificationPending = '/email-verification-pending';
  
  // Main
  static const String home = '/home';
  static const String parentHome = '/parent-home';
  static const String teacherHome = '/teacher-home';
  static const String search = '/search';
  static const String profile = '/profile';
  
  // Content
  static const String levelDetail = '/level';
  static const String moduleDetail = '/module';
  static const String activity = '/activity';
  static const String interactiveActivity = '/interactive-activity';
  
  // Children
  static const String children = '/children';
  static const String childForm = '/child-form';
  
  // Progress
  static const String progress = '/progress';
  
  // Classes
  static const String teacherClasses = '/teacher-classes';
  static const String studentClasses = '/student-classes';
  static const String classDetail = '/class-detail';
  
  // Settings
  static const String notificationSettings = '/notification-settings';
  static const String appearanceSettings = '/appearance-settings';
  static const String animationsDemo = '/animations-demo';
  
  // Onboarding
  static const String onboarding = '/onboarding';
  
  // Assessment (Prueba de conocimiento)
  static const String assessment = '/assessment';
  static const String assessmentResult = '/assessment-result';
  
  // Content Import (Docente)
  static const String importContent = '/import-content';
  
  // Join class (alias para student classes)
  static const String joinClass = '/join-class';
  
  // Premium / Membresía
  static const String membership = '/membership';
  static const String translator = '/translator';
  static const String dynamicLearning = '/dynamic-learning';
  
  // Hand Tracking / Nivel Avanzado
  static const String signPractice = '/sign-practice';
  static const String advancedLevel = '/advanced-level';
}

/// Router de la aplicación
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ============================================
      // Auth Routes
      // ============================================
      case AppRoutes.splash:
        return _buildRoute(const SplashPage(), settings);
        
      case AppRoutes.login:
        return _buildRoute(const LoginPage(), settings);
        
      case AppRoutes.register:
        return _buildRoute(const RegisterPage(), settings);
        
      case AppRoutes.forgotPassword:
        return _buildRoute(const ForgotPasswordPage(), settings);
        
      case AppRoutes.resetPassword:
        final token = settings.arguments as String?;
        return _buildRoute(ResetPasswordPage(token: token), settings);
        
      case AppRoutes.verifyEmail:
        final token = settings.arguments as String?;
        return _buildRoute(VerifyEmailPage(token: token), settings);
        
      case AppRoutes.emailVerificationPending:
        final email = settings.arguments as String?;
        return _buildRoute(EmailVerificationPendingPage(email: email), settings);
      
      // ============================================
      // Main Routes
      // ============================================
      case AppRoutes.home:
        // El wrapper decide qué home mostrar según el rol
        return _buildRoute(const MainHomeWrapper(), settings);
      
      case AppRoutes.parentHome:
        // Home específico para padres (aprendizaje)
        return _buildRoute(const HomePage(), settings);
      
      case AppRoutes.teacherHome:
        // Home específico para docentes (gestión)
        return _buildRoute(const TeacherHomePage(), settings);
        
      case AppRoutes.search:
        return _buildRoute(const SearchPage(), settings);
        
      case AppRoutes.profile:
        return _buildRoute(const ProfilePage(), settings);
      
      // ============================================
      // Content Routes
      // ============================================
      case AppRoutes.levelDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          LevelDetailPage(
            levelId: args['levelId'],
            levelName: args['levelName'],
          ),
          settings,
        );
        
      case AppRoutes.moduleDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          ModuleDetailPage(
            moduleId: args['moduleId'],
            moduleName: args['moduleName'],
          ),
          settings,
        );
        
      case AppRoutes.activity:
        final activityId = settings.arguments as String;
        return _buildRoute(ActivityPage(activityId: activityId), settings);
        
      case AppRoutes.interactiveActivity:
        final activity = settings.arguments as Activity;
        return _buildRoute(InteractiveActivityPage(activity: activity), settings);
      
      // ============================================
      // Children Routes
      // ============================================
      case AppRoutes.children:
        return _buildRoute(const ChildrenListPage(), settings);
        
      case AppRoutes.childForm:
        final childId = settings.arguments as String?;
        return _buildRoute(ChildFormPage(childId: childId), settings);
      
      // ============================================
      // Progress Routes
      // ============================================
      case AppRoutes.progress:
        return _buildRoute(const ProgressPage(), settings);
      
      // ============================================
      // Classes Routes
      // ============================================
      case AppRoutes.teacherClasses:
        return _buildRoute(const TeacherClassesPage(), settings);
        
      case AppRoutes.studentClasses:
        return _buildRoute(const StudentClassesPage(), settings);
        
      case AppRoutes.classDetail:
        final classId = settings.arguments as String;
        return _buildRoute(ClassDetailPage(classId: classId), settings);
      
      // ============================================
      // Settings Routes
      // ============================================
      case AppRoutes.notificationSettings:
        return _buildRoute(const NotificationSettingsPage(), settings);
      
      case AppRoutes.appearanceSettings:
        return _buildRoute(const AppearanceSettingsPage(), settings);
      
      case AppRoutes.animationsDemo:
        return _buildRoute(const AnimationsDemoPage(), settings);
      
      // ============================================
      // Onboarding Routes
      // ============================================
      case AppRoutes.onboarding:
        return _buildRoute(const OnboardingPage(), settings);
      
      // ============================================
      // Assessment Routes
      // ============================================
      case AppRoutes.assessment:
        return _buildRoute(const AssessmentPage(), settings);
      
      case AppRoutes.assessmentResult:
        return _buildRoute(const AssessmentResultPage(), settings);
      
      // ============================================
      // Content Import Routes
      // ============================================
      case AppRoutes.importContent:
        final classId = settings.arguments as String?;
        return _buildRoute(ImportContentPage(classId: classId), settings);
      
      case AppRoutes.joinClass:
        return _buildRoute(const StudentClassesPage(), settings);
      
      // ============================================
      // Premium Routes
      // ============================================
      case AppRoutes.membership:
        return _buildRoute(const MembershipPage(), settings);
      
      case AppRoutes.translator:
        return _buildRoute(const TranslatorPage(), settings);
      
      case AppRoutes.dynamicLearning:
        return _buildRoute(const DynamicLearningPage(), settings);
      
      // ============================================
      // Hand Tracking Routes
      // ============================================
      case AppRoutes.signPractice:
        return _buildRoute(const SignPracticePage(), settings);
      
      case AppRoutes.advancedLevel:
        return _buildRoute(const SignPracticePage(), settings);
      
      // ============================================
      // Default
      // ============================================
      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static PageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}

/// Navigator helper para navegación global
class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState get _navigator => navigatorKey.currentState!;

  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return _navigator.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T>(String routeName, {Object? arguments}) {
    return _navigator.pushReplacementNamed<T, void>(routeName, arguments: arguments);
  }

  static Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName, 
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return _navigator.pushNamedAndRemoveUntil<T>(
      routeName, 
      predicate,
      arguments: arguments,
    );
  }

  static void pop<T>([T? result]) {
    _navigator.pop<T>(result);
  }

  static void popUntil(bool Function(Route<dynamic>) predicate) {
    _navigator.popUntil(predicate);
  }

  /// Navegar al home limpiando el stack
  static void goToHome() {
    pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  /// Navegar al login limpiando el stack
  static void goToLogin() {
    pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }
}
