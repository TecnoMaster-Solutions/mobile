import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';

const _sideMenuBg = Color(0xFF04652C);
const _sideMenuCollapse = Color(0xFF034A21);
const _sideMenuHover = Color(0xFF058A3C);
const _sideMenuActiveSubmenu = Color(0xFF06A646);
const _sideMenuActiveLink = Color(0xFF08873C);
const _sideMenuBorder = Color(0xFFC3E6D2);
const _sideMenuDropdownBg = Color(0xFFD0F0DC);
const _sideMenuSecondaryText = Color(0xFFE6F6EC);
const _sideMenuDropdownText = Color(0xFF04652C);

class SideMenuButton extends StatelessWidget {
  static const double buttonSize = 44;

  const SideMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: _sideMenuCollapse,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class SideMenuPanel extends StatefulWidget {
  const SideMenuPanel({
    super.key,
    required this.permissions,
    required this.onClose,
    required this.onLogout,
  });

  final List<String> permissions;
  final VoidCallback onClose;
  final VoidCallback onLogout;

  @override
  State<SideMenuPanel> createState() => _SideMenuPanelState();
}

class _SideMenuPanelState extends State<SideMenuPanel> {
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
    Navigator.of(context).pushNamed(route, arguments: widget.permissions);
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

  bool _isRouteActive(String? route) {
    if (route == null) return false;
    return ModalRoute.of(context)?.settings.name == route;
  }

  bool _isSubmenuActive(List<_SideMenuItem> children) {
    return children.any((child) => _isRouteActive(child.route));
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
            width: 26,
            height: 26,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          )
        : item.icon != null
        ? Icon(item.icon, color: Colors.white)
        : const SizedBox.shrink();

    if (!item.hasChildren) {
      final isActive = _isRouteActive(item.route);
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isActive ? _sideMenuActiveLink : null,
        hoverColor: _sideMenuHover,
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
    final isActiveGroup = _isSubmenuActive(children);
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tileColor: (isExpanded || isActiveGroup) ? _sideMenuActiveSubmenu : null,
          hoverColor: _sideMenuHover,
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
            child: const Icon(
              Icons.keyboard_arrow_down,
              color: _sideMenuSecondaryText,
            ),
          ),
          onTap: () => _toggle(item.label),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              if (isExpanded)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _sideMenuDropdownBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _sideMenuBorder),
                  ),
                  child: Column(
                    children: children.map((child) {
                      final isActive = _isRouteActive(child.route);
                      return Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          dense: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          tileColor: isActive ? _sideMenuActiveLink : null,
                          hoverColor: _sideMenuHover.withValues(alpha: 0.2),
                          leading: const SizedBox.shrink(),
                          title: Text(
                            child.label,
                            style: TextStyle(
                              color: isActive ? Colors.white : _sideMenuDropdownText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => _navigate(child.route!),
                        ),
                      );
                    }).toList(growable: false),
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
            color: _sideMenuBg,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            border: Border(
              right: BorderSide(color: _sideMenuBorder),
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
                          color: _sideMenuBg,
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
                              color: _sideMenuSecondaryText,
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
              const Divider(color: _sideMenuBorder, height: 1),
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
                    const Divider(color: _sideMenuBorder, height: 1),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      hoverColor: _sideMenuHover,
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
        label: 'Técnicos',
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
      'quotes.read',
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
        label: 'Cotizaciones',
        route: AppRoutes.quotes,
        requiredPermissions: ['quotes.read'],
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
