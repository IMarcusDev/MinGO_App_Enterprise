import '../../domain/entities/child_entity.dart';

/// Modelo de Child para serialización JSON
class ChildModel extends Child {
  const ChildModel({
    required super.id,
    required super.parentId,
    required super.name,
    required super.birthDate,
    required super.age,
    required super.ageCategory,
    super.disabilityType,
    super.notes,
    super.avatarUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'] as String,
      parentId: json['parentId'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      age: json['age'] as int,
      ageCategory: json['ageCategory'] as String,
      disabilityType: DisabilityType.fromString(json['disabilityType'] as String?),
      notes: json['notes'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'parentId': parentId,
        'name': name,
        'birthDate': birthDate.toIso8601String().split('T').first,
        'age': age,
        'ageCategory': ageCategory,
        if (disabilityType != null) 'disabilityType': disabilityType!.value,
        if (notes != null) 'notes': notes,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

/// Modelo de lista de hijos
class ChildListModel extends ChildList {
  const ChildListModel({
    required List<ChildModel> children,
    required super.total,
  }) : super(children: children);

  factory ChildListModel.fromJson(Map<String, dynamic> json) {
    final childrenJson = json['children'] as List<dynamic>;
    final children = childrenJson
        .map((e) => ChildModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ChildListModel(
      children: children,
      total: json['total'] as int,
    );
  }
}
