import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:vertecx/data/models/orderServices/order_service_models.dart';
import 'package:vertecx/data/repositories/orderServices/order_repository.dart';

enum OrderSortOrder { newestFirst, oldestFirst }

class OrderServiceController extends ChangeNotifier {
  OrderServiceController(this._repo);

  final OrderRepository _repo;

  List<OrderService> _all = [];
  List<OrderService> _visible = [];
  String _query = '';
  OrderSortOrder _sortOrder = OrderSortOrder.newestFirst;
  bool _loading = false;
  String? _error;

  List<OrderService> get orders => _visible;
  OrderSortOrder get sortOrder => _sortOrder;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _all = await _repo.getAll();
      _applyFilter();
    } catch (e) {
      _visible = [];
      _error = e.toString();
      notifyListeners();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void search(String q) {
    _query = q;
    _applyFilter();
  }

  void setSortOrder(OrderSortOrder order) {
    if (_sortOrder == order) return;
    _sortOrder = order;
    _applyFilter();
  }

  String _statusText(OrderServiceStatus s) {
    switch (s) {
      case OrderServiceStatus.pendiente:
        return 'pendiente';
      case OrderServiceStatus.enProgreso:
        return 'en progreso';
      case OrderServiceStatus.completada:
        return 'completada';
      case OrderServiceStatus.anulada:
        return 'anulada';
    }
  }

  String _norm(String v) {
    final lower = v.toLowerCase();
    return lower
        .replaceAll(RegExp('[áàä]'), 'a')
        .replaceAll(RegExp('[éèë]'), 'e')
        .replaceAll(RegExp('[íìï]'), 'i')
        .replaceAll(RegExp('[óòö]'), 'o')
        .replaceAll(RegExp('[úùü]'), 'u')
        .replaceAll('ñ', 'n');
  }

  void _applyFilter() {
    if (_query.trim().isEmpty) {
      _visible = List.of(_all);
    } else {
      final q = _norm(_query.trim());
      final tokens = q
          .split(RegExp(r'\s+'))
          .where((t) => t.isNotEmpty)
          .toList();

      final f1 = DateFormat('dd/MM/yyyy');
      final f2 = DateFormat('yyyy-MM-dd');

      _visible = _all.where((o) {
        final bag = StringBuffer()
          ..write(o.titulo)
          ..write(' ')
          ..write(o.tecnico)
          ..write(' ')
          ..write(o.cliente)
          ..write(' ')
          ..write('id:${o.id}')
          ..write(' ')
          ..write(_statusText(o.estado))
          ..write(' ')
          ..write(f1.format(o.fechaCreacion))
          ..write(' ')
          ..write(f2.format(o.fechaCreacion))
          ..write(' ')
          ..write(o.fechaCreacion.toIso8601String())
          ..write(' ')
          ..write(o.estadoLabel.toLowerCase())
          ..write(' ')
          ..write(o.techniciansLabel.toLowerCase());

        final haystack = _norm(bag.toString());
        return tokens.every((t) => haystack.contains(t));
      }).toList();
    }
    _visible.sort((a, b) {
      if (_sortOrder == OrderSortOrder.newestFirst) {
        final byDate = b.fechaCreacion.compareTo(a.fechaCreacion);
        if (byDate != 0) return byDate;
        return b.id.compareTo(a.id);
      }
      final byDate = a.fechaCreacion.compareTo(b.fechaCreacion);
      if (byDate != 0) return byDate;
      return a.id.compareTo(b.id);
    });
    notifyListeners();
  }
}
