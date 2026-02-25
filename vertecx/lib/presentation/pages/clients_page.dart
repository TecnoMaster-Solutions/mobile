import 'package:flutter/material.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import '../widgets/components/search/search.dart';
import 'package:vertecx/data/mocks/clients_mock_data.dart';
import '../widgets/clientsWidgets/clients_card_widget.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final ScrollController _scrollController = ScrollController();
  int _clientsToShow = 4; // cantidad inicial de clientes
  String _searchQuery = "";

  void _loadMoreClients() {
    setState(() {
      _clientsToShow = (_clientsToShow + 2).clamp(0, mockClients.length);
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
    // filtrar clientes por búsqueda
    final filteredClients = mockClients
        .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    final clients = filteredClients.take(_clientsToShow).toList();
    final allClientsLoaded = _clientsToShow >= filteredClients.length;

    return Scaffold(
      appBar: const AppTopBar(),
      backgroundColor: const Color(0xFFE8E8E8),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const SizedBox(height: 20),

            // buscador
            Buscar(
              hintText: "Buscar cliente...",
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),

            const SizedBox(height: 20),

            // lista de clientes filtrados
            if (clients.isNotEmpty)
              ...clients.map((c) => ClientCardWidget(client: c))
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "No se encontraron clientes",
                  style: TextStyle(
                    color: Color(0xFFB20000),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // botón o mensaje final
            if (filteredClients.isNotEmpty)
              if (!allClientsLoaded)
                TextButton(
                  onPressed: _loadMoreClients,
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

      // botón flotante para subir
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: const Color(0xFFB20000),
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }
}
