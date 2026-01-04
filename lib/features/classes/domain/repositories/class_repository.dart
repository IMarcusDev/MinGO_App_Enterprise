import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/class_entities.dart';

/// Repositorio de clases
abstract class ClassRepository {
  // ==================== DOCENTE ====================
  
  /// Crear una nueva clase
  Future<Either<Failure, SchoolClass>> createClass(CreateClassParams params);
  
  /// Obtener clases que imparto
  Future<Either<Failure, ClassList>> getTeacherClasses();
  
  /// Actualizar clase
  Future<Either<Failure, SchoolClass>> updateClass(String classId, UpdateClassParams params);
  
  /// Eliminar clase
  Future<Either<Failure, void>> deleteClass(String classId);
  
  /// Crear tarea en una clase
  Future<Either<Failure, Assignment>> createAssignment(String classId, CreateAssignmentParams params);
  
  /// Obtener estudiantes de una clase con su progreso
  Future<Either<Failure, List<StudentProgress>>> getClassStudents(String classId);

  // ==================== ESTUDIANTE ====================
  
  /// Unirse a una clase con código
  Future<Either<Failure, Enrollment>> joinClass(JoinClassParams params);
  
  /// Salir de una clase
  Future<Either<Failure, void>> leaveClass(String classId);
  
  /// Obtener clases en las que estoy inscrito
  Future<Either<Failure, ClassList>> getEnrolledClasses();

  // ==================== COMÚN ====================
  
  /// Obtener detalle de una clase
  Future<Either<Failure, SchoolClass>> getClassById(String classId);
  
  /// Obtener tareas de una clase
  Future<Either<Failure, List<Assignment>>> getClassAssignments(String classId);
}
