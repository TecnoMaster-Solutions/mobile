import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vertecx/blocs/OrderServiceController.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/data/repositories/orderServices/order_repository.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_side_menu.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/orderServicesWidgets/OrderServiceCard.dart';

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
  bool _menuOpen = false;
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
    final total = context.read<OrderServiceController>().orders.length;
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
    final all = controller.orders;
    final shown = all.take(_ordersToShow).toList();
    final allLoaded = _ordersToShow >= all.length;

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
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (shown.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No se encontraron ordenes',
          style: TextStyle(
            color: Color(0xFFB20000),
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

    final topBar = const AppTopBar(
      title: 'Ordenes de Servicio',
      centerTitle: true,
    );

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: topBar.preferredSize.height, child: topBar),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: TextField(
                          onChanged: controller.search,
                          decoration: InputDecoration(
                            hintText: 'Buscar ordenes...',
                            prefixIcon: const Icon(Icons.search),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 12,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
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
                              selected:
                                  controller.sortOrder ==
                                  OrderSortOrder.newestFirst,
                              onSelected: (_) => controller.setSortOrder(
                                OrderSortOrder.newestFirst,
                              ),
                              selectedColor: const Color(
                                0xFFB20000,
                              ).withOpacity(0.12),
                              labelStyle: TextStyle(
                                color:
                                    controller.sortOrder ==
                                        OrderSortOrder.newestFirst
                                    ? const Color(0xFFB20000)
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              side: BorderSide(
                                color:
                                    controller.sortOrder ==
                                        OrderSortOrder.newestFirst
                                    ? const Color(0xFFB20000)
                                    : const Color(0xFFD1D5DB),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('Mas antiguas'),
                              selected:
                                  controller.sortOrder ==
                                  OrderSortOrder.oldestFirst,
                              onSelected: (_) => controller.setSortOrder(
                                OrderSortOrder.oldestFirst,
                              ),
                              selectedColor: const Color(
                                0xFFB20000,
                              ).withOpacity(0.12),
                              labelStyle: TextStyle(
                                color:
                                    controller.sortOrder ==
                                        OrderSortOrder.oldestFirst
                                    ? const Color(0xFFB20000)
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              side: BorderSide(
                                color:
                                    controller.sortOrder ==
                                        OrderSortOrder.oldestFirst
                                    ? const Color(0xFFB20000)
                                    : const Color(0xFFD1D5DB),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      content,
                      const SizedBox(height: 8),
                      if (!controller.isLoading &&
                          controller.error == null &&
                          all.isNotEmpty)
                        if (!allLoaded)
                          TextButton(
                            onPressed: _loadMore,
                            child: const Text(
                              'Cargar mas ordenes',
                              style: TextStyle(color: Color(0xFFB20000)),
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'Ya estan todas las ordenes',
                              style: TextStyle(
                                color: Color(0xFFB20000),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            left: 8,
            child: SafeArea(
              child: Material(
                elevation: 2,
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: IconButton(
                  onPressed: () => setState(() => _menuOpen = !_menuOpen),
                  icon: Icon(
                    _menuOpen ? Icons.close : Icons.menu,
                    color: const Color(0xFFB20000),
                  ),
                ),
              ),
            ),
          ),
          if (_menuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _menuOpen = false),
                child: const ColoredBox(color: Colors.black45),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 510),
            curve: Curves.easeOut,
            top: 0,
            bottom: 0,
            left: _menuOpen ? 0 : -260,
            child: AppSideMenuPanel(
              permissions: _permissions,
              onClose: () => setState(() => _menuOpen = false),
              onLogout: () {
                SessionContext.clearAll();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'orders_scroll_top_fab',
        onPressed: _scrollToTop,
        backgroundColor: const Color(0xFFB20000),
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }
}
