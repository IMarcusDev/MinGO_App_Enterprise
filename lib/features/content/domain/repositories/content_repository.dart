import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/content_entities.dart';

/// Repositorio de contenido educativo
abstract class ContentRepository {
  /// Obtener categorías de edad (público)
  Future<Either<Failure, List<AgeCategory>>> getAgeCategories();

  /// Obtener secciones de nivel con estado de desbloqueo
  Future<Either<Failure, List<LevelSection>>> getLevelSections();

  /// Obtener categorías de contenido (público)
  Future<Either<Failure, List<ContentCategory>>> getContentCategories();

  /// Obtener módulos, opcionalmente filtrados por nivel
  Future<Either<Failure, List<Module>>> getModules({String? levelSectionId});

  /// Obtener lecciones de un módulo
  Future<Either<Failure, List<Lesson>>> getLessons(String moduleId);

  /// Obtener detalle de una lección
  Future<Either<Failure, Lesson>> getLessonById(String lessonId);

  /// Obtener actividades de una lección
  Future<Either<Failure, List<Activity>>> getActivities(String lessonId);

  /// Buscar contenido por término
  Future<Either<Failure, SearchResult>> searchContent(String query);
}

/// Resultado de búsqueda
class SearchResult {
  final List<Module> modules;
  final List<Lesson> lessons;

  const SearchResult({
    required this.modules,
    required this.lessons,
  });

  bool get isEmpty => modules.isEmpty && lessons.isEmpty;
  int get totalCount => modules.length + lessons.length;
}
