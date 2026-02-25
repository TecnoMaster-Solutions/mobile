import 'dart:async';
import 'dart:convert';
import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/core/api_config.dart';
import 'package:vertecx/data/models/request/request_model.dart';

class ServiceRequestsService {
  final String baseUrl;

  const ServiceRequestsService({String? baseUrl})
    : baseUrl = baseUrl ?? ApiConfig.baseUrl;

  Uri _uri(String path, [Map<String, dynamic>? q]) {
    final uri = Uri.parse('$baseUrl$path');
    if (q == null) {
      return uri;
    }
    return uri.replace(
      queryParameters: q.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  Future<List<ServiceRequestModel>> getRequests({
    int page = 1,
    int limit = 50,
  }) async {
    final url = _uri('/service-requests', {'page': page, 'limit': limit});
    try {
      final res = await ApiHttp.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        throw Exception('GET ${url.path}: ${res.statusCode} - ${res.body}');
      }

      final dynamic body = jsonDecode(res.body);

      final List<dynamic> data = body is Map<String, dynamic>
          ? (body['data'] is List ? body['data'] as List<dynamic> : const [])
          : (body is List ? body : const []);

      return data
          .whereType<Map<String, dynamic>>()
          .map(ServiceRequestModel.fromJson)
          .toList();
    } on TimeoutException {
      throw Exception('GET ${url.path}: timeout');
    } catch (_) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRequestById(int id) async {
    final url = _uri('/service-requests/$id');
    try {
      final res = await ApiHttp.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        throw Exception('GET ${url.path}: ${res.statusCode} - ${res.body}');
      }

      final dynamic body = jsonDecode(res.body);
      if (body is Map<String, dynamic>) {
        return body;
      }

      throw Exception('GET ${url.path}: respuesta inesperada');
    } on TimeoutException {
      throw Exception('GET ${url.path}: timeout');
    } catch (_) {
      rethrow;
    }
  }
}
