import 'package:equatable/equatable.dart';

/// Estado de sincronización del correo (PRD §8 — tabla email_sync_state).
///
/// El usuario siempre debe saber si su correo está conectado y al día (F3.4).
class SyncStatus extends Equatable {
  const SyncStatus({
    required this.status,
    this.lastSyncAt,
    this.lastError,
  });

  final SyncState status;
  final DateTime? lastSyncAt;
  final String? lastError;

  bool get isActive => status == SyncState.active;
  bool get hasError => status == SyncState.error;

  @override
  List<Object?> get props => [status, lastSyncAt, lastError];
}

enum SyncState { active, error, revoked }
