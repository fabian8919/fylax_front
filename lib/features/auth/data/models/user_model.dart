import 'package:fylax_front/core/utils/parse_amount.dart';
import 'package:fylax_front/features/auth/domain/entities/user.dart';

/// DTO de usuario (respuesta de POST /auth/session y del JWT de Supabase).
///
/// Los modelos JSON de la API nunca llegan a la UI; se mapean a entidades
/// de dominio (PRD §5.1 — DTOs y mappers).
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.subscriptionTier,
    this.avatarUrl,
    this.incomeAmount = 0,
    this.incomeFrequency = 'monthly',
    this.monthlyIncome = 0,
    this.monthlyBudget = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String? ?? '',
        subscriptionTier: json['subscription_tier'] as String? ?? 'free',
        avatarUrl: json['avatar_url'] as String?,
        incomeAmount: parseApiAmount(json['income_amount']),
        incomeFrequency: json['income_frequency'] as String? ?? 'monthly',
        monthlyIncome: parseApiAmount(json['monthly_income']),
        monthlyBudget: parseApiAmount(json['monthly_budget']),
      );

  final String id;
  final String email;
  final String name;
  final String subscriptionTier;
  final String? avatarUrl;
  final double incomeAmount;
  final String incomeFrequency;
  final double monthlyIncome;
  final double monthlyBudget;

  User toEntity() => User(
        id: id,
        email: email,
        name: name,
        subscriptionTier: subscriptionTier,
        avatarUrl: avatarUrl,
        incomeAmount: incomeAmount,
        incomeFrequency: incomeFrequency,
        monthlyIncome: monthlyIncome,
        monthlyBudget: monthlyBudget,
      );
}
