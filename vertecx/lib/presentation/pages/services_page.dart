import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';
import 'package:vertecx/presentation/widgets/components/search/search.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/side_menu_panel.dart';
import 'package:vertecx/presentation/widgets/servicesWidgets/services_card_widget.dart';

import 'package:vertecx/data/repositories/services/bloc/services_bloc.dart';
import 'package:vertecx/data/repositories/services/bloc/services_event.dart';
import 'package:vertecx/data/repositories/services/bloc/services_state.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = "";

  // Permisos para SideMenu
  List<String> _permissions = const <String>[];

  @override
  void initState() {
    super.initState();
    context.read<ServicesBloc>().add(LoadServicesEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is List<String>) {
      _permissions = args;
      SessionContext.permissions = args;
    } else {
      _permissions = SessionContext.permissions;
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  bool _matchesSearch(dynamic s) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return true;

    final name = (s.name).toLowerCase();
    final desc = (s.description).toLowerCase();
    final type = (s.typeName ?? '').toLowerCase();
    final state = (s.stateName ?? '').toLowerCase();

    return name.contains(q) ||
        desc.contains(q) ||
        type.contains(q) ||
        state.contains(q);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Servicios', showMenu: true),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: SideMenuPanel(
          permissions: _permissions,
          onClose: () => Navigator.of(context).maybePop(),
          onLogout: () {
            Navigator.of(context).maybePop();
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          },
        ),
      ),
      backgroundColor: const Color(0xFFE8E8E8),
      body: BlocBuilder<ServicesBloc, ServicesState>(
        builder: (context, state) {
          if (state is ServicesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ServicesError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state is ServicesLoaded) {
            final filtered = state.services.where(_matchesSearch).toList();

            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: Column(
                children: [
                  Buscar(
                    hintText: "Buscar servicio...",
                    onChanged: (value) =>
                        setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: 20),

                  if (filtered.isNotEmpty)
                    ...filtered.map((s) => ServiceCardWidget(service: s))
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No se encontraron servicios",
                        style: TextStyle(
                          color: Color(0xFFB20000),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  if (_searchQuery.trim().isEmpty)
                    if (state.services.isNotEmpty)
                      if (state.hasMore)
                        TextButton(
                          onPressed: state.loadingMore
                              ? null
                              : () => context
                                  .read<ServicesBloc>()
                                  .add(LoadMoreServicesEvent()),
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/icons/Vector.png",
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.loadingMore
                                    ? "Cargando..."
                                    : "Cargar más servicios",
                                style:
                                    const TextStyle(color: Color(0xFFB20000)),
                              ),
                            ],
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Ya están todos los servicios",
                            style: TextStyle(
                              color: Color(0xFFB20000),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "services_fab",
        onPressed: _scrollToTop,
        backgroundColor: const Color(0xFFB20000),
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }
}