import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/content_entities.dart';
import '../repositories/content_repository.dart';

/// Obtener categorías de edad
class GetAgeCategoriesUseCase {
  final ContentRepository repository;

  GetAgeCategoriesUseCase(this.repository);

  Future<Either<Failure, List<AgeCategory>>> call() {
    return repository.getAgeCategories();
  }
}

/// Obtener secciones de nivel
class GetLevelSectionsUseCase {
  final ContentRepository repository;

  GetLevelSectionsUseCase(this.repository);

  Future<Either<Failure, List<LevelSection>>> call() {
    return repository.getLevelSections();
  }
}

/// Obtener categorías de contenido
class GetContentCategoriesUseCase {
  final ContentRepository repository;

  GetContentCategoriesUseCase(this.repository);

  Future<Either<Failure, List<ContentCategory>>> call() {
    return repository.getContentCategories();
  }
}

/// Obtener módulos
class GetModulesUseCase {
  final ContentRepository repository;

  GetModulesUseCase(this.repository);

  Future<Either<Failure, List<Module>>> call({String? levelSectionId}) {
    return repository.getModules(levelSectionId: levelSectionId);
  }
}

/// Obtener lecciones de un módulo
class GetLessonsUseCase {
  final ContentRepository repository;

  GetLessonsUseCase(this.repository);

  Future<Either<Failure, List<Lesson>>> call(String moduleId) {
    return repository.getLessons(moduleId);
  }
}

/// Obtener detalle de una lección
class GetLessonDetailUseCase {
  final ContentRepository repository;

  GetLessonDetailUseCase(this.repository);

  Future<Either<Failure, Lesson>> call(String lessonId) {
    return repository.getLessonById(lessonId);
  }
}

/// Obtener actividades de una lección
class GetActivitiesUseCase {
  final ContentRepository repository;

  GetActivitiesUseCase(this.repository);

  Future<Either<Failure, List<Activity>>> call(String lessonId) {
    return repository.getActivities(lessonId);
  }
}
