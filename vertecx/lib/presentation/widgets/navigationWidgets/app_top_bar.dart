import 'package:flutter/material.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/side_menu_panel.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.centerTitle = true,
    this.showBack = false,
    this.showMenu = false,
    this.extraActions,
  });

  final String? title;
  final bool centerTitle;
  final bool showBack;
  final bool showMenu;
  final List<Widget>? extraActions;

  @override
  Size get preferredSize =>
      const Size.fromHeight(SideMenuButton.buttonSize + 16);

  String _titleFromRoute(BuildContext context) {
    final name = ModalRoute.of(context)?.settings.name ?? '';
    switch (name) {
      case AppRoutes.home:
        return 'Dashboard';
      case AppRoutes.userList:
        return 'Usuarios';
      case AppRoutes.categoryProduct:
        return 'Productos';
      case AppRoutes.salesAppointments:
        return 'Citas';
      case AppRoutes.dashboard:
        return 'Dashboard';
      case AppRoutes.profile:
        return 'Mi Perfil';
      case AppRoutes.rolesList:
        return 'Roles';
      case AppRoutes.salesOrders:
        return 'Ordenes de Servicio';
      case AppRoutes.requests:
        return 'Solicitudes';
      case AppRoutes.techniciansList:
        return 'Tecnicos';
      case AppRoutes.servicesList:
        return 'Servicios';
      case AppRoutes.productsList:
        return 'Productos';
      case AppRoutes.sales:
        return 'Ventas';
      case AppRoutes.purchases:
        return 'Compras';
      case AppRoutes.providers:
        return 'Proveedores';
      case AppRoutes.clients:
        return 'Clientes';
      case AppRoutes.salesHub:
        return 'Ventas';
      case AppRoutes.purchasesHub:
        return 'Compras';
      case AppRoutes.productsHub:
        return 'Productos';
      case AppRoutes.servicesHub:
        return 'Servicios';
      case AppRoutes.purchaseOrders:
        return 'Orden de Compra';
      default:
        return 'Sistemas PC';
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ?? _titleFromRoute(context);

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 1.5,
      backgroundColor: Colors.white,
      centerTitle: centerTitle,
      toolbarHeight: SideMenuButton.buttonSize + 12,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : showMenu
              ? Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: SideMenuButton.buttonSize,
                      height: SideMenuButton.buttonSize,
                      child: const SideMenuButton(),
                    ),
                  ),
                )
              : null,
      leadingWidth: showMenu ? SideMenuButton.buttonSize + 8 : null,
      titleSpacing: 0,
      title: Text(
        resolvedTitle,
        style: const TextStyle(
          color: Color(0xFFB20000),
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: extraActions ?? [],
    );
  }
}

