import 'package:flutter/material.dart';
import 'package:vertecx/data/mocks/sales_mock_data.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/salesWidgets/sales_card_widget.dart';
import 'package:vertecx/presentation/widgets/components/search/search.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final ScrollController _scrollController = ScrollController();
  int _salesToShow = 4; // cantidad inicial de ventas
  String _searchQuery = "";

  void _loadMoreSales() {
    setState(() {
      _salesToShow = (_salesToShow + 2).clamp(0, mockSales.length);
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
    // Filtrar ventas por nombre de cliente o ID
    final filteredSales = mockSales.where((s) {
      final query = _searchQuery.toLowerCase();
      return s.clientName.toLowerCase().contains(query) ||
          s.id.toLowerCase().contains(query);
    }).toList();

    // Paginación
    final sales = filteredSales.take(_salesToShow).toList();
    final allSalesLoaded = _salesToShow >= filteredSales.length;

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
              hintText: "Buscar cliente o ID...",
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // 📋 Lista de resultados
            if (sales.isNotEmpty)
              ...sales.map(
                (s) =>
                    SaleCardWidget(sale: s), // 👈 ya no tiene GestureDetector
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "No se encontraron ventas",
                  style: TextStyle(
                    color: Color(0xFFB20000),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Botón o mensaje de final
            if (filteredSales.isNotEmpty)
              if (!allSalesLoaded)
                TextButton(
                  onPressed: _loadMoreSales,
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/icons/Vector.png",
                        width: 20,
                        height: 20,
                      ),
                      const Text(
                        "Cargar más ventas",
                        style: TextStyle(color: Color(0xFFB20000)),
                      ),
                    ],
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "Ya están todas las ventas",
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

      // ⬆️ Botón flotante
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: const Color(0xFFB20000),
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }
}
