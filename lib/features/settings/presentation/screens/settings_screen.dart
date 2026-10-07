import 'package:fylax_front/app/theme/app_theme.dart';
import 'package:fylax_front/core/widgets/fade_in_slide.dart';
import 'package:fylax_front/features/sync/presentation/providers/sync_provider.dart';
import 'package:fylax_front/features/sync/presentation/widgets/sync_status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuración de la app.
///
/// Nota de producto (PRD §7): Fylax NO notifica cada gasto — el registro
/// es silencioso por diseño. Los toggles de notificación se reservan para
/// recomendaciones y avance de propósitos (fase posterior), y aquí se
/// presentan como configuración anticipada, accionable y clara.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // TODO(Fase 6): persistir en shared_preferences y leer al arrancar.
  bool _notifyRecommendations = true;
  bool _notifyGoalProgress = true;
  bool _biometricLock = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: staggered(
          [
            _Section(
              title: 'Sincronización',
              children: [
                _Tile(
                  icon: Icons.sync_rounded,
                  title: 'Estado del correo',
                  trailing: const SyncStatusIndicator(),
                  onTap: () => ref.invalidate(syncStatusProvider),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _Section(
              title: 'Notificaciones',
              subtitle: 'Nunca te avisamos por cada gasto: solo eventos de '
                  'valor que tú controles.',
              children: [
                _SwitchTile(
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'Recomendaciones inteligentes',
                  subtitle: 'Próximamente — fase posterior al MVP',
                  value: _notifyRecommendations,
                  onChanged: (v) =>
                      setState(() => _notifyRecommendations = v),
                ),
                _SwitchTile(
                  icon: Icons.savings_rounded,
                  title: 'Avance de propósitos',
                  subtitle: 'Cumplimiento y progreso de tus metas',
                  value: _notifyGoalProgress,
                  onChanged: (v) => setState(() => _notifyGoalProgress = v),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _Section(
              title: 'General',
              children: [
                _SwitchTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Bloqueo biométrico',
                  subtitle: 'Pedir huella al abrir la app',
                  value: _biometricLock,
                  onChanged: (v) => setState(() => _biometricLock = v),
                ),
                const _Tile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Apariencia',
                  trailing: Text(
                    'Oscuro',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                const _Tile(
                  icon: Icons.payments_rounded,
                  title: 'Moneda',
                  trailing: Text(
                    'COP \$',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _Section(
              title: 'Privacidad y datos',
              children: [
                _Tile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Política de privacidad',
                  onTap: () {},
                ),
                _Tile(
                  icon: Icons.mail_outline_rounded,
                  title: 'Permisos de correo',
                  subtitle: 'Solo lectura · puedes revocarlo desde Google',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Fylax v0.1.0 · MVP',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ),
          ],
          step: const Duration(milliseconds: 70),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ],
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  const Divider(indent: 60, height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.blue, size: 21),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.green, size: 21),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.green,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
