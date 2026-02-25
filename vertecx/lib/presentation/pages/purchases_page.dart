import 'package:flutter/material.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/purchasesWidgets/purchase_card_widget.dart';
import 'package:vertecx/presentation/widgets/components/search/search.dart';
import 'package:vertecx/data/mocks/purchases_mock_data.dart';
class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  final ScrollController _scrollController = ScrollController();
  int _purchasesToShow = 4; // cantidad inicial de compras
  String _searchQuery = "";

  // 🔹 Cargar más registros
  void _loadMorePurchases() {
    setState(() {
      _purchasesToShow = (_purchasesToShow + 2).clamp(0, mockPurchases.length);
    });
  }

  // 🔹 Subir al inicio
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔎 Filtrar compras por proveedor o ID
    final filteredPurchases = mockPurchases.where((p) {
      final query = _searchQuery.toLowerCase();
      return p.proveedor.toLowerCase().contains(query) ||
          p.id.toLowerCase().contains(query) ||
          p.factura.toLowerCase().contains(query);
    }).toList();

    // Paginación
    final purchases = filteredPurchases.take(_purchasesToShow).toList();
    final allPurchasesLoaded = _purchasesToShow >= filteredPurchases.length;

    return Scaffold(
      appBar: const AppTopBar(),
      backgroundColor: const Color(0xFFE8E8E8),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🔎 Buscador
            Buscar(
              hintText: "Buscar proveedor, OC o factura...",
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // 📋 Lista de compras
            if (purchases.isNotEmpty)
              ...purchases.map((p) => PurchaseCardWidget(compra: p))
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "No se encontraron compras",
                  style: TextStyle(
                    color: Color(0xFFB20000),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // 🔽 Botón cargar más o mensaje final
            if (filteredPurchases.isNotEmpty)
              if (!allPurchasesLoaded)
                TextButton(
                  onPressed: _loadMorePurchases,
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/icons/Vector.png",
                        width: 20,
                        height: 20,
                      ),
                      const Text(
                        "Cargar más compras",
                        style: TextStyle(color: Color(0xFFB20000)),
                      ),
                    ],
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "Ya están todas las compras",
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

      // ⬆️ Botón flotante para subir
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: const Color(0xFFB20000),
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }
}
