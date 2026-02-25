import 'package:flutter/material.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';

class NavigationHelper {
  const NavigationHelper._();

  static String landingRouteForPermissions(List<String> permissions) {
    final perms = permissions.map((p) => p.toLowerCase()).toSet();
    if (perms.contains('dashboard.read')) {
      return AppRoutes.adminHome;
    }
    if (perms.contains('appointments.read')) {
      return AppRoutes.techHub;
    }
    return AppRoutes.adminHome;
  }

  static void goToLanding(
    BuildContext context, {
    required List<String> permissions,
  }) {
    final route = landingRouteForPermissions(permissions);
    Navigator.of(context).pushNamedAndRemoveUntil(
      route,
      (Route<dynamic> r) => false,
      arguments: permissions,
    );
  }

  static void goToPrimarySection(
    BuildContext context, {
    required String route,
    required List<String> permissions,
  }) {
    final current = ModalRoute.of(context)?.settings.name;
    if (current == route) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      route,
      (Route<dynamic> r) {
        final name = r.settings.name;
        return name == AppRoutes.home || name == AppRoutes.techHub;
      },
      arguments: {'permissions': permissions},
    );
  }
}
