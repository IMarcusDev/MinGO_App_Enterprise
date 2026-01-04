import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/class_entities.dart';
import '../repositories/class_repository.dart';

// ==================== DOCENTE ====================

class CreateClassUseCase {
  final ClassRepository repository;
  CreateClassUseCase(this.repository);

  Future<Either<Failure, SchoolClass>> call(CreateClassParams params) {
    return repository.createClass(params);
  }
}

class GetTeacherClassesUseCase {
  final ClassRepository repository;
  GetTeacherClassesUseCase(this.repository);

  Future<Either<Failure, ClassList>> call() {
    return repository.getTeacherClasses();
  }
}

class UpdateClassUseCase {
  final ClassRepository repository;
  UpdateClassUseCase(this.repository);

  Future<Either<Failure, SchoolClass>> call(String classId, UpdateClassParams params) {
    return repository.updateClass(classId, params);
  }
}

class DeleteClassUseCase {
  final ClassRepository repository;
  DeleteClassUseCase(this.repository);

  Future<Either<Failure, void>> call(String classId) {
    return repository.deleteClass(classId);
  }
}

class CreateAssignmentUseCase {
  final ClassRepository repository;
  CreateAssignmentUseCase(this.repository);

  Future<Either<Failure, Assignment>> call(String classId, CreateAssignmentParams params) {
    return repository.createAssignment(classId, params);
  }
}

class GetClassStudentsUseCase {
  final ClassRepository repository;
  GetClassStudentsUseCase(this.repository);

  Future<Either<Failure, List<StudentProgress>>> call(String classId) {
    return repository.getClassStudents(classId);
  }
}

// ==================== ESTUDIANTE ====================

class JoinClassUseCase {
  final ClassRepository repository;
  JoinClassUseCase(this.repository);

  Future<Either<Failure, Enrollment>> call(JoinClassParams params) {
    return repository.joinClass(params);
  }
}

class LeaveClassUseCase {
  final ClassRepository repository;
  LeaveClassUseCase(this.repository);

  Future<Either<Failure, void>> call(String classId) {
    return repository.leaveClass(classId);
  }
}

class GetEnrolledClassesUseCase {
  final ClassRepository repository;
  GetEnrolledClassesUseCase(this.repository);

  Future<Either<Failure, ClassList>> call() {
    return repository.getEnrolledClasses();
  }
}

// ==================== COMÚN ====================

class GetClassByIdUseCase {
  final ClassRepository repository;
  GetClassByIdUseCase(this.repository);

  Future<Either<Failure, SchoolClass>> call(String classId) {
    return repository.getClassById(classId);
  }
}

class GetClassAssignmentsUseCase {
  final ClassRepository repository;
  GetClassAssignmentsUseCase(this.repository);

  Future<Either<Failure, List<Assignment>>> call(String classId) {
    return repository.getClassAssignments(classId);
  }
}
