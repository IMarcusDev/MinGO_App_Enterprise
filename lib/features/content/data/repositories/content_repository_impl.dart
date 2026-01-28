import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/content_entities.dart';
import '../../domain/repositories/content_repository.dart';
import '../datasources/content_remote_datasource.dart';
import '../datasources/content_local_datasource.dart';

class ContentRepositoryImpl implements ContentRepository {
  final ContentRemoteDataSource remoteDataSource;
  final ContentLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ContentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<AgeCategory>>> getAgeCategories() async {
    // Intentar obtener del caché primero
    final cached = localDataSource.getCachedAgeCategories();
    
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getAgeCategories();
        // Guardar en caché
        await localDataSource.cacheAgeCategories(result);
        return Right(result);
      } on ServerException catch (e) {
        // Si falla pero tenemos caché, usar caché
        if (cached != null) return Right(cached);
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        if (cached != null) return Right(cached);
        return Left(ServerFailure(message: e.toString()));
      }
    }

    // Sin conexión, usar caché
    if (cached != null) {
      return Right(cached);
    }
    return const Left(NetworkFailure(
      message: 'Sin conexión y sin datos en caché',
    ));
  }

  @override
  Future<Either<Failure, List<LevelSection>>> getLevelSections({
    String? ageCategoryId,
  }) async {
    final cacheKey = ageCategoryId ?? 'all';
    final cached = localDataSource.getCachedLevelSections(cacheKey);

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getLevelSections();
        await localDataSource.cacheLevelSections(cacheKey, result);
        return Right(result);
      } on ServerException catch (e) {
        if (cached != null) return Right(cached);
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        if (cached != null) return Right(cached);
        return Left(ServerFailure(message: e.toString()));
      }
    }

    if (cached != null) {
      return Right(cached);
    }
    return const Left(NetworkFailure(
      message: 'Sin conexión y sin datos en caché',
    ));
  }

  @override
  Future<Either<Failure, List<ContentCategory>>> getContentCategories() async {
    final cached = localDataSource.getCachedContentCategories();

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getContentCategories();
        await localDataSource.cacheContentCategories(result);
        return Right(result);
      } on ServerException catch (e) {
        if (cached != null) return Right(cached);
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        if (cached != null) return Right(cached);
        return Left(ServerFailure(message: e.toString()));
      }
    }

    if (cached != null) {
      return Right(cached);
    }
    return const Left(NetworkFailure(
      message: 'Sin conexión y sin datos en caché',
    ));
  }

  @override
  Future<Either<Failure, List<Module>>> getModules({String? levelSectionId}) async {
    final cacheKey = levelSectionId ?? 'all';
    final cached = localDataSource.getCachedModules(cacheKey);

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getModules(
          levelSectionId: levelSectionId,
        );
        await localDataSource.cacheModules(cacheKey, result);
        return Right(result);
      } on ServerException catch (e) {
        if (cached != null) return Right(cached);
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        if (cached != null) return Right(cached);
        return Left(ServerFailure(message: e.toString()));
      }
    }

    if (cached != null) {
      return Right(cached);
    }
    return const Left(NetworkFailure(
      message: 'Sin conexión y sin datos en caché',
    ));
  }

  @override
  Future<Either<Failure, List<Lesson>>> getLessons(String moduleId) async {
    final cached = localDataSource.getCachedLessons(moduleId);

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getLessons(moduleId);
        await localDataSource.cacheLessons(moduleId, result);
        return Right(result);
      } on ServerException catch (e) {
        if (cached != null) return Right(cached);
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        if (cached != null) return Right(cached);
        return Left(ServerFailure(message: e.toString()));
      }
    }

    if (cached != null) {
      return Right(cached);
    }
    return const Left(NetworkFailure(
      message: 'Sin conexión y sin datos en caché',
    ));
  }

  @override
  Future<Either<Failure, Lesson>> getLessonById(String lessonId) async {
    final cached = localDataSource.getCachedLessonDetail(lessonId);

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getLessonById(lessonId);
        await localDataSource.cacheLessonDetail(result);
        return Right(result);
      } on ServerException catch (e) {
        if (cached != null) return Right(cached);
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        if (cached != null) return Right(cached);
        return Left(ServerFailure(message: e.toString()));
      }
    }

    if (cached != null) {
      return Right(cached);
    }
    return const Left(NetworkFailure(
      message: 'Sin conexión y sin datos en caché',
    ));
  }

  @override
  Future<Either<Failure, List<Activity>>> getActivities(String lessonId) async {
    final cached = localDataSource.getCachedActivities(lessonId);

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getActivities(lessonId);
        await localDataSource.cacheActivities(lessonId, result);
        return Right(result);
      } on ServerException catch (e) {
        if (cached != null) return Right(cached);
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        if (cached != null) return Right(cached);
        return Left(ServerFailure(message: e.toString()));
      }
    }

    if (cached != null) {
      return Right(cached);
    }
    return const Left(NetworkFailure(
      message: 'Sin conexión y sin datos en caché',
    ));
  }

  /// Limpiar todo el caché de contenido
  Future<void> clearCache() async {
    await localDataSource.clearContentCache();
  }

  @override
  Future<Either<Failure, SearchResult>> searchContent(String query) async {
    if (query.trim().isEmpty) {
      return const Right(SearchResult(modules: [], lessons: []));
    }

    final searchTerm = query.toLowerCase().trim();

    try {
      // Obtener todos los módulos
      final modulesResult = await getModules();
      List<Module> matchingModules = [];
      List<Lesson> matchingLessons = [];

      modulesResult.fold(
        (failure) => null,
        (modules) {
          // Filtrar módulos que coincidan
          matchingModules = modules.where((module) {
            return module.title.toLowerCase().contains(searchTerm) ||
                (module.description?.toLowerCase().contains(searchTerm) ?? false);
          }).toList();
        },
      );

      // Buscar en lecciones de cada módulo
      final allModulesResult = await getModules();
      await allModulesResult.fold(
        (failure) async => null,
        (modules) async {
          for (final module in modules) {
            final lessonsResult = await getLessons(module.id);
            lessonsResult.fold(
              (failure) => null,
              (lessons) {
                final matching = lessons.where((lesson) {
                  return lesson.title.toLowerCase().contains(searchTerm) ||
                      (lesson.description?.toLowerCase().contains(searchTerm) ?? false);
                });
                matchingLessons.addAll(matching);
              },
            );
          }
        },
      );

      return Right(SearchResult(
        modules: matchingModules,
        lessons: matchingLessons,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al buscar: $e'));
    }
  }
}
