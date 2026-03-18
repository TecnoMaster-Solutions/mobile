import 'package:flutter/material.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';

class NavigationHelper {
  const NavigationHelper._();

  static String? _firstLeafRouteForPermissions(Set<String> perms) {
    if (perms.contains('dashboard.read')) return AppRoutes.adminHome;
    if (perms.contains('users.read')) return AppRoutes.userList;
    if (perms.contains('roles.read')) return AppRoutes.rolesList;
    if (perms.contains('purchaseorders.read')) return AppRoutes.purchaseOrders;
    if (perms.contains('purchases.read')) return AppRoutes.purchases;
    if (perms.contains('suppliers.read')) return AppRoutes.providers;
    if (perms.contains('categoryproducts.read')) return AppRoutes.productCategories;
    if (perms.contains('products.read')) return AppRoutes.productsList;
    if (perms.contains('services.read')) return AppRoutes.servicesList;
    if (perms.contains('technicians.read')) return AppRoutes.techniciansList;
    if (perms.contains('sales.read')) return AppRoutes.sales;
    if (perms.contains('customers.read')) return AppRoutes.clients;
    if (perms.contains('servicesrequest.read')) return AppRoutes.requests;
    if (perms.contains('quotes.read')) return AppRoutes.quotes;
    if (perms.contains('orderservices.read')) return AppRoutes.salesOrders;
    if (perms.contains('appointments.read')) return AppRoutes.salesAppointments;
    return null;
  }

  static String landingRouteForPermissions(List<String> permissions) {
    final perms = permissions.map((p) => p.toLowerCase()).toSet();
    if (SessionContext.isClientRole) {
      return _firstLeafRouteForPermissions(perms) ?? AppRoutes.adminHome;
    }
    if (perms.contains('dashboard.read')) {
      return AppRoutes.adminHome;
    }
    if (perms.contains('appointments.read')) {
      return AppRoutes.techHub;
    }
    if (perms.contains('sales.read') ||
        perms.contains('customers.read') ||
        perms.contains('servicesrequest.read') ||
        perms.contains('quotes.read') ||
        perms.contains('orderservices.read')) {
      return AppRoutes.salesHub;
    }
    return _firstLeafRouteForPermissions(perms) ?? AppRoutes.adminHome;
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
