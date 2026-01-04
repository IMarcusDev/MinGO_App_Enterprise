import 'package:equatable/equatable.dart';

/// Clase/grupo de estudiantes
class SchoolClass extends Equatable {
  final String id;
  final String teacherId;
  final String? teacherName;
  final String name;
  final String code;
  final String? description;
  final bool isActive;
  final int studentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SchoolClass({
    required this.id,
    required this.teacherId,
    this.teacherName,
    required this.name,
    required this.code,
    this.description,
    required this.isActive,
    required this.studentsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, code, studentsCount];
}

/// Lista de clases
class ClassList extends Equatable {
  final List<SchoolClass> classes;
  final int total;

  const ClassList({
    required this.classes,
    required this.total,
  });

  @override
  List<Object?> get props => [classes, total];
}

/// Inscripción de estudiante
class Enrollment extends Equatable {
  final String id;
  final String classId;
  final String studentId;
  final String? studentName;
  final DateTime enrolledAt;

  const Enrollment({
    required this.id,
    required this.classId,
    required this.studentId,
    this.studentName,
    required this.enrolledAt,
  });

  @override
  List<Object?> get props => [id, classId, studentId];
}

/// Tarea asignada
class Assignment extends Equatable {
  final String id;
  final String classId;
  final String lessonId;
  final String? lessonTitle;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool isOverdue;
  final DateTime createdAt;

  const Assignment({
    required this.id,
    required this.classId,
    required this.lessonId,
    this.lessonTitle,
    required this.title,
    this.description,
    this.dueDate,
    required this.isOverdue,
    required this.createdAt,
  });

  /// Días restantes para entregar
  int? get daysRemaining {
    if (dueDate == null) return null;
    final now = DateTime.now();
    return dueDate!.difference(now).inDays;
  }

  @override
  List<Object?> get props => [id, classId, lessonId, title];
}

/// Progreso de estudiante en una clase
class StudentProgress extends Equatable {
  final String studentId;
  final String studentName;
  final int lessonsCompleted;
  final int assignmentsCompleted;
  final int totalAssignments;
  final double averageAccuracy;
  final int totalTimeSpent;
  final DateTime? lastActivity;

  const StudentProgress({
    required this.studentId,
    required this.studentName,
    required this.lessonsCompleted,
    required this.assignmentsCompleted,
    required this.totalAssignments,
    required this.averageAccuracy,
    required this.totalTimeSpent,
    this.lastActivity,
  });

  double get completionRate {
    if (totalAssignments == 0) return 0;
    return (assignmentsCompleted / totalAssignments) * 100;
  }

  @override
  List<Object?> get props => [studentId, lessonsCompleted, assignmentsCompleted];
}

/// Parámetros para crear clase
class CreateClassParams {
  final String name;
  final String? description;

  const CreateClassParams({
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
      };
}

/// Parámetros para actualizar clase
class UpdateClassParams {
  final String? name;
  final String? description;

  const UpdateClassParams({
    this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    return map;
  }
}

/// Parámetros para unirse a clase
class JoinClassParams {
  final String code;

  const JoinClassParams({required this.code});

  Map<String, dynamic> toJson() => {'code': code};
}

/// Parámetros para crear tarea
class CreateAssignmentParams {
  final String lessonId;
  final String title;
  final String? description;
  final DateTime? dueDate;

  const CreateAssignmentParams({
    required this.lessonId,
    required this.title,
    this.description,
    this.dueDate,
  });

  Map<String, dynamic> toJson() => {
        'lessonId': lessonId,
        'title': title,
        if (description != null) 'description': description,
        if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
      };
}
