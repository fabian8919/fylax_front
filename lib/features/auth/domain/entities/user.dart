import 'package:equatable/equatable.dart';

/// Entidad de dominio del usuario (PRD §8 — tabla users).
///
/// Nota: el google_refresh_token NUNCA llega al cliente; lo almacena
/// encriptado el backend (AES-256-GCM, llave en Secret Manager — PRD §F1.3).
class User extends Equatable {
  const User({
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

  final String id; // UUID enlazado a Supabase Auth
  final String email;
  final String name;
  final String? avatarUrl;

  /// Tier SaaS: free | pro (PRD §F4.1). El paywall llega después del MVP.
  final String subscriptionTier;

  /// Ingreso por nómina y frecuencia: monthly | biweekly.
  final double incomeAmount;
  final String incomeFrequency;

  /// Equivalente mensual y presupuesto de gastos usados por los planes.
  final double monthlyIncome;
  final double monthlyBudget;

  bool get isPro => subscriptionTier == 'pro';
  bool get hasFinancialSetup => monthlyIncome > 0;
  double get monthlySavingsCapacity =>
      (monthlyIncome - monthlyBudget).clamp(0, monthlyIncome);

  User copyWith({
    String? name,
    double? incomeAmount,
    String? incomeFrequency,
    double? monthlyIncome,
    double? monthlyBudget,
  }) =>
      User(
        id: id,
        email: email,
        name: name ?? this.name,
        subscriptionTier: subscriptionTier,
        avatarUrl: avatarUrl,
        incomeAmount: incomeAmount ?? this.incomeAmount,
        incomeFrequency: incomeFrequency ?? this.incomeFrequency,
        monthlyIncome: monthlyIncome ?? this.monthlyIncome,
        monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      );

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        avatarUrl,
        subscriptionTier,
        incomeAmount,
        incomeFrequency,
        monthlyIncome,
        monthlyBudget,
      ];
}
