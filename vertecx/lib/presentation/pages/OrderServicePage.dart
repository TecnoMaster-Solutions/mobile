import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vertecx/blocs/OrderServiceController.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/data/repositories/orderServices/order_repository.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/side_menu_panel.dart';
import 'package:vertecx/presentation/widgets/orderServicesWidgets/OrderServiceCard.dart';

const _brandGreen = Color(0xFF06A646);
const _brandGreenDark = Color(0xFF058A3C);
const _brandGreenDeep = Color(0xFF04652C);
const _pageBackground = Color(0xFFF4F7F5);
const _inputBorder = Color(0xFFD7E2DA);

class OrderServicePage extends StatelessWidget {
  const OrderServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderServiceController(OrderRepository())..load(),
      child: const _OrderServiceView(),
    );
  }
}

class _OrderServiceView extends StatefulWidget {
  const _OrderServiceView();

  @override
  State<_OrderServiceView> createState() => _OrderServiceViewState();
}

class _OrderServiceViewState extends State<_OrderServiceView> {
  final ScrollController _scrollController = ScrollController();
  int _ordersToShow = 4;
  List<String> _permissions = const <String>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  void _loadMore() {
    final int total = context.read<OrderServiceController>().orders.length;
    setState(() {
      _ordersToShow = (_ordersToShow + 2).clamp(0, total);
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OrderServiceController>();
    final List all = controller.orders;
    final List shown = all.take(_ordersToShow).toList();
    final bool allLoaded = _ordersToShow >= all.length;

    Widget content;
    if (controller.isLoading && all.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (controller.error != null && all.isEmpty) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          controller.error!,
          style: const TextStyle(color: Color(0xFFB42318)),
        ),
      );
    } else if (shown.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No se encontraron ordenes',
          style: TextStyle(
            color: _brandGreenDeep,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      content = Column(
        children: shown
            .map(
              (o) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: OrderCard(order: o),
              ),
            )
            .toList(),
      );
    }

    return Scaffold(
      backgroundColor: _pageBackground,
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
      appBar: const AppTopBar(
        title: 'Ordenes de Servicio',
        centerTitle: true,
        showMenu: true,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: controller.search,
                decoration: InputDecoration(
                  hintText: 'Buscar ordenes...',
                  prefixIcon: const Icon(Icons.search, color: _brandGreenDeep),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 12,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: _inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: _inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: _brandGreen, width: 1.4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Mas recientes'),
                    selected: controller.sortOrder == OrderSortOrder.newestFirst,
                    onSelected: (_) =>
                        controller.setSortOrder(OrderSortOrder.newestFirst),
                    selectedColor: _brandGreen.withOpacity(0.14),
                    labelStyle: TextStyle(
                      color: controller.sortOrder == OrderSortOrder.newestFirst
                          ? _brandGreenDeep
                          : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: controller.sortOrder == OrderSortOrder.newestFirst
                          ? _brandGreen
                          : _inputBorder,
                    ),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Mas antiguas'),
                    selected: controller.sortOrder == OrderSortOrder.oldestFirst,
                    onSelected: (_) =>
                        controller.setSortOrder(OrderSortOrder.oldestFirst),
                    selectedColor: _brandGreen.withOpacity(0.14),
                    labelStyle: TextStyle(
                      color: controller.sortOrder == OrderSortOrder.oldestFirst
                          ? _brandGreenDeep
                          : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: controller.sortOrder == OrderSortOrder.oldestFirst
                          ? _brandGreen
                          : _inputBorder,
                    ),
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            content,
            const SizedBox(height: 8),
            if (!controller.isLoading && controller.error == null && all.isNotEmpty)
              if (!allLoaded)
                TextButton(
                  onPressed: _loadMore,
                  child: const Text(
                    'Cargar mas ordenes',
                    style: TextStyle(color: _brandGreenDeep),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Ya estan todas las ordenes',
                    style: TextStyle(
                      color: _brandGreenDeep,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'orders_scroll_top_fab',
        onPressed: _scrollToTop,
        backgroundColor: _brandGreenDark,
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }
}
