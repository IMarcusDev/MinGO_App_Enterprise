import 'package:equatable/equatable.dart';

/// Tipos de discapacidad - Alineado con API
enum DisabilityType {
  auditiva('AUDITIVA'),
  delHabla('DEL_HABLA'),
  ambas('AMBAS');

  final String value;
  const DisabilityType(this.value);

  static DisabilityType? fromString(String? value) {
    if (value == null) return null;
    return DisabilityType.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => DisabilityType.auditiva,
    );
  }

  String get displayName {
    switch (this) {
      case DisabilityType.auditiva:
        return 'Auditiva';
      case DisabilityType.delHabla:
        return 'Del habla';
      case DisabilityType.ambas:
        return 'Auditiva y del habla';
    }
  }
}

/// Entidad Child - Alineada con API
class Child extends Equatable {
  final String id;
  final String parentId;
  final String name;
  final DateTime birthDate;
  final int age;
  final String ageCategory;
  final DisabilityType? disabilityType;
  final String? notes;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Child({
    required this.id,
    required this.parentId,
    required this.name,
    required this.birthDate,
    required this.age,
    required this.ageCategory,
    this.disabilityType,
    this.notes,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, parentId, name, birthDate, age];
}

/// Lista de hijos con total
class ChildList extends Equatable {
  final List<Child> children;
  final int total;

  const ChildList({
    required this.children,
    required this.total,
  });

  @override
  List<Object?> get props => [children, total];
}
