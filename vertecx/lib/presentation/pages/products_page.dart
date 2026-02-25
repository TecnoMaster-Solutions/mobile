import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/side_menu_panel.dart';
import 'package:vertecx/presentation/widgets/components/search/search.dart';
import 'package:vertecx/presentation/widgets/productsWidgets/product_card_widget.dart';

import 'package:vertecx/data/repositories/products/bloc/products_bloc.dart';
import 'package:vertecx/data/repositories/products/bloc/products_event.dart';
import 'package:vertecx/data/repositories/products/bloc/products_state.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ScrollController _scrollController = ScrollController();
  int _productsToShow = 4;
  String _searchQuery = "";

  List<String> _permissions = const <String>[];

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(LoadProductsEvent());
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

  void _loadMoreProducts(int max) {
    setState(() {
      _productsToShow = (_productsToShow + 2).clamp(0, max);
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  String _normalize(String s) {
    var v = s.toLowerCase().trim();

    const from = ['á', 'é', 'í', 'ó', 'ú', 'ü', 'ñ'];
    const to = ['a', 'e', 'i', 'o', 'u', 'u', 'n'];

    for (var i = 0; i < from.length; i++) {
      v = v.replaceAll(from[i], to[i]);
    }

    v = v.replaceAll(RegExp(r'\s+'), ' ');
    return v;
  }

  bool _matchesSearch(dynamic p) {
    final q = _normalize(_searchQuery);
    if (q.isEmpty) return true;

    final name = _normalize(p.name ?? '');
    final desc = _normalize(p.description ?? '');
    final cat = _normalize(p.category ?? '');
    final supCat = _normalize(p.supplierCategory ?? '');
    final code = _normalize(p.code ?? '');
    final status = _normalize(p.statusString ?? '');

    return name.contains(q) ||
        desc.contains(q) ||
        cat.contains(q) ||
        supCat.contains(q) ||
        code.contains(q) ||
        status.contains(q);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Productos', showMenu: true),
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
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          if (state is ProductsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductsError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state is ProductsLoaded) {
            final filtered = state.products.where(_matchesSearch).toList();
            final page = filtered.take(_productsToShow).toList();
            final allLoaded = _productsToShow >= filtered.length;

            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  Buscar(
                    hintText: "Buscar producto...",
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: 20),
                  if (page.isNotEmpty)
                    ...page.map((p) => ProductCardWidget(product: p))
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No se encontraron productos",
                        style: TextStyle(
                          color: Color(0xFFB20000),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (filtered.isNotEmpty)
                    if (!allLoaded)
                      TextButton(
                        onPressed: () => _loadMoreProducts(filtered.length),
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/icons/Vector.png",
                              width: 20,
                              height: 20,
                            ),
                            const Text(
                              "Cargar más productos",
                              style: TextStyle(color: Color(0xFFB20000)),
                            ),
                          ],
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Ya están todos los productos",
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
        heroTag: "products_fab",
        onPressed: _scrollToTop,
        backgroundColor: const Color(0xFFB20000),
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }
}