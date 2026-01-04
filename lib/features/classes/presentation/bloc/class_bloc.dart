import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/class_entities.dart';
import '../../domain/usecases/class_usecases.dart';

// ============================================
// EVENTS
// ============================================
abstract class ClassEvent extends Equatable {
  const ClassEvent();
  @override
  List<Object?> get props => [];
}

// Docente events
class LoadTeacherClassesEvent extends ClassEvent {
  const LoadTeacherClassesEvent();
}

class CreateClassEvent extends ClassEvent {
  final CreateClassParams params;
  const CreateClassEvent(this.params);
  @override
  List<Object?> get props => [params];
}

class UpdateClassEvent extends ClassEvent {
  final String classId;
  final UpdateClassParams params;
  const UpdateClassEvent(this.classId, this.params);
  @override
  List<Object?> get props => [classId, params];
}

class DeleteClassEvent extends ClassEvent {
  final String classId;
  const DeleteClassEvent(this.classId);
  @override
  List<Object?> get props => [classId];
}

class CreateAssignmentEvent extends ClassEvent {
  final String classId;
  final CreateAssignmentParams params;
  const CreateAssignmentEvent(this.classId, this.params);
  @override
  List<Object?> get props => [classId, params];
}

class LoadClassStudentsEvent extends ClassEvent {
  final String classId;
  const LoadClassStudentsEvent(this.classId);
  @override
  List<Object?> get props => [classId];
}

// Estudiante events
class LoadEnrolledClassesEvent extends ClassEvent {
  const LoadEnrolledClassesEvent();
}

class JoinClassEvent extends ClassEvent {
  final JoinClassParams params;
  const JoinClassEvent(this.params);
  @override
  List<Object?> get props => [params];
}

class LeaveClassEvent extends ClassEvent {
  final String classId;
  const LeaveClassEvent(this.classId);
  @override
  List<Object?> get props => [classId];
}

// Common events
class LoadClassDetailEvent extends ClassEvent {
  final String classId;
  const LoadClassDetailEvent(this.classId);
  @override
  List<Object?> get props => [classId];
}

class LoadClassAssignmentsEvent extends ClassEvent {
  final String classId;
  const LoadClassAssignmentsEvent(this.classId);
  @override
  List<Object?> get props => [classId];
}

// ============================================
// STATES
// ============================================
abstract class ClassState extends Equatable {
  const ClassState();
  @override
  List<Object?> get props => [];
}

class ClassInitialState extends ClassState {
  const ClassInitialState();
}

class ClassLoadingState extends ClassState {
  const ClassLoadingState();
}

class TeacherClassesLoadedState extends ClassState {
  final ClassList classList;
  const TeacherClassesLoadedState(this.classList);
  @override
  List<Object?> get props => [classList];
}

class EnrolledClassesLoadedState extends ClassState {
  final ClassList classList;
  const EnrolledClassesLoadedState(this.classList);
  @override
  List<Object?> get props => [classList];
}

class ClassDetailLoadedState extends ClassState {
  final SchoolClass schoolClass;
  final List<Assignment> assignments;
  final List<StudentProgress>? students;

  const ClassDetailLoadedState({
    required this.schoolClass,
    this.assignments = const [],
    this.students,
  });

  @override
  List<Object?> get props => [schoolClass, assignments, students];
}

class ClassCreatedState extends ClassState {
  final SchoolClass schoolClass;
  const ClassCreatedState(this.schoolClass);
  @override
  List<Object?> get props => [schoolClass];
}

class ClassUpdatedState extends ClassState {
  final SchoolClass schoolClass;
  const ClassUpdatedState(this.schoolClass);
  @override
  List<Object?> get props => [schoolClass];
}

class ClassDeletedState extends ClassState {
  const ClassDeletedState();
}

class JoinedClassState extends ClassState {
  final Enrollment enrollment;
  const JoinedClassState(this.enrollment);
  @override
  List<Object?> get props => [enrollment];
}

class LeftClassState extends ClassState {
  const LeftClassState();
}

class AssignmentCreatedState extends ClassState {
  final Assignment assignment;
  const AssignmentCreatedState(this.assignment);
  @override
  List<Object?> get props => [assignment];
}

class ClassErrorState extends ClassState {
  final String message;
  const ClassErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// ============================================
// BLOC
// ============================================
class ClassBloc extends Bloc<ClassEvent, ClassState> {
  final GetTeacherClassesUseCase getTeacherClassesUseCase;
  final GetEnrolledClassesUseCase getEnrolledClassesUseCase;
  final GetClassByIdUseCase getClassByIdUseCase;
  final GetClassAssignmentsUseCase getClassAssignmentsUseCase;
  final GetClassStudentsUseCase getClassStudentsUseCase;
  final CreateClassUseCase createClassUseCase;
  final UpdateClassUseCase updateClassUseCase;
  final DeleteClassUseCase deleteClassUseCase;
  final JoinClassUseCase joinClassUseCase;
  final LeaveClassUseCase leaveClassUseCase;
  final CreateAssignmentUseCase createAssignmentUseCase;

  ClassBloc({
    required this.getTeacherClassesUseCase,
    required this.getEnrolledClassesUseCase,
    required this.getClassByIdUseCase,
    required this.getClassAssignmentsUseCase,
    required this.getClassStudentsUseCase,
    required this.createClassUseCase,
    required this.updateClassUseCase,
    required this.deleteClassUseCase,
    required this.joinClassUseCase,
    required this.leaveClassUseCase,
    required this.createAssignmentUseCase,
  }) : super(const ClassInitialState()) {
    on<LoadTeacherClassesEvent>(_onLoadTeacherClasses);
    on<LoadEnrolledClassesEvent>(_onLoadEnrolledClasses);
    on<LoadClassDetailEvent>(_onLoadClassDetail);
    on<LoadClassAssignmentsEvent>(_onLoadClassAssignments);
    on<LoadClassStudentsEvent>(_onLoadClassStudents);
    on<CreateClassEvent>(_onCreateClass);
    on<UpdateClassEvent>(_onUpdateClass);
    on<DeleteClassEvent>(_onDeleteClass);
    on<JoinClassEvent>(_onJoinClass);
    on<LeaveClassEvent>(_onLeaveClass);
    on<CreateAssignmentEvent>(_onCreateAssignment);
  }

  Future<void> _onLoadTeacherClasses(
    LoadTeacherClassesEvent event,
    Emitter<ClassState> emit,
  ) async {
    emit(const ClassLoadingState());
    final result = await getTeacherClassesUseCase();
    result.fold(
      (failure) => emit(ClassErrorState(failure.message)),
      (classList) => emit(TeacherClassesLoadedState(classList)),
    );
  }

  Future<void> _onLoadEnrolledClasses(
    LoadEnrolledClassesEvent event,
    Emitter<ClassState> emit,
  ) async {
    emit(const ClassLoadingState());
    final result = await getEnrolledClassesUseCase();
    result.fold(
      (failure) => emit(ClassErrorState(failure.message)),
      (classList) => emit(EnrolledClassesLoadedState(classList)),
    );
  }

  Future<void> _onLoadClassDetail(
    LoadClassDetailEvent event,
    Emitter<ClassState> emit,
  ) async {
    emit(const ClassLoadingState());

    final classResult = await getClassByIdUseCase(event.classId);

    await classResult.fold(
      (failure) async => emit(ClassErrorState(failure.message)),
      (schoolClass) async {
        // También cargar tareas
        final assignmentsResult = await getClassAssignmentsUseCase(event.classId);
        final assignments = assignmentsResult.fold(
          (failure) => <Assignment>[],
          (list) => list,
        );

        emit(ClassDetailLoadedState(
          schoolClass: schoolClass,
          assignments: assignments,
        ));
      },
    );
  }

  Future<void> _onLoadClassAssignments(
    LoadClassAssignmentsEvent event,
    Emitter<ClassState> emit,
  ) async {
    final currentState = state;
    if (currentState is ClassDetailLoadedState) {
      final result = await getClassAssignmentsUseCase(event.classId);
      result.fold(
        (failure) => emit(ClassErrorState(failure.message)),
        (assignments) => emit(ClassDetailLoadedState(
          schoolClass: currentState.schoolClass,
          assignments: assignments,
          students: currentState.students,
        )),
      );
    }
  }

  Future<void> _onLoadClassStudents(
    LoadClassStudentsEvent event,
    Emitter<ClassState> emit,
  ) async {
    final currentState = state;
    if (currentState is ClassDetailLoadedState) {
      final result = await getClassStudentsUseCase(event.classId);
      result.fold(
        (failure) => emit(ClassErrorState(failure.message)),
        (students) => emit(ClassDetailLoadedState(
          schoolClass: currentState.schoolClass,
          assignments: currentState.assignments,
          students: students,
        )),
      );
    }
  }

  Future<void> _onCreateClass(
    CreateClassEvent event,
    Emitter<ClassState> emit,
  ) async {
    emit(const ClassLoadingState());
    final result = await createClassUseCase(event.params);
    result.fold(
      (failure) => emit(ClassErrorState(failure.message)),
      (schoolClass) => emit(ClassCreatedState(schoolClass)),
    );
  }

  Future<void> _onUpdateClass(
    UpdateClassEvent event,
    Emitter<ClassState> emit,
  ) async {
    emit(const ClassLoadingState());
    final result = await updateClassUseCase(event.classId, event.params);
    result.fold(
      (failure) => emit(ClassErrorState(failure.message)),
      (schoolClass) => emit(ClassUpdatedState(schoolClass)),
    );
  }

  Future<void> _onDeleteClass(
    DeleteClassEvent event,
    Emitter<ClassState> emit,
  ) async {
    emit(const ClassLoadingState());
    final result = await deleteClassUseCase(event.classId);
    result.fold(
      (failure) => emit(ClassErrorState(failure.message)),
      (_) => emit(const ClassDeletedState()),
    );
  }

  Future<void> _onJoinClass(
    JoinClassEvent event,
    Emitter<ClassState> emit,
  ) async {
    emit(const ClassLoadingState());
    final result = await joinClassUseCase(event.params);
    result.fold(
      (failure) => emit(ClassErrorState(failure.message)),
      (enrollment) => emit(JoinedClassState(enrollment)),
    );
  }

  Future<void> _onLeaveClass(
    LeaveClassEvent event,
    Emitter<ClassState> emit,
  ) async {
    emit(const ClassLoadingState());
    final result = await leaveClassUseCase(event.classId);
    result.fold(
      (failure) => emit(ClassErrorState(failure.message)),
      (_) => emit(const LeftClassState()),
    );
  }

  Future<void> _onCreateAssignment(
    CreateAssignmentEvent event,
    Emitter<ClassState> emit,
  ) async {
    emit(const ClassLoadingState());
    final result = await createAssignmentUseCase(event.classId, event.params);
    result.fold(
      (failure) => emit(ClassErrorState(failure.message)),
      (assignment) => emit(AssignmentCreatedState(assignment)),
    );
  }
}
