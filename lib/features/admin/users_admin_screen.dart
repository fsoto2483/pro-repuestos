import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/app_user.dart';
import '../../data/models/user_role.dart';
import '../../data/models/user_status.dart';
import '../../services/user_service.dart';
import '../../state/auth_controller.dart';
import '../auth/auth_guard.dart';

/// Gestion de usuarios, roles y estado (solo administradores).
class UsersAdminScreen extends StatefulWidget {
  const UsersAdminScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => const AuthGuard(
          requiredRole: UserRole.admin,
          child: UsersAdminScreen(),
        ),
      ),
    );
  }

  @override
  State<UsersAdminScreen> createState() => _UsersAdminScreenState();
}

class _UsersAdminScreenState extends State<UsersAdminScreen> {
  final UserService _userService = const UserService();
  late Future<List<AppUser>> _future;

  @override
  void initState() {
    super.initState();
    _future = _userService.listUsers();
  }

  void _reload() {
    setState(() {
      _future = _userService.listUsers();
    });
  }

  Future<void> _changeRole(AppUser target, UserRole next) async {
    if (target.role == next) return;

    final String? selfId = context.read<AuthController>().user?.id;
    if (selfId != null && selfId == target.id && next != UserRole.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes quitarte el rol de administrador.'),
        ),
      );
      return;
    }

    try {
      await _userService.setUserRole(target.id, next);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${target.email} ahora es ${next.label}'),
        ),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cambiar el rol: $e')),
      );
    }
  }

  Future<void> _changeStatus(AppUser target, UserStatus next) async {
    if (target.status == next) return;

    final String? selfId = context.read<AuthController>().user?.id;
    if (selfId != null &&
        selfId == target.id &&
        next == UserStatus.suspended) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes suspender tu propia cuenta.'),
        ),
      );
      return;
    }

    try {
      await _userService.updateUserStatus(target.id, next);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${target.email} ahora esta ${next.label.toLowerCase()}'),
        ),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cambiar el estado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double gutter = context.horizontalPadding;
    final String? selfId = context.watch<AuthController>().user?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<AppUser>>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<List<AppUser>> snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar los usuarios.\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final List<AppUser> users = snap.data ?? const <AppUser>[];
          if (users.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 28),
            itemCount: users.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              final AppUser user = users[index];
              final bool isSelf = user.id == selfId;

              return Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor:
                                  AppColors.brand.withValues(alpha: 0.12),
                              foregroundColor: AppColors.brand,
                              child: Text(user.initials),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    user.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  Text(
                                    '${user.email}${isSelf ? ' · tu cuenta' : ''}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            _LabeledDropdown<UserRole>(
                              label: 'Rol',
                              value: user.role,
                              items: UserRole.values,
                              itemLabel: (UserRole r) => r.label,
                              onChanged: (UserRole? next) {
                                if (next == null) return;
                                _changeRole(user, next);
                              },
                            ),
                            _LabeledDropdown<UserStatus>(
                              label: 'Estado',
                              value: user.status,
                              items: UserStatus.values,
                              itemLabel: (UserStatus s) => s.label,
                              onChanged: (UserStatus? next) {
                                if (next == null) return;
                                _changeStatus(user, next);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('$label:', style: theme.textTheme.bodySmall),
        const SizedBox(width: 6),
        DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isDense: true,
            items: items
                .map(
                  (T item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(itemLabel(item)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
