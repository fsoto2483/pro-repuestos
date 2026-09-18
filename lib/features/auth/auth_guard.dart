import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/user_role.dart';
import '../../state/auth_controller.dart';

/// Protege una pantalla segun el rol del usuario autenticado.
///
/// Si no hay sesion o el rol no alcanza, muestra [fallback] (o una pantalla
/// de acceso denegado) en lugar de [child].
class AuthGuard extends StatelessWidget {
  const AuthGuard({
    super.key,
    required this.child,
    this.requiredRole = UserRole.admin,
    this.fallback,
  });

  final Widget child;
  final UserRole requiredRole;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final AuthController auth = context.watch<AuthController>();

    if (!auth.isSignedIn) {
      return fallback ??
          const _AccessDeniedPage(
            title: 'Sesion requerida',
            message: 'Inicia sesion para continuar.',
          );
    }

    if (requiredRole == UserRole.admin && !auth.isAdmin) {
      return fallback ??
          const _AccessDeniedPage(
            title: 'Acceso restringido',
            message:
                'Esta seccion solo esta disponible para administradores.',
          );
    }

    return child;
  }
}

/// Muestra [child] solo si el usuario tiene el [role] indicado.
class RoleGate extends StatelessWidget {
  const RoleGate({
    super.key,
    required this.role,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  final UserRole role;
  final Widget child;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    final AuthController auth = context.watch<AuthController>();
    final bool allowed = switch (role) {
      UserRole.admin => auth.isAdmin,
      UserRole.client => auth.isSignedIn,
    };
    return allowed ? child : fallback;
  }
}

class _AccessDeniedPage extends StatelessWidget {
  const _AccessDeniedPage({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: canPop,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.lock_outline_rounded,
                size: 56,
                color: AppColors.danger.withValues(alpha: 0.85),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (canPop) ...<Widget>[
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Volver'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
