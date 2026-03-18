import 'package:flutter/material.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/side_menu_panel.dart';
import '../widgets/components/search/search.dart';
import 'package:vertecx/data/models/clients/customer_model.dart';
import 'package:vertecx/data/repositories/clients/customer_repository.dart';
import '../widgets/clientsWidgets/clients_card_widget.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final ScrollController _scrollController = ScrollController();
  final CustomerRepository _repository = CustomerRepository();
  
  List<CustomerModel> _allCustomers = [];
  List<CustomerModel> _filteredCustomers = [];
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
    // Fallback? SessionContext is usually where we store it globally too
  }

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    try {
      final customers = await _repository.fetchCustomers();
      setState(() {
        _allCustomers = customers;
        _filteredCustomers = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      _searchQuery = query;
      _filteredCustomers = _allCustomers
          .where((c) => c.name.toLowerCase().contains(query.toLowerCase()) || 
                       c.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _itemsToShow = 4; // Reset pagination on search
    });
  }

  void _loadMore() {
    setState(() {
      _itemsToShow = (_itemsToShow + 4).clamp(0, _filteredCustomers.length);
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
    final clients = _filteredCustomers.take(_itemsToShow).toList();
    final allClientsLoaded = _itemsToShow >= _filteredCustomers.length;

    return Scaffold(
      appBar: const AppTopBar(showMenu: true),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: SideMenuPanel(
          permissions: _permissions,
          onClose: () => Navigator.of(context).maybePop(),
          onLogout: () {
            Navigator.of(context).maybePop();
            // SessionContext.clearAll(); // Import needed
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          },
        ),
      ),
      backgroundColor: const Color(0xFFE8E8E8),
      body: RefreshIndicator(
        onRefresh: _loadCustomers,
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            child: Column(
            children: [
              const SizedBox(height: 20),
              Buscar(
                hintText: "Buscar cliente...",
                onChanged: _filterCustomers,
              ),
              const SizedBox(height: 20),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
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
              else if (clients.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "No se encontraron clientes",
                    style: TextStyle(
                      color: Color(0xFFB20000),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                ...clients.map((c) => ClientCardWidget(client: c)),

              const SizedBox(height: 20),

              if (!_isLoading && _filteredCustomers.isNotEmpty)
                if (!allClientsLoaded)
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
                          "Cargar más clientes",
                          style: TextStyle(color: Color(0xFFB20000)),
                        ),
                      ],
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Ya están todos los clientes",
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

