import 'package:fylax_front/features/categories/domain/entities/category.dart';

/// DTO de categoría.
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.isSystemDefault,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String? ?? 'category',
        color: json['color'] as String? ?? '#888888',
        type: json['type'] == 'income'
            ? CategoryType.income
            : CategoryType.expense,
        isSystemDefault: json['is_system_default'] as bool? ?? false,
      );

  final String id;
  final String name;
  final String icon;
  final String color;
  final CategoryType type;
  final bool isSystemDefault;

  Category toEntity() => Category(
        id: id,
        name: name,
        icon: icon,
        color: color,
        type: type,
        isSystemDefault: isSystemDefault,
      );
}
