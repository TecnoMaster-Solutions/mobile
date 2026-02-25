import 'dart:convert';
import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/data/constants/api_constants.dart';

class DashboardService {
  DashboardService({String? baseUrl})
      : baseUrl = baseUrl ?? kBackendBaseUrl;

  final String baseUrl;
  String get _dashboardBase => '$baseUrl/dashboard';

  Uri _uri(String path, [int? year]) {
    final parsed = Uri.parse(path);
    if (year == null) return parsed;
    return parsed.replace(
      queryParameters: {...parsed.queryParameters, 'year': '$year'},
    );
  }

  Future<List<dynamic>> fetchSalesByYear([int? year]) =>
      _getList(_uri('$_dashboardBase/sales/year', year));
  Future<Map<String, dynamic>> fetchTotalSales([int? year]) =>
      _getMap(_uri('$_dashboardBase/sales/total', year));
  Future<List<dynamic>> fetchDailySales(int month, [int? year]) =>
      _getList(_uri('$_dashboardBase/sales/month/$month', year));

  Future<List<dynamic>> fetchPurchasesByYear([int? year]) =>
      _getList(_uri('$_dashboardBase/purchases/year', year));
  Future<Map<String, dynamic>> fetchTotalPurchases([int? year]) =>
      _getMap(_uri('$_dashboardBase/purchases/total', year));
  Future<List<dynamic>> fetchDailyPurchases(int month, [int? year]) =>
      _getList(_uri('$_dashboardBase/purchases/month/$month', year));

  Future<List<dynamic>> fetchClientsByYear([int? year]) =>
      _getList(_uri('$_dashboardBase/clients/year', year));
  Future<Map<String, dynamic>> fetchTotalClients([int? year]) =>
      _getMap(_uri('$_dashboardBase/clients/total', year));
  Future<List<dynamic>> fetchDailyClients(int month, [int? year]) =>
      _getList(_uri('$_dashboardBase/clients/month/$month', year));

  Future<List<dynamic>> fetchProductsByCategory([int? year]) =>
      _getList(_uri('$_dashboardBase/categories/products', year));

  Future<List<dynamic>> fetchOrdersByState([int? year]) =>
      _getList(_uri('$_dashboardBase/orders/state', year));
  Future<Map<String, dynamic>> fetchTotalOrders([int? year]) =>
      _getMap(_uri('$_dashboardBase/orders/total', year));

  Future<List<dynamic>> fetchServiceRequestsByState([int? year]) =>
      _getList(_uri('$_dashboardBase/service-requests/state', year));
  Future<Map<String, dynamic>> fetchTotalServiceRequests([int? year]) =>
      _getMap(_uri('$_dashboardBase/service-requests/total', year));

  Future<dynamic> _get(Uri uri) async {
    // Loggeamos siempre para validar el año que se envía
    // ignore: avoid_print
    print('GET $uri');

    final response = await ApiHttp.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Error ${response.statusCode} al consultar ${uri.path}: ${response.body}',
    );
  }

  Future<List<dynamic>> _getList(Uri uri) async {
    final decoded = await _get(uri);

    if (decoded is Map<String, dynamic> && decoded['data'] is List) {
      return List<dynamic>.from(decoded['data'] as List);
    }
    if (decoded is List) {
      return List<dynamic>.from(decoded);
    }

    throw Exception('Formato inesperado de respuesta en $uri');
  }

  Future<Map<String, dynamic>> _getMap(Uri uri) async {
    final decoded = await _get(uri);

    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded['data'] as Map);
      }
      return Map<String, dynamic>.from(decoded);
    }

    throw Exception('Formato inesperado de respuesta en $uri');
  }
}
