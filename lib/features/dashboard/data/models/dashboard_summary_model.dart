import 'package:fylax_front/features/dashboard/domain/entities/dashboard_summary.dart';

/// DTO de GET /dashboard/summary.
class DashboardSummaryModel {
  const DashboardSummaryModel({
    required this.monthBalance,
    required this.availableBudget,
    required this.spendingByCategory,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) =>
      DashboardSummaryModel(
        monthBalance: (json['month_balance'] as num).toDouble(),
        availableBudget: (json['available_budget'] as num).toDouble(),
        spendingByCategory: (json['spending_by_category'] as List<dynamic>? ??
                const [])
            .map(
              (e) => CategorySpendingModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );

  final double monthBalance;
  final double availableBudget;
  final List<CategorySpendingModel> spendingByCategory;

  DashboardSummary toEntity() => DashboardSummary(
        monthBalance: monthBalance,
        availableBudget: availableBudget,
        spendingByCategory: spendingByCategory
            .map((m) => m.toEntity())
            .toList(growable: false),
      );
}

class CategorySpendingModel {
  const CategorySpendingModel({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.icon,
    required this.color,
  });

  factory CategorySpendingModel.fromJson(Map<String, dynamic> json) =>
      CategorySpendingModel(
        categoryId: json['category_id'] as String,
        categoryName: json['category_name'] as String,
        amount: (json['amount'] as num).toDouble(),
        icon: json['icon'] as String? ?? 'category',
        color: json['color'] as String? ?? '#888888',
      );

  final String categoryId;
  final String categoryName;
  final double amount;
  final String icon;
  final String color;

  CategorySpending toEntity() => CategorySpending(
        categoryId: categoryId,
        categoryName: categoryName,
        amount: amount,
        icon: icon,
        color: color,
      );
}
