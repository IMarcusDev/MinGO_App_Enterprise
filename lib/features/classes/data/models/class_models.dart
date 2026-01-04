import '../../domain/entities/class_entities.dart';

class SchoolClassModel extends SchoolClass {
  const SchoolClassModel({
    required super.id,
    required super.teacherId,
    super.teacherName,
    required super.name,
    required super.code,
    super.description,
    required super.isActive,
    required super.studentsCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SchoolClassModel.fromJson(Map<String, dynamic> json) {
    return SchoolClassModel(
      id: json['id'] as String,
      teacherId: json['teacherId'] as String,
      teacherName: json['teacherName'] as String?,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      studentsCount: json['studentsCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class ClassListModel extends ClassList {
  const ClassListModel({
    required List<SchoolClassModel> classes,
    required super.total,
  }) : super(classes: classes);

  factory ClassListModel.fromJson(Map<String, dynamic> json) {
    final classesJson = json['classes'] as List<dynamic>? ?? [];
    final classes = classesJson
        .map((c) => SchoolClassModel.fromJson(c as Map<String, dynamic>))
        .toList();

    return ClassListModel(
      classes: classes,
      total: json['total'] as int? ?? classes.length,
    );
  }
}

class EnrollmentModel extends Enrollment {
  const EnrollmentModel({
    required super.id,
    required super.classId,
    required super.studentId,
    super.studentName,
    required super.enrolledAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] as String,
      classId: json['classId'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String?,
      enrolledAt: DateTime.parse(json['enrolledAt'] as String),
    );
  }
}

class AssignmentModel extends Assignment {
  const AssignmentModel({
    required super.id,
    required super.classId,
    required super.lessonId,
    super.lessonTitle,
    required super.title,
    super.description,
    super.dueDate,
    required super.isOverdue,
    required super.createdAt,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] as String,
      classId: json['classId'] as String,
      lessonId: json['lessonId'] as String,
      lessonTitle: json['lessonTitle'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate'] as String) 
          : null,
      isOverdue: json['isOverdue'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class StudentProgressModel extends StudentProgress {
  const StudentProgressModel({
    required super.studentId,
    required super.studentName,
    required super.lessonsCompleted,
    required super.assignmentsCompleted,
    required super.totalAssignments,
    required super.averageAccuracy,
    required super.totalTimeSpent,
    super.lastActivity,
  });

  factory StudentProgressModel.fromJson(Map<String, dynamic> json) {
    return StudentProgressModel(
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String? ?? 'Estudiante',
      lessonsCompleted: json['lessonsCompleted'] as int? ?? 0,
      assignmentsCompleted: json['assignmentsCompleted'] as int? ?? 0,
      totalAssignments: json['totalAssignments'] as int? ?? 0,
      averageAccuracy: (json['averageAccuracy'] as num?)?.toDouble() ?? 0.0,
      totalTimeSpent: json['totalTimeSpent'] as int? ?? 0,
      lastActivity: json['lastActivity'] != null
          ? DateTime.parse(json['lastActivity'] as String)
          : null,
    );
  }
}
