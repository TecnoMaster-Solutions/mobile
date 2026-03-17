import 'package:flutter/material.dart';
import 'package:vertecx/data/models/purchases/purchase_model.dart';
import 'package:vertecx/data/repositories/purchases/purchases_repository.dart';
import 'package:vertecx/presentation/widgets/components/search/search.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/purchasesWidgets/purchase_card_widget.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  final ScrollController _scrollController = ScrollController();
  final PurchasesRepository _repository = PurchasesRepository();

  int _purchasesToShow = 4;
  String _searchQuery = "";
  late Future<List<PurchaseModel>> _futurePurchases;

  @override
  void initState() {
    super.initState();
    _futurePurchases = _loadPurchases();
  }

  Future<List<PurchaseModel>> _loadPurchases() async {
    final response = await _repository.fetchPurchases(
      page: 1,
      limit: 50,
      search: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
    );
    return response.data;
  }

  void _refreshPurchases() {
    setState(() {
      _purchasesToShow = 4;
      _futurePurchases = _loadPurchases();
    });
  }

  void _loadMorePurchases(int max) {
    setState(() {
      _purchasesToShow = (_purchasesToShow + 2).clamp(0, max);
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
    return Scaffold(
      appBar: const AppTopBar(title: 'Compras', showMenu: true),
      backgroundColor: const Color(0xFFE8E8E8),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Buscar(
            hintText: "Buscar proveedor, orden o factura...",
            onChanged: (value) {
              _searchQuery = value;
              _refreshPurchases();
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<PurchaseModel>>(
              future: _futurePurchases,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFB20000),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }

                final purchases = snapshot.data ?? [];
                final visiblePurchases =
                    purchases.take(_purchasesToShow).toList();
                final allPurchasesLoaded =
                    _purchasesToShow >= purchases.length;

                return SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 90),
                  child: Column(
                    children: [
                      if (visiblePurchases.isNotEmpty)
                        ...visiblePurchases
                            .map((p) => PurchaseCardWidget(compra: p))
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
                      if (purchases.isNotEmpty)
                        if (!allPurchasesLoaded)
                          TextButton(
                            onPressed: () => _loadMorePurchases(purchases.length),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/icons/Vector.png",
                                  width: 20,
                                  height: 20,
                                ),
                                const Text(
                                  "Cargar más compras",
                                  style: TextStyle(color: Color(0xFF089642)),
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
                                color: Color(0xFF089642),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: const Color(0xFF089642),
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }
}