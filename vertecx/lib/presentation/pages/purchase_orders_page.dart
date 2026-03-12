import 'package:flutter/material.dart';
import 'package:vertecx/data/repositories/purchases/purchase_order_repository.dart';
import 'package:vertecx/data/models/purchases/purchase_order_model.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/side_menu_panel.dart';
import 'package:vertecx/presentation/widgets/components/search/search.dart';
import 'package:vertecx/presentation/widgets/purchasesWidgets/purchase_orders_card_widget.dart';

class PurchaseOrdersPage extends StatefulWidget {
  const PurchaseOrdersPage({super.key});

  @override
  State<PurchaseOrdersPage> createState() => _PurchaseOrdersPageState();
}

class _PurchaseOrdersPageState extends State<PurchaseOrdersPage> {
  final ScrollController _scrollController = ScrollController();
  final PurchaseOrderRepository _repository = PurchaseOrderRepository();
  
  List<PurchaseOrderModel> _allOrders = [];
  List<PurchaseOrderModel> _filteredOrders = [];
  bool _isLoading = true;
  String _errorMessage = "";
  String _searchQuery = "";
  int _itemsToShow = 4;
  List<String> _permissions = const <String>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is List<String>) {
      _permissions = args;
      return;
    }
    if (args is Map<String, dynamic>) {
      final raw = args['permissions'];
      if (raw is List) {
        _permissions = raw.map((e) => e.toString()).toList();
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    try {
      final orders = await _repository.fetchPurchaseOrders();
      setState(() {
        _allOrders = orders;
        _filteredOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _filterOrders(String query) {
    setState(() {
      _searchQuery = query;
      _filteredOrders = _allOrders.where((o) {
        final q = query.toLowerCase();
        return o.supplier.toLowerCase().contains(q) ||
               o.orderIdString.toLowerCase().contains(q) ||
               o.orderNumber.toLowerCase().contains(q);
      }).toList();
      _itemsToShow = 4;
    });
  }

  void _loadMore() {
    setState(() {
      _itemsToShow = (_itemsToShow + 4).clamp(0, _filteredOrders.length);
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
    final orders = _filteredOrders.take(_itemsToShow).toList();
    final allOrdersLoaded = _itemsToShow >= _filteredOrders.length;

    return Scaffold(
      appBar: const AppTopBar(showMenu: true),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: SideMenuPanel(
          permissions: _permissions,
          onClose: () => Navigator.of(context).maybePop(),
          onLogout: () {
            Navigator.of(context).maybePop();
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          },
        ),
      ),
      backgroundColor: const Color(0xFFE8E8E8),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            child: Column(
            children: [
              const SizedBox(height: 20),
              Buscar(
                hintText: "Buscar órdenes...",
                onChanged: _filterOrders,
              ),
              const SizedBox(height: 20),
              
              if (_isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ))
              else if (_errorMessage.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Error: $_errorMessage",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else if (orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "No se encontraron órdenes",
                    style: TextStyle(
                      color: Color(0xFFB20000),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                ...orders.map((o) => PurchaseOrderCardWidget(order: o)),

              const SizedBox(height: 20),

              if (!_isLoading && _filteredOrders.isNotEmpty)
                if (!allOrdersLoaded)
                  TextButton(
                    onPressed: _loadMore,
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/icons/Vector.png",
                          width: 20,
                          height: 20,
                        ),
                        const Text(
                          "Cargar más órdenes",
                          style: TextStyle(color: Color(0xFFB20000)),
                        ),
                      ],
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Ya están todas las órdenes",
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: const Color(0xFF089642),
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }
}

