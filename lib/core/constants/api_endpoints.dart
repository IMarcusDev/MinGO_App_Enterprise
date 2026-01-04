/// Endpoints de la API MinGO
/// 
/// Alineados con el backend NestJS v1.1.0
class ApiEndpoints {
  // ============================================
  // AUTH
  // ============================================
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authProfile = '/auth/profile';
  static const String authVerifyEmail = '/auth/verify-email';
  static const String authResendVerification = '/auth/resend-verification';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';

  // ============================================
  // CHILDREN
  // ============================================
  static const String children = '/children';
  static String childById(String id) => '/children/$id';

  // ============================================
  // CONTENT
  // ============================================
  static const String contentLevels = '/content/levels';
  static String contentLevelById(String id) => '/content/levels/$id';
  static String contentLevelModules(String levelId) => '/content/levels/$levelId/modules';
  static String contentModuleById(String id) => '/content/modules/$id';
  static String contentModuleActivities(String moduleId) => '/content/modules/$moduleId/activities';
  static String contentActivityById(String id) => '/content/activities/$id';
  static const String contentSearch = '/content/search';

  // ============================================
  // PROGRESS
  // ============================================
  static const String progress = '/progress';
  static String progressByUser(String userId) => '/progress/user/$userId';
  static String progressActivity(String activityId) => '/progress/activity/$activityId';
  static const String progressUnlockedLevels = '/progress/unlocked-levels';

  // ============================================
  // CLASSES (para docentes)
  // ============================================
  static const String classes = '/classes';
  static String classById(String id) => '/classes/$id';
  static String classStudents(String classId) => '/classes/$classId/students';
  static String classEnroll(String classId) => '/classes/$classId/enroll';
  static const String classAssignments = '/classes/assignments';
}
