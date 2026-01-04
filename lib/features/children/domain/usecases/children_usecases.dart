import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/child_entity.dart';
import '../repositories/children_repository.dart';

/// Crear un hijo
class CreateChildUseCase {
  final ChildrenRepository repository;

  CreateChildUseCase(this.repository);

  Future<Either<Failure, Child>> call(CreateChildParams params) {
    return repository.createChild(params);
  }
}

/// Obtener lista de hijos
class GetChildrenUseCase {
  final ChildrenRepository repository;

  GetChildrenUseCase(this.repository);

  Future<Either<Failure, ChildList>> call() {
    return repository.getChildren();
  }
}

/// Obtener un hijo por ID
class GetChildByIdUseCase {
  final ChildrenRepository repository;

  GetChildByIdUseCase(this.repository);

  Future<Either<Failure, Child>> call(String id) {
    return repository.getChildById(id);
  }
}

/// Actualizar un hijo
class UpdateChildUseCase {
  final ChildrenRepository repository;

  UpdateChildUseCase(this.repository);

  Future<Either<Failure, Child>> call(String id, UpdateChildParams params) {
    return repository.updateChild(id, params);
  }
}

/// Eliminar un hijo
class DeleteChildUseCase {
  final ChildrenRepository repository;

  DeleteChildUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteChild(id);
  }
}
