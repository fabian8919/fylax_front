import 'package:equatable/equatable.dart';

/// Entidad de dominio del resumen mensual (PRD §9 — GET /dashboard/summary).
class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.monthBalance,
    required this.availableBudget,
    required this.spendingByCategory,
  });

  /// Balance del mes (ingresos − gastos).
  final double monthBalance;

  /// Dinero disponible: presupuesto restante.
  final double availableBudget;

  /// Distribución del gasto por categoría.
  final List<CategorySpending> spendingByCategory;

  @override
  List<Object?> get props => [monthBalance, availableBudget, spendingByCategory];
}

class CategorySpending extends Equatable {
  const CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String categoryId;
  final String categoryName;
  final double amount;
  final String icon;
  final String color;

  @override
  List<Object?> get props => [categoryId, categoryName, amount, icon, color];
}
