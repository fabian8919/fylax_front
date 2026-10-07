import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fylax_front/core/utils/formatters.dart';
import 'package:fylax_front/features/sync/domain/entities/sync_status.dart';
import 'package:fylax_front/features/sync/presentation/providers/sync_provider.dart';

/// Indicador de sincronización (F3.4): el usuario siempre sabe si su
/// correo está conectado y al día.
///
/// - Sincronizando correos… (sin lastSyncAt o sync reciente)
/// - Última actualización hace X min
/// - Error con acción de reintento
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(syncStatusProvider);

    return statusAsync.when(
      loading: () => const _Chip(
        icon: Icons.sync,
        label: 'Sincronizando…',
      ),
      error: (_, __) => _Chip(
        icon: Icons.error_outline,
        label: 'Error de sincronización',
        isError: true,
        onRetry: () => ref.invalidate(syncStatusProvider),
      ),
      data: (status) => switch (status.status) {
        SyncState.active => _Chip(
            icon: Icons.check_circle_outline,
            label: status.lastSyncAt == null
                ? 'Sincronizando…'
                : 'Actualizado ${Formatters.timeAgo(status.lastSyncAt!)}',
          ),
        SyncState.error => _Chip(
            icon: Icons.error_outline,
            label: 'Error de sincronización',
            isError: true,
            onRetry: () => ref.invalidate(syncStatusProvider),
          ),
        SyncState.revoked => const _Chip(
            icon: Icons.link_off,
            label: 'Correo desconectado',
            isError: true,
          ),
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    this.isError = false,
    this.onRetry,
  });

  final IconData icon;
  final String label;
  final bool isError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isError ? theme.colorScheme.error : theme.colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onRetry,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
