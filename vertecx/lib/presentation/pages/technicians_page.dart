import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';
import 'package:vertecx/presentation/widgets/components/search/search.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/side_menu_panel.dart';
import 'package:vertecx/presentation/widgets/techniciansWidgets/technicians_card_widget.dart';

import 'package:vertecx/data/repositories/technicians/bloc/technicians_bloc.dart';
import 'package:vertecx/data/repositories/technicians/bloc/technicians_event.dart';
import 'package:vertecx/data/repositories/technicians/bloc/technicians_state.dart';

class TechniciansPage extends StatefulWidget {
  const TechniciansPage({super.key});

  @override
  State<TechniciansPage> createState() => _TechniciansPageState();
}

class _TechniciansPageState extends State<TechniciansPage> {
  final ScrollController _scrollController = ScrollController();
  int _techniciansToShow = 4;
  String _searchQuery = "";

  List<String> _permissions = const <String>[];

  @override
  void initState() {
    super.initState();
    context.read<TechniciansBloc>().add(LoadTechniciansEvent());
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

  void _loadMoreTechnicians() {
    final state = context.read<TechniciansBloc>().state;
    if (state is TechniciansLoaded) {
      setState(() {
        _techniciansToShow =
            (_techniciansToShow + 2).clamp(0, state.technicians.length);
      });
    }
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
      appBar: const AppTopBar(title: 'Técnicos', showMenu: true),
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
      body: BlocBuilder<TechniciansBloc, TechniciansState>(
        builder: (context, state) {
          if (state is TechniciansLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TechniciansError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is TechniciansLoaded) {
            final list = state.technicians;

            final filtered = list
                .where((t) => t.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                .toList();

            final page = filtered.take(_techniciansToShow).toList();
            final allLoaded = _techniciansToShow >= filtered.length;

            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: Column(
                children: [
                  Buscar(
                    hintText: "Buscar técnico...",
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                  const SizedBox(height: 20),

                  if (page.isNotEmpty)
                    ...page.map((t) => TechnicianCardWidget(technician: t))
                  else
                    const Text(
                      "No se encontraron técnicos",
                      style: TextStyle(
                        color: Color(0xFFB20000),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  const SizedBox(height: 20),

                  if (filtered.isNotEmpty)
                    !allLoaded
                        ? TextButton(
                            onPressed: _loadMoreTechnicians,
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/icons/Vector.png",
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Cargar más técnicos",
                                  style: TextStyle(color: Color(0xFFB20000)),
                                ),
                              ],
                            ),
                          )
                        : const Text(
                            "Ya están todos los técnicos",
                            style: TextStyle(
                              color: Color(0xFFB20000),
                              fontWeight: FontWeight.bold,
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
        heroTag: "technicians_fab",
        onPressed: _scrollToTop,
        backgroundColor: const Color(0xFFB20000),
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }
}