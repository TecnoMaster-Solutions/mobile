import 'package:flutter/material.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/components/search/search.dart';
import 'package:vertecx/data/mocks/purchase_orders_mock_data.dart';
import 'package:vertecx/presentation/widgets/purchasesWidgets/purchase_orders_card_widget.dart';

class PurchaseOrdersPage extends StatefulWidget {
  const PurchaseOrdersPage({super.key});

  @override
  State<PurchaseOrdersPage> createState() => _PurchaseOrdersPageState();
}

class _PurchaseOrdersPageState extends State<PurchaseOrdersPage> {
  final ScrollController _scrollController = ScrollController();
  int _ordersToShow = 4;
  String _searchQuery = "";

  void _loadMoreOrders() {
    setState(() {
      _ordersToShow = (_ordersToShow + 2).clamp(0, mockPurchaseOrders.length);
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
    final filteredOrders = mockPurchaseOrders
        .where(
          (o) =>
              o.supplier.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              o.id.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    final orders = filteredOrders.take(_ordersToShow).toList();
    final allOrdersLoaded = _ordersToShow >= filteredOrders.length;

    return Scaffold(
      appBar: AppTopBar(),
      backgroundColor: const Color(0xFFE8E8E8),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const SizedBox(height: 20),

            Buscar(
              hintText: "Buscar solicitudes...",
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),

            const SizedBox(height: 20),

            if (orders.isNotEmpty)
              ...orders.map((o) => PurchaseOrderCardWidget(order: o))
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "No se encontraron órdenes",
                  style: TextStyle(
                    color: Color(0xFFB20000),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            if (filteredOrders.isNotEmpty)
              if (!allOrdersLoaded)
                TextButton(
                  onPressed: _loadMoreOrders,
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

      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: const Color(0xFFB20000),
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }
}
