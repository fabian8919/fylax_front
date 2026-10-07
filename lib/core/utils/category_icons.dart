import 'package:fylax_front/features/categories/domain/entities/category.dart';
import 'package:flutter/material.dart';

/// Mapea el identificador de ícono de una categoría (columna `icon` en BD)
/// a un [IconData] de Material. Ícono desconocido → categoría genérica.
IconData categoryIcon(String icon) => switch (icon) {
      'restaurant' => Icons.restaurant_rounded,
      'delivery' => Icons.two_wheeler_rounded,
      'transport' => Icons.directions_car_filled_rounded,
      'groceries' => Icons.shopping_basket_rounded,
      'services' => Icons.lightbulb_outline_rounded,
      'entertainment' => Icons.movie_rounded,
      'health' => Icons.favorite_rounded,
      'subscriptions' => Icons.autorenew_rounded,
      'shopping' => Icons.shopping_bag_rounded,
      'travel' => Icons.flight_rounded,
      'education' => Icons.school_rounded,
      'income' => Icons.account_balance_wallet_rounded,
      _ => Icons.category_rounded,
    };

/// Color de categoría desde hex ('#1B7A43') con fallback a la marca.
Color categoryColor(String hex, {Color fallback = const Color(0xFF2E8FFF)}) {
  final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
  return value == null ? fallback : Color(0xFF000000 + value);
}

/// Ícono circular de categoría: fondo tintado con el color de la categoría.
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    required this.category,
    this.size = 46,
    super.key,
  });

  final Category category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(category.color);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(categoryIcon(category.icon), color: color, size: size * 0.5),
    );
  }
}
