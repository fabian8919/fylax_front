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
  });

  final String id; // UUID enlazado a Supabase Auth
  final String email;
  final String name;
  final String? avatarUrl;

  /// Tier SaaS: free | pro (PRD §F4.1). El paywall llega después del MVP.
  final String subscriptionTier;

  bool get isPro => subscriptionTier == 'pro';

  @override
  List<Object?> get props => [id, email, name, avatarUrl, subscriptionTier];
}
