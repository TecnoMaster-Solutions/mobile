import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vertecx/data/repositories/request/bloc/requests_bloc.dart';
import 'package:vertecx/data/repositories/request/bloc/requests_event.dart';
import 'package:vertecx/data/repositories/request/bloc/requests_state.dart';
import 'package:vertecx/data/repositories/request/request_repository.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';
import 'package:vertecx/presentation/widgets/requestWidgets/request_card.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/side_menu_panel.dart';

const _brandGreen = Color(0xFF06A646);
const _brandGreenDark = Color(0xFF058A3C);
const _brandGreenDeep = Color(0xFF04652C);
const _pageBackground = Color(0xFFF4F7F5);
const _inputBorder = Color(0xFFD7E2DA);

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RequestsBloc>(
      create: (_) =>
          RequestsBloc(RequestsRepository())
            ..add(const RequestsLoadRequested()),
      child: const _RequestsScaffold(),
    );
  }
}

class _RequestsScaffold extends StatefulWidget {
  const _RequestsScaffold();

  @override
  State<_RequestsScaffold> createState() => _RequestsScaffoldState();
}

class _RequestsScaffoldState extends State<_RequestsScaffold> {
  final ScrollController _scrollController = ScrollController();
  List<String> _permissions = const <String>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is List<String>) {
      _permissions = args;
      SessionContext.permissions = args;
      return;
    }
    if (args is Map<String, dynamic>) {
      final raw = args['permissions'];
      if (raw is List) {
        final perms = raw.map((e) => e.toString()).toList();
        _permissions = perms;
        SessionContext.permissions = perms;
        return;
      }
    }
    _permissions = SessionContext.permissions;
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: SideMenuPanel(
          permissions: _permissions,
          onClose: () => Navigator.of(context).maybePop(),
          onLogout: () {
            Navigator.of(context).maybePop();
            SessionContext.clearAll();
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
          },
        ),
      ),
      appBar: const AppTopBar(
        title: 'Solicitudes',
        centerTitle: true,
        showBack: false,
        showMenu: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: _SearchBox(),
          ),
          BlocBuilder<RequestsBloc, RequestsState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Mas recientes'),
                      selected: state.sortOrder == RequestsSortOrder.newestFirst,
                      onSelected: (_) => context.read<RequestsBloc>().add(
                        const RequestsSortChanged(
                          RequestsSortOrder.newestFirst,
                        ),
                      ),
                      selectedColor: _brandGreen.withOpacity(0.14),
                      labelStyle: TextStyle(
                        color: state.sortOrder == RequestsSortOrder.newestFirst
                            ? _brandGreenDeep
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: state.sortOrder == RequestsSortOrder.newestFirst
                            ? _brandGreen
                            : _inputBorder,
                      ),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Mas antiguas'),
                      selected: state.sortOrder == RequestsSortOrder.oldestFirst,
                      onSelected: (_) => context.read<RequestsBloc>().add(
                        const RequestsSortChanged(
                          RequestsSortOrder.oldestFirst,
                        ),
                      ),
                      selectedColor: _brandGreen.withOpacity(0.14),
                      labelStyle: TextStyle(
                        color: state.sortOrder == RequestsSortOrder.oldestFirst
                            ? _brandGreenDeep
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: state.sortOrder == RequestsSortOrder.oldestFirst
                            ? _brandGreen
                            : _inputBorder,
                      ),
                      backgroundColor: Colors.white,
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(child: _RequestsList(controller: _scrollController)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'requests_scroll_top_fab',
        onPressed: _scrollToTop,
        backgroundColor: _brandGreenDark,
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }
}

class _RequestsList extends StatelessWidget {
  const _RequestsList({required this.controller});
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestsBloc, RequestsState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null) {
          return Center(
            child: Text(
              state.error!,
              style: const TextStyle(color: Color(0xFFB42318)),
            ),
          );
        }
        if (state.visible.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No hay solicitudes',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _brandGreenDeep,
                ),
              ),
            ),
          );
        }

        return ListView.separated(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
          itemCount: state.visible.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            if (i < state.visible.length) {
              return RequestCard(data: state.visible[i]);
            }

            if (state.hasMore) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: TextButton(
                    onPressed: state.loadingMore
                        ? null
                        : () => context.read<RequestsBloc>().add(
                            const RequestsLoadMorePressed(),
                          ),
                    child: state.loadingMore
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Cargar mas solicitudes',
                            style: TextStyle(color: _brandGreenDeep),
                          ),
                  ),
                ),
              );
            }

            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Ya estan todas las solicitudes',
                  style: TextStyle(
                    color: _brandGreenDeep,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SearchBox extends StatefulWidget {
  const _SearchBox();

  @override
  State<_SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<_SearchBox> {
  final c = TextEditingController();

  @override
  void initState() {
    super.initState();
    c.addListener(() {
      context.read<RequestsBloc>().add(RequestsSearchChanged(c.text));
    });
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _inputBorder),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x11000000),
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, size: 20, color: _brandGreenDeep),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: c,
              decoration: const InputDecoration(
                hintText: 'Buscar solicitudes...',
                border: InputBorder.none,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          BlocBuilder<RequestsBloc, RequestsState>(
            builder: (context, state) {
              if (state.query.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => c.clear(),
              );
            },
          ),
        ],
      ),
    );
  }
}

