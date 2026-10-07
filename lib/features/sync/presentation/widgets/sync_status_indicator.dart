import 'package:fylax_front/app/theme/app_theme.dart';
import 'package:fylax_front/core/utils/formatters.dart';
import 'package:fylax_front/features/sync/domain/entities/sync_status.dart';
import 'package:fylax_front/features/sync/presentation/providers/sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Indicador de sincronización (F3.4): el usuario siempre sabe si su
/// correo está conectado y al día.
///
/// - Sincronizando correos… (ícono girando)
/// - Última actualización hace X min (punto verde con pulso)
/// - Error con acción de reintento
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(syncStatusProvider);

    return statusAsync.when(
      loading: () => const _Chip(
        label: 'Sincronizando…',
        spinning: true,
      ),
      error: (_, __) => _Chip(
        label: 'Error de sync',
        isError: true,
        onRetry: () => ref.invalidate(syncStatusProvider),
      ),
      data: (status) => switch (status.status) {
        SyncState.active => _Chip(
            label: status.lastSyncAt == null
                ? 'Sincronizando…'
                : Formatters.timeAgo(status.lastSyncAt!),
            pulsing: status.lastSyncAt != null,
            spinning: status.lastSyncAt == null,
          ),
        SyncState.error => _Chip(
            label: 'Error de sync',
            isError: true,
            onRetry: () => ref.invalidate(syncStatusProvider),
          ),
        SyncState.revoked => const _Chip(
            label: 'Correo desconectado',
            isError: true,
          ),
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    this.isError = false,
    this.spinning = false,
    this.pulsing = false,
    this.onRetry,
  });

  final String label;
  final bool isError;
  final bool spinning;
  final bool pulsing;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isError ? AppColors.error : AppColors.green;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onRetry,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (spinning)
              _SpinningIcon(color: color)
            else if (pulsing)
              _PulsingDot(color: color)
            else
              Icon(
                isError ? Icons.error_outline_rounded : Icons.check_rounded,
                size: 14,
                color: color,
              ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ícono de sync girando mientras se procesan correos.
class _SpinningIcon extends StatefulWidget {
  const _SpinningIcon({required this.color});

  final Color color;

  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(Icons.sync_rounded, size: 14, color: widget.color),
    );
  }
}

/// Punto verde con pulso suave: "todo al día".
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
          boxShadow: [
            BoxShadow(
              color: widget.color
                  .withValues(alpha: 0.5 * (1 - _controller.value)),
              blurRadius: 6 + 4 * _controller.value,
              spreadRadius: _controller.value * 2,
            ),
          ],
        ),
      ),
    );
  }
}
