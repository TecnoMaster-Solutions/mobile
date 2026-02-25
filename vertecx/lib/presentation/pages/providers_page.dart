import 'package:flutter/material.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/data/models/suppliers/supplier_model.dart';
import 'package:vertecx/data/services/suppliers_service.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';
import 'package:vertecx/presentation/widgets/components/search/search.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/side_menu_panel.dart';
import 'package:vertecx/presentation/widgets/suppliersWidgets/supplier_card_widget.dart';

class ProvidersPage extends StatefulWidget {
  const ProvidersPage({super.key});

  @override
  State<ProvidersPage> createState() => _ProvidersPageState();
}

class _ProvidersPageState extends State<ProvidersPage> {
  final SuppliersService _service = SuppliersService();
  final ScrollController _scrollController = ScrollController();

  List<SupplierModel> _suppliers = const <SupplierModel>[];
  List<String> _permissions = const <String>[];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  int _suppliersToShow = 6;
  bool _permissionsReady = false;
  final Set<int> _updatingSupplierIds = <int>{};

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_permissionsReady) return;
    _permissionsReady = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is List<String>) {
      _permissions = args;
      SessionContext.permissions = args;
      return;
    }
    if (args is Map<String, dynamic>) {
      final raw = args['permissions'];
      if (raw is List) {
        final perms = raw.map((e) => e.toString()).toList();
        _permissions = perms;
        SessionContext.permissions = perms;
        return;
      }
    }
    _permissions = SessionContext.permissions;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSuppliers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _service.getSuppliers();
      if (!mounted) return;
      setState(() {
        _suppliers = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleStatus(SupplierModel supplier) async {
    final isActive = supplier.status == SupplierStatus.active;
    final nextStateId = isActive ? 2 : 1;
    if (_updatingSupplierIds.contains(supplier.id)) return;

    final confirmed = await _showStatusDialog(
      supplier: supplier,
      activating: !isActive,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _updatingSupplierIds.add(supplier.id));
    try {
      final updated = await _service.updateSupplierState(
        supplier.id,
        nextStateId,
      );
      if (!mounted) return;

      setState(() {
        _suppliers = _suppliers
            .map((s) => s.id == supplier.id ? updated : s)
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estado actualizado correctamente'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo actualizar el estado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingSupplierIds.remove(supplier.id));
      }
    }
  }

  Future<bool?> _showStatusDialog({
    required SupplierModel supplier,
    required bool activating,
  }) {
    final title = activating ? 'Activar proveedor' : 'Inactivar proveedor';
    final actionText = activating ? 'Activar' : 'Inactivar';
    final actionColor = activating
        ? const Color(0xFF2E7D32)
        : const Color(0xFFC62828);
    final icon = activating ? Icons.check_circle : Icons.block;

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          contentPadding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          title: Row(
            children: [
              Icon(icon, color: actionColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                supplier.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'ID ${supplier.id} - ${supplier.nit}',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  activating
                      ? 'Este proveedor volvera a estar disponible para operaciones de compra.'
                      : 'El proveedor se mantendra en el sistema, pero quedara inactivo para nuevas operaciones.',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: actionColor),
              onPressed: () => Navigator.of(context).pop(true),
              icon: Icon(icon, size: 16),
              label: Text(actionText),
            ),
          ],
        );
      },
    );
  }

  void _loadMore(int total) {
    setState(() {
      _suppliersToShow = (_suppliersToShow + 4).clamp(0, total);
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _suppliers
        .where((supplier) => supplier.matchesQuery(_searchQuery))
        .toList();
    final visible = filtered.take(_suppliersToShow).toList();
    final allLoaded = _suppliersToShow >= filtered.length;

    return Scaffold(
      appBar: const AppTopBar(title: 'Proveedores', showMenu: true),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: SideMenuPanel(
          permissions: _permissions,
          onClose: () => Navigator.of(context).maybePop(),
          onLogout: () {
            Navigator.of(context).maybePop();
            SessionContext.clearAll();
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
          },
        ),
      ),
      backgroundColor: const Color(0xFFE8E8E8),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadSuppliers,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  child: Column(
                    children: [
                      Buscar(
                        hintText: 'Buscar proveedor...',
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                      ),
                      const SizedBox(height: 20),
                      if (visible.isNotEmpty)
                        ...visible.map(
                          (supplier) => SupplierCardWidget(
                            supplier: supplier,
                            onToggleStatus: () => _toggleStatus(supplier),
                            isUpdating: _updatingSupplierIds.contains(
                              supplier.id,
                            ),
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No se encontraron proveedores',
                            style: TextStyle(
                              color: Color(0xFFB20000),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),
                      if (filtered.isNotEmpty)
                        if (!allLoaded)
                          TextButton(
                            onPressed: () => _loadMore(filtered.length),
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/icons/Vector.png',
                                  width: 20,
                                  height: 20,
                                ),
                                const Text(
                                  'Cargar mas proveedores',
                                  style: TextStyle(color: Color(0xFFB20000)),
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Ya estan todos los proveedores',
                              style: TextStyle(
                                color: Color(0xFFB20000),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'providers_scroll_fab',
        onPressed: _scrollToTop,
        backgroundColor: const Color(0xFFB20000),
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }
}
