import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/data/constants/api_constants.dart';

class OrderServicesService {
  final String baseUrl;

  OrderServicesService({String? baseUrl, http.Client? client})
    : baseUrl = baseUrl ?? kBackendBaseUrl;

  Uri _buildUri([Map<String, dynamic>? query]) {
    final uri = Uri.parse('$baseUrl/orders-services');
    if (query == null || query.isEmpty) {
      return uri;
    }
    return uri.replace(
      queryParameters: query.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getOrders({
    Map<String, dynamic>? query,
  }) async {
    final uri = _buildUri(query);
    final response = await ApiHttp.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error al cargar las órdenes de servicio');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>> getOrderById(int id) async {
    final uri = Uri.parse('$baseUrl/orders-services/$id');
    final response = await ApiHttp.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error al cargar la orden de servicio');
    }
    final data = jsonDecode(response.body);
    return data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getOrderHistory(int id) async {
    final uri = Uri.parse('$baseUrl/orders-services/$id/history');
    final response = await ApiHttp.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error al cargar el historial de la orden de servicio');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.whereType<Map<String, dynamic>>().toList();
  }
}
