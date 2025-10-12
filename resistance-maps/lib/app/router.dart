import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';
import '../features/map/presentation/pages/map_page.dart';
import '../auth/application/auth_bloc.dart';
import '../auth/presentation/auth_callback_page.dart';
import '../auth/presentation/account_settings_page.dart';

RouteMap get appRoutes => RouteMap(
  onUnknownRoute: (path) => const Redirect('/'),
  routes: {
    '/': (route) => const MaterialPage(child: MapPage()),
    '/callback': (route) => const MaterialPage(child: AuthCallbackPage()),
    '/account': (route) => const MaterialPage(child: AccountSettingsPage()),
    '/admin': (route) => GuardedPage(
      allowed: (context) {
        final state = context.read<AuthBloc>().state;
        final roles = state.session?.roles ?? const [];
        return roles.contains('ADMIN') || roles.contains('SUPERADMIN');
      },
      child: const Placeholder(),
    ),
  },
);

class GuardedPage extends Page {
  const GuardedPage({required this.allowed, required this.child})
    : super(key: const ValueKey('guarded'));
  final bool Function(BuildContext) allowed;
  final Widget child;

  @override
  Route createRoute(BuildContext context) {
    if (!allowed(context)) {
      return Redirect('/').createRoute(context);
    }
    return MaterialPage(child: child).createRoute(context);
  }
}
