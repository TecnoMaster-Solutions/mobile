import '../../models/dashboard/dashboard_models.dart';
import '../../services/dashboard_service.dart';

class SalesRepository {
  SalesRepository({DashboardService? service})
      : service = service ?? DashboardService();

  final DashboardService service;

  Future<List<Sales>> fetchSales({int? year}) async {
    final data = await service.fetchSalesByYear(year);
    return _mapSalesData(data);
  }

  Future<List<double>> fetchDailySales(int month, {int? year}) async {
    final data = await service.fetchDailySales(month, year);
    return _mapDailyTotals(data);
  }
}

class ClientsRepository {
  ClientsRepository({DashboardService? service})
      : service = service ?? DashboardService();

  final DashboardService service;

  Future<List<Clients>> fetchClients({int? year}) async {
    final data = await service.fetchClientsByYear(year);
    return _mapClientsData(data);
  }

  Future<List<double>> fetchDailyClients(int month, {int? year}) async {
    final data = await service.fetchDailyClients(month, year);
    return _mapDailyTotals(data);
  }
}

class PurchasesRepository {
  PurchasesRepository({DashboardService? service})
      : service = service ?? DashboardService();

  final DashboardService service;

  Future<List<Sales>> fetchPurchases({int? year}) async {
    final data = await service.fetchPurchasesByYear(year);
    return _mapSalesData(data);
  }

  Future<List<double>> fetchDailyPurchases(int month, {int? year}) async {
    final data = await service.fetchDailyPurchases(month, year);
    return _mapDailyTotals(data);
  }
}

class AppointmentsRepository {
  AppointmentsRepository({DashboardService? service})
      : service = service ?? DashboardService();

  final DashboardService service;

  Future<Map<String, int>> fetchAppointmentsStats({int? year}) async {
    final stateData = await service.fetchServiceRequestsByState(year);
    final counts = _mapStatesAsIs(stateData);
    return _ensureStateTotals(counts, await service.fetchTotalServiceRequests(year));
  }
}

class OrdersRepository {
  OrdersRepository({DashboardService? service})
      : service = service ?? DashboardService();

  final DashboardService service;

  Future<Map<String, int>> fetchOrdersStats({int? year}) async {
    final data = await service.fetchOrdersByState(year);
    return _ensureStateTotals(_mapStatesAsIs(data), await service.fetchTotalOrders(year));
  }
}

class ProductsRepository {
  ProductsRepository({DashboardService? service})
      : service = service ?? DashboardService();

  final DashboardService service;

  Future<Map<String, double>> fetchProductsByCategory({int? year}) async {
    final data = await service.fetchProductsByCategory(year);
    return _mapCategoryTotals(data);
  }
}

List<Sales> _mapSalesData(List<dynamic> data) {
  final result = <Sales>[];

  for (final item in data) {
    if (item is Map<String, dynamic>) {
      result.add(Sales.fromJson(item));
    }
  }

  result.sort((a, b) => a.month.compareTo(b.month));

  if (result.isEmpty) {
    return [Sales(month: 1, amount: 0)];
  }

  return result;
}

List<Clients> _mapClientsData(List<dynamic> data) {
  final result = <Clients>[];

  for (final item in data) {
    if (item is Map<String, dynamic>) {
      result.add(Clients.fromJson(item));
    }
  }

  result.sort((a, b) => a.month.compareTo(b.month));

  if (result.isEmpty) {
    return [Clients(month: 1, amount: 0)];
  }

  return result;
}

List<double> _mapDailyTotals(List<dynamic> data) {
  var maxDay = 0;
  final totals = <int, double>{};

  for (final item in data) {
    if (item is! Map<String, dynamic>) continue;

    final day = parseDashboardInt(item['day']);
    final total = parseDashboardDouble(
      item['total'] ?? item['value'] ?? item['amount'],
    );

    if (day > 0) {
      if (day > maxDay) maxDay = day;
      totals[day] = total;
    }
  }

  if (maxDay == 0) return [0];

  return List<double>.generate(
    maxDay,
    (index) => totals[index + 1] ?? 0.0,
  );
}

Map<String, double> _mapCategoryTotals(List<dynamic> data) {
  final categories = <String, double>{};

  for (final item in data) {
    if (item is! Map<String, dynamic>) continue;

    final name = (item['category'] ?? item['name'] ?? '').toString().trim();
    final value = parseDashboardDouble(
      item['value'] ?? item['total'] ?? item['count'],
    );

    if (name.isNotEmpty) {
      categories[name] = value;
    }
  }

  if (categories.isEmpty) {
    categories['Sin datos'] = 1;
  }

  return categories;
}

Map<String, int> _mapStateCounts(List<dynamic> data) {
  final counts = <String, int>{};

  for (final item in data) {
    if (item is! Map<String, dynamic>) continue;

    final rawState = (item['state'] ?? item['status'] ?? '').toString().trim();
    if (rawState.isEmpty) continue;

    final stateLabel = _translateDashboardState(rawState);
    final value = parseDashboardInt(item['value'] ?? item['total'] ?? item['count']);
    counts[stateLabel] = (counts[stateLabel] ?? 0) + value;
  }

  return counts;
}

Map<String, int> _mapStatesAsIs(List<dynamic> data) => _mapStateCounts(data);

Map<String, int> _ensureStateTotals(
  Map<String, int> counts,
  Map<String, dynamic> totalResponse,
) {
  final totalFromEndpoint = parseDashboardInt(
    totalResponse['total'] ?? totalResponse['count'],
  );

  if (counts.isEmpty && totalFromEndpoint > 0) {
    return {'Total': totalFromEndpoint};
  }

  final sum = counts.values.fold<int>(0, (a, b) => a + b);
  if (sum == 0 && totalFromEndpoint > 0) {
    return {'Total': totalFromEndpoint};
  }

  return counts;
}

String _normalizeState(String value) {
  var normalized = value.toLowerCase().trim();
  const replacements = {
    '\u00e1': 'a',
    '\u00e0': 'a',
    '\u00e4': 'a',
    '\u00e2': 'a',
    '\u00e9': 'e',
    '\u00e8': 'e',
    '\u00eb': 'e',
    '\u00ea': 'e',
    '\u00ed': 'i',
    '\u00ec': 'i',
    '\u00ef': 'i',
    '\u00ee': 'i',
    '\u00f3': 'o',
    '\u00f2': 'o',
    '\u00f6': 'o',
    '\u00f4': 'o',
    '\u00fa': 'u',
    '\u00f9': 'u',
    '\u00fc': 'u',
    '\u00fb': 'u',
    '\u00f1': 'n',
  };

  replacements.forEach((key, value) {
    normalized = normalized.replaceAll(key, value);
  });

  return normalized;
}

String _translateDashboardState(String value) {
  final normalized = _normalizeState(value).replaceAll('-', ' ');
  switch (normalized) {
    case 'cancel':
    case 'canceled':
    case 'cancelled':
    case 'cancelado':
      return 'Cancelados';
    case 'finished':
    case 'finalizado':
      return 'Finalizados';
    case 'in process':
    case 'inprocess':
    case 'en proceso':
    case 'enproceso':
      return 'En proceso';
    case 'pendient':
    case 'pending':
    case 'pendiente':
      return 'Pendientes';
    case 'agendada':
    case 'agendado':
      return 'Agendada';
    default:
      return value;
  }
}
