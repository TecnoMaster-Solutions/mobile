import 'package:flutter/material.dart';
import 'package:vertecx/data/models/sales/sale_model.dart';
import 'package:vertecx/data/repositories/sales/sale_repository.dart';
import 'package:vertecx/presentation/widgets/components/search/search.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/side_menu_panel.dart';
import 'package:vertecx/presentation/widgets/salesWidgets/sales_card_widget.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final ScrollController _scrollController = ScrollController();
  final SaleRepository _repository = SaleRepository();

  List<SaleModel> _allSales = [];
  List<SaleModel> _filteredSales = [];
  bool _isLoading = true;
  String _errorMessage = "";
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
    _loadSales();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSales() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    try {
      final sales = await _repository.fetchSales();
      setState(() {
        _allSales = sales;
        _filteredSales = sales;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _filterSales(String query) {
    setState(() {
      final q = query.toLowerCase();
      _filteredSales = _allSales.where((s) {
        return s.clientName.toLowerCase().contains(q) ||
            s.id.toLowerCase().contains(q) ||
            s.saleCode.toLowerCase().contains(q);
      }).toList();
      _itemsToShow = 4;
    });
  }

  void _loadMore() {
    setState(() {
      _itemsToShow = (_itemsToShow + 4).clamp(0, _filteredSales.length);
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
    final sales = _filteredSales.take(_itemsToShow).toList();
    final allSalesLoaded = _itemsToShow >= _filteredSales.length;

    return Scaffold(
      appBar: const AppTopBar(showMenu: true),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: SideMenuPanel(
          permissions: _permissions,
          onClose: () => Navigator.of(context).maybePop(),
          onLogout: () {
            Navigator.of(context).maybePop();
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          },
        ),
      ),
      backgroundColor: const Color(0xFFE8E8E8),
      body: RefreshIndicator(
        onRefresh: _loadSales,
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Buscar(
                  hintText: "Buscar cliente o ID...",
                  onChanged: _filterSales,
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
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
                else if (sales.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No se encontraron ventas",
                      style: TextStyle(
                        color: Color(0xFFB20000),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  ...sales.map((s) => SaleCardWidget(sale: s)),
                const SizedBox(height: 20),
                if (!_isLoading && _filteredSales.isNotEmpty)
                  if (!allSalesLoaded)
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
                            "Cargar mas ventas",
                            style: TextStyle(color: Color(0xFFB20000)),
                          ),
                        ],
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Ya estan todas las ventas",
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
