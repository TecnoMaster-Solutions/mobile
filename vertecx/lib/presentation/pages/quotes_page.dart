import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/data/models/quotes/quote_model.dart';
import 'package:vertecx/data/repositories/quotes/quotes_repository.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/side_menu_panel.dart';
import 'package:vertecx/presentation/widgets/quotesWidgets/quote_card_widget.dart';

const _brandGreen = Color(0xFF06A646);
const _brandGreenDark = Color(0xFF058A3C);
const _brandGreenDeep = Color(0xFF04652C);
const _pageBackground = Color(0xFFF4F7F5);
const _inputBorder = Color(0xFFD7E2DA);

enum QuotesSortOrder { newestFirst, oldestFirst }

class QuotesController extends ChangeNotifier {
  QuotesController(this._repository);

  final QuotesRepository _repository;

  List<QuoteModel> _all = const <QuoteModel>[];
  String _query = '';
  QuotesSortOrder _sortOrder = QuotesSortOrder.newestFirst;
  bool _loading = false;
  String? _error;

  List<QuoteModel> get items {
    final String q = _query.trim().toLowerCase();
    final List<QuoteModel> filtered = _all.where((quote) {
      if (q.isEmpty) return true;
      final String haystack = [
        quote.id.toString(),
        quote.serviceType,
        quote.customerName,
        quote.technicianName,
        quote.status,
        quote.observation,
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();

    filtered.sort((a, b) {
      final DateTime da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return _sortOrder == QuotesSortOrder.newestFirst
          ? db.compareTo(da)
          : da.compareTo(db);
    });

    return filtered;
  }

  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;
  QuotesSortOrder get sortOrder => _sortOrder;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _all = await _repository.fetchQuotes();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load();

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setSortOrder(QuotesSortOrder value) {
    _sortOrder = value;
    notifyListeners();
  }
}

class QuotesPage extends StatelessWidget {
  const QuotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuotesController(QuotesRepository())..load(),
      child: const _QuotesScaffold(),
    );
  }
}

class _QuotesScaffold extends StatelessWidget {
  const _QuotesScaffold();

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    final List<String> permissions = args is List<String>
        ? args
        : args is Map<String, dynamic> && args['permissions'] is List
            ? (args['permissions'] as List).map((e) => e.toString()).toList()
            : SessionContext.permissions;

    void logout() {
      SessionContext.clearAll();
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }

    return Scaffold(
      backgroundColor: _pageBackground,
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: SideMenuPanel(
          permissions: permissions,
          onClose: () => Navigator.of(context).maybePop(),
          onLogout: () {
            Navigator.of(context).maybePop();
            logout();
          },
        ),
      ),
      appBar: const AppTopBar(
        title: 'Cotizaciones',
        centerTitle: true,
        showMenu: true,
      ),
      body: Consumer<QuotesController>(
        builder: (context, controller, _) {
          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              children: [
                Container(
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
                          onChanged: controller.setQuery,
                          decoration: const InputDecoration(
                            hintText: 'Buscar cotizaciones...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Mas recientes'),
                      selected:
                          controller.sortOrder == QuotesSortOrder.newestFirst,
                      onSelected: (_) => controller.setSortOrder(
                        QuotesSortOrder.newestFirst,
                      ),
                      selectedColor: _brandGreen.withOpacity(0.14),
                      labelStyle: TextStyle(
                        color:
                            controller.sortOrder == QuotesSortOrder.newestFirst
                                ? _brandGreenDeep
                                : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color:
                            controller.sortOrder == QuotesSortOrder.newestFirst
                                ? _brandGreen
                                : _inputBorder,
                      ),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Mas antiguas'),
                      selected:
                          controller.sortOrder == QuotesSortOrder.oldestFirst,
                      onSelected: (_) => controller.setSortOrder(
                        QuotesSortOrder.oldestFirst,
                      ),
                      selectedColor: _brandGreen.withOpacity(0.14),
                      labelStyle: TextStyle(
                        color:
                            controller.sortOrder == QuotesSortOrder.oldestFirst
                                ? _brandGreenDeep
                                : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color:
                            controller.sortOrder == QuotesSortOrder.oldestFirst
                                ? _brandGreen
                                : _inputBorder,
                      ),
                      backgroundColor: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (controller.loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Text(
                        controller.error!,
                        style: const TextStyle(color: Color(0xFFB42318)),
                      ),
                    ),
                  )
                else if (controller.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Text(
                        'No hay cotizaciones',
                        style: TextStyle(
                          color: _brandGreenDeep,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  ...controller.items.map(
                    (quote) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: QuoteCardWidget(quote: quote),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'quotes_refresh_fab',
        onPressed: () => context.read<QuotesController>().refresh(),
        backgroundColor: _brandGreenDark,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
