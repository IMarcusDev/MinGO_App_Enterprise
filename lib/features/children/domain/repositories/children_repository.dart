import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/child_entity.dart';

/// Parámetros para crear un hijo
class CreateChildParams {
  final String name;
  final String birthDate; // ISO format: YYYY-MM-DD
  final DisabilityType? disabilityType;
  final String? notes;
  final String? avatarUrl;

  const CreateChildParams({
    required this.name,
    required this.birthDate,
    this.disabilityType,
    this.notes,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'birthDate': birthDate,
        if (disabilityType != null) 'disabilityType': disabilityType!.value,
        if (notes != null) 'notes': notes,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };
}

/// Parámetros para actualizar un hijo
class UpdateChildParams {
  final String? name;
  final String? birthDate;
  final DisabilityType? disabilityType;
  final String? notes;
  final String? avatarUrl;

  const UpdateChildParams({
    this.name,
    this.birthDate,
    this.disabilityType,
    this.notes,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (birthDate != null) json['birthDate'] = birthDate;
    if (disabilityType != null) json['disabilityType'] = disabilityType!.value;
    if (notes != null) json['notes'] = notes;
    if (avatarUrl != null) json['avatarUrl'] = avatarUrl;
    return json;
  }
}

/// Repositorio de hijos
abstract class ChildrenRepository {
  /// Crear un hijo
  Future<Either<Failure, Child>> createChild(CreateChildParams params);

  /// Obtener lista de hijos
  Future<Either<Failure, ChildList>> getChildren();

  /// Obtener un hijo por ID
  Future<Either<Failure, Child>> getChildById(String id);

  /// Actualizar un hijo
  Future<Either<Failure, Child>> updateChild(String id, UpdateChildParams params);

  /// Eliminar un hijo
  Future<Either<Failure, void>> deleteChild(String id);
}
