import 'package:equatable/equatable.dart';

/// Entidad de categoría (PRD §8 — tabla categories).
///
/// El sistema trae categorías por defecto (isSystemDefault) y el usuario
/// podrá crear las suyas en fases posteriores.
class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.isSystemDefault,
  });

  final String id;
  final String name;
  final String icon;
  final String color; // hex, ej. '#1B7A43'

  /// income | expense.
  final CategoryType type;

  final bool isSystemDefault;

  @override
  List<Object?> get props => [id, name, icon, color, type, isSystemDefault];
}

enum CategoryType { income, expense }
