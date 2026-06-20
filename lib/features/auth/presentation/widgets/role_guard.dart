import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_user.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Wraps a widget and only shows it if the current user has one of
/// the required roles. Otherwise shows [fallback] (default: empty).
///
/// Usage:
/// ```dart
/// RoleGuard(
///   allowedRoles: [UserRole.admin],
///   child: AdminOnlyButton(),
/// )
/// ```
class RoleGuard extends ConsumerWidget {
  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  final List<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authViewModelProvider);
    final role  = state.user?.role;
    if (role != null && allowedRoles.contains(role)) return child;
    return fallback ?? const SizedBox.shrink();
  }
}