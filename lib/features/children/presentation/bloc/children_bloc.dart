import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/child_entity.dart';
import '../../domain/repositories/children_repository.dart';
import '../../domain/usecases/children_usecases.dart';

// ============================================
// EVENTS
// ============================================
abstract class ChildrenEvent extends Equatable {
  const ChildrenEvent();
  @override
  List<Object?> get props => [];
}

class LoadChildrenEvent extends ChildrenEvent {
  const LoadChildrenEvent();
}

class CreateChildEvent extends ChildrenEvent {
  final CreateChildParams params;
  const CreateChildEvent(this.params);
  @override
  List<Object?> get props => [params];
}

class UpdateChildEvent extends ChildrenEvent {
  final String id;
  final UpdateChildParams params;
  const UpdateChildEvent(this.id, this.params);
  @override
  List<Object?> get props => [id, params];
}

class DeleteChildEvent extends ChildrenEvent {
  final String id;
  const DeleteChildEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// ============================================
// STATES
// ============================================
abstract class ChildrenState extends Equatable {
  const ChildrenState();
  @override
  List<Object?> get props => [];
}

class ChildrenInitialState extends ChildrenState {
  const ChildrenInitialState();
}

class ChildrenLoadingState extends ChildrenState {
  final String? message;
  const ChildrenLoadingState({this.message});
  @override
  List<Object?> get props => [message];
}

class ChildrenLoadedState extends ChildrenState {
  final List<Child> children;
  final int total;

  const ChildrenLoadedState({
    required this.children,
    required this.total,
  });

  @override
  List<Object?> get props => [children, total];
}

class ChildCreatedState extends ChildrenState {
  final Child child;
  const ChildCreatedState(this.child);
  @override
  List<Object?> get props => [child];
}

class ChildUpdatedState extends ChildrenState {
  final Child child;
  const ChildUpdatedState(this.child);
  @override
  List<Object?> get props => [child];
}

class ChildDeletedState extends ChildrenState {
  const ChildDeletedState();
}

class ChildrenErrorState extends ChildrenState {
  final String message;
  const ChildrenErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// ============================================
// BLOC
// ============================================
class ChildrenBloc extends Bloc<ChildrenEvent, ChildrenState> {
  final GetChildrenUseCase getChildrenUseCase;
  final CreateChildUseCase createChildUseCase;
  final UpdateChildUseCase updateChildUseCase;
  final DeleteChildUseCase deleteChildUseCase;

  ChildrenBloc({
    required this.getChildrenUseCase,
    required this.createChildUseCase,
    required this.updateChildUseCase,
    required this.deleteChildUseCase,
  }) : super(const ChildrenInitialState()) {
    on<LoadChildrenEvent>(_onLoadChildren);
    on<CreateChildEvent>(_onCreateChild);
    on<UpdateChildEvent>(_onUpdateChild);
    on<DeleteChildEvent>(_onDeleteChild);
  }

  Future<void> _onLoadChildren(
    LoadChildrenEvent event,
    Emitter<ChildrenState> emit,
  ) async {
    emit(const ChildrenLoadingState(message: 'Cargando...'));

    final result = await getChildrenUseCase();

    result.fold(
      (failure) => emit(ChildrenErrorState(failure.message)),
      (childList) => emit(ChildrenLoadedState(
        children: childList.children,
        total: childList.total,
      )),
    );
  }

  Future<void> _onCreateChild(
    CreateChildEvent event,
    Emitter<ChildrenState> emit,
  ) async {
    emit(const ChildrenLoadingState(message: 'Creando...'));

    final result = await createChildUseCase(event.params);

    result.fold(
      (failure) => emit(ChildrenErrorState(failure.message)),
      (child) => emit(ChildCreatedState(child)),
    );
  }

  Future<void> _onUpdateChild(
    UpdateChildEvent event,
    Emitter<ChildrenState> emit,
  ) async {
    emit(const ChildrenLoadingState(message: 'Actualizando...'));

    final result = await updateChildUseCase(event.id, event.params);

    result.fold(
      (failure) => emit(ChildrenErrorState(failure.message)),
      (child) => emit(ChildUpdatedState(child)),
    );
  }

  Future<void> _onDeleteChild(
    DeleteChildEvent event,
    Emitter<ChildrenState> emit,
  ) async {
    emit(const ChildrenLoadingState(message: 'Eliminando...'));

    final result = await deleteChildUseCase(event.id);

    result.fold(
      (failure) => emit(ChildrenErrorState(failure.message)),
      (_) => emit(const ChildDeletedState()),
    );
  }
}
