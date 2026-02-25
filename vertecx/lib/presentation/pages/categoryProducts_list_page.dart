import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/data/models/categoryProducts/categoryProducts_model.dart';
import 'package:vertecx/presentation/widgets/categoryProductsWidgets/categoryProduct_card_widget.dart';
import 'package:vertecx/presentation/widgets/components/search/search.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/data/services/category_products_service.dart';
import 'package:vertecx/data/repositories/categoryProductRepositories/bloc/category_product_bloc.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/side_menu_panel.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';

class CategoryProductListPage extends StatefulWidget {
  const CategoryProductListPage({super.key});

  @override
  State<CategoryProductListPage> createState() =>
      _CategoryProductListPageState();
}

class _CategoryProductListPageState extends State<CategoryProductListPage> {
  int _categoriesToShow = 4;
  String _searchQuery = "";
  final ScrollController _scrollController = ScrollController();
  List<String> _permissions = const <String>[];

  void _loadMoreCategories(int totalCategories) {
    setState(() {
      _categoriesToShow = (_categoriesToShow + 2).clamp(0, totalCategories);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_permissions.isEmpty) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is List<String>) {
        _permissions = args;
        SessionContext.permissions = args;
      } else {
        _permissions = SessionContext.permissions;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CategoryProductBloc(CategoryProductsService())..add(LoadCategories()),
      child: Scaffold(
        appBar: const AppTopBar(title: 'Categorías de productos', showMenu: true),
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
        body: BlocBuilder<CategoryProductBloc, CategoryProductState>(
          builder: (context, state) {
            if (state is CategoryProductLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CategoryProductError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (state is CategoryProductLoaded) {
              final filteredCategories = state.categories
                  .where((c) => c.matchesQuery(_searchQuery))
                  .toList();

              final categories = filteredCategories
                  .take(_categoriesToShow)
                  .toList();
              final allCategoriesLoaded =
                  _categoriesToShow >= filteredCategories.length;

              return SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Buscar(
                        hintText: "Buscar categorí­a...",
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                      ),
                      const SizedBox(height: 20),
                      ...categories.map(
                        (category) => CategoryCard(
                          category: category,
                          onToggleStatus: () {
                            context.read<CategoryProductBloc>().add(
                              ToggleCategoryStatus(category.id),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // BotÃ³n para cargar mÃ¡s
                      if (filteredCategories.isNotEmpty)
                        if (!allCategoriesLoaded)
                          TextButton(
                            onPressed: () =>
                                _loadMoreCategories(filteredCategories.length),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/icons/Vector.png",
                                  width: 20,
                                  height: 20,
                                ),
                                const Text(
                                  "Cargar más Categorí­as de productos",
                                  style: TextStyle(color: Color(0xFFB20000)),
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Ya están todas las categorí­as de productos",
                              style: TextStyle(
                                color: Color(0xFFB20000),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            "No se encontraron categorías de productos",
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
              );
            }

            // Estado inicial vacÃ­o
            return const Center(child: CircularProgressIndicator());
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _scrollToTop,
          backgroundColor: const Color(0xFFB20000),
          child: const Icon(Icons.arrow_upward, color: Colors.white),
        ),
      ),
    );
  }
}
