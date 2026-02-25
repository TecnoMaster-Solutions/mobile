import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vertecx/core/navigation_helper.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';

const _sideMenuWine = Color(0xFFB20000);

class AppSideMenuPanel extends StatefulWidget {
  const AppSideMenuPanel({
    super.key,
    required this.permissions,
    required this.onClose,
    required this.onLogout,
  });

  final List<String> permissions;
  final VoidCallback onClose;
  final VoidCallback onLogout;

  @override
  State<AppSideMenuPanel> createState() => _AppSideMenuPanelState();
}

class _AppSideMenuPanelState extends State<AppSideMenuPanel> {
  final _expanded = <String>{};

  Set<String> get _permSet =>
      widget.permissions.map((p) => p.toLowerCase()).toSet();

  void _toggle(String label) {
    setState(() {
      if (_expanded.contains(label)) {
        _expanded.remove(label);
      } else {
        _expanded.add(label);
      }
    });
  }

  void _navigate(String route) {
    widget.onClose();
    NavigationHelper.goToPrimarySection(
      context,
      route: route,
      permissions: widget.permissions,
    );
  }

  bool _hasPermission(_SideMenuItem item) {
    if (item.requiredPermissions == null || item.requiredPermissions!.isEmpty) {
      return true;
    }
    return item.requiredPermissions!
        .map((p) => p.toLowerCase())
        .any(_permSet.contains);
  }

  List<_SideMenuItem> _visibleChildren(List<_SideMenuItem> children) {
    return children
        .where((child) => _hasPermission(child))
        .toList(growable: false);
  }

  Widget _buildItem(_SideMenuItem item) {
    if (!item.hasChildren && !_hasPermission(item)) {
      return const SizedBox.shrink();
    }

    final children = item.children != null
        ? _visibleChildren(item.children!)
        : const <_SideMenuItem>[];

    final showGroup =
        item.hasChildren && (children.isNotEmpty || _hasPermission(item));

    if (item.hasChildren && !showGroup) {
      return const SizedBox.shrink();
    }

    final leading = item.iconAsset != null
        ? SvgPicture.asset(
            item.iconAsset!,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          )
        : item.icon != null
        ? Icon(item.icon, color: Colors.white)
        : const SizedBox.shrink();

    if (!item.hasChildren) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: leading,
        title: Text(
          item.label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () => _navigate(item.route!),
      );
    }

    final isExpanded = _expanded.contains(item.label);
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: leading,
          title: Text(
            item.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 380),
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          ),
          onTap: () => _toggle(item.label),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              if (isExpanded)
                ...children.map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(left: 48),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      dense: true,
                      leading: const SizedBox.shrink(),
                      title: Text(
                        child.label,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () => _navigate(child.route!),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          width: 250,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: _sideMenuWine,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 12,
                offset: Offset(4, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: const Text(
                        'v',
                        style: TextStyle(
                          color: _sideMenuWine,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Vertecx',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Panel de gestion',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(top: 8),
                        children: _menuItems.map(_buildItem).toList(),
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      leading: const Icon(Icons.logout, color: Colors.white),
                      title: const Text(
                        'Salir',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: widget.onLogout,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideMenuItem {
  const _SideMenuItem({
    required this.label,
    this.icon,
    this.iconAsset,
    this.route,
    this.children,
    this.requiredPermissions,
  });

  final String label;
  final IconData? icon;
  final String? iconAsset;
  final String? route;
  final List<_SideMenuItem>? children;
  final List<String>? requiredPermissions;

  bool get hasChildren => children != null && children!.isNotEmpty;
}

const _menuItems = [
  _SideMenuItem(
    label: 'Perfil',
    iconAsset: 'assets/image/userPerfil.svg',
    route: AppRoutes.profile,
    requiredPermissions: null,
  ),
  _SideMenuItem(
    label: 'Dashboard',
    icon: Icons.home,
    route: AppRoutes.dashboard,
    requiredPermissions: ['dashboard.read'],
  ),
  _SideMenuItem(
    label: 'Usuarios',
    icon: Icons.person,
    route: AppRoutes.userList,
    requiredPermissions: ['users.read'],
  ),
  _SideMenuItem(
    label: 'Roles',
    icon: Icons.group,
    route: AppRoutes.rolesList,
    requiredPermissions: ['roles.read'],
  ),
  _SideMenuItem(
    label: 'Compras',
    icon: Icons.local_shipping,
    requiredPermissions: [
      'purchases.read',
      'purchaseorders.read',
      'suppliers.read',
    ],
    children: [
      _SideMenuItem(
        label: 'Proveedores',
        route: AppRoutes.providers,
        requiredPermissions: ['suppliers.read'],
      ),
      _SideMenuItem(
        label: 'Compras',
        route: AppRoutes.purchases,
        requiredPermissions: ['purchases.read'],
      ),
      _SideMenuItem(
        label: 'Orden de compra',
        route: AppRoutes.purchaseOrders,
        requiredPermissions: ['purchaseorders.read'],
      ),
    ],
  ),
  _SideMenuItem(
    label: 'Productos',
    icon: Icons.widgets,
    requiredPermissions: ['products.read', 'categoryproducts.read'],
    children: [
      _SideMenuItem(
        label: 'Productos',
        route: AppRoutes.productsList,
        requiredPermissions: ['products.read'],
      ),
      _SideMenuItem(
        label: 'Categorias',
        route: AppRoutes.productCategories,
        requiredPermissions: ['categoryproducts.read'],
      ),
    ],
  ),
  _SideMenuItem(
    label: 'Servicios',
    icon: Icons.build,
    requiredPermissions: ['services.read', 'technicians.read'],
    children: [
      _SideMenuItem(
        label: 'Servicios',
        route: AppRoutes.servicesList,
        requiredPermissions: ['services.read'],
      ),
      _SideMenuItem(
        label: 'Tecnicos',
        route: AppRoutes.techniciansList,
        requiredPermissions: ['technicians.read'],
      ),
    ],
  ),
  _SideMenuItem(
    label: 'Ventas',
    icon: Icons.shopping_cart,
    requiredPermissions: [
      'sales.read',
      'customers.read',
      'servicesrequest.read',
      'orderservices.read',
      'appointments.read',
    ],
    children: [
      _SideMenuItem(
        label: 'Ventas',
        route: AppRoutes.sales,
        requiredPermissions: ['sales.read'],
      ),
      _SideMenuItem(
        label: 'Clientes',
        route: AppRoutes.clients,
        requiredPermissions: ['customers.read'],
      ),
      _SideMenuItem(
        label: 'Solicitudes',
        route: AppRoutes.requests,
        requiredPermissions: ['servicesrequest.read'],
      ),
      _SideMenuItem(
        label: 'Ordenes',
        route: AppRoutes.salesOrders,
        requiredPermissions: ['orderservices.read'],
      ),
      _SideMenuItem(
        label: 'Citas',
        route: AppRoutes.salesAppointments,
        requiredPermissions: ['appointments.read'],
      ),
    ],
  ),
];
