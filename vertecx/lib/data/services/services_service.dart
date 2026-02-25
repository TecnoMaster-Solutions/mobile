import 'dart:convert';
import 'dart:io';

import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/data/constants/api_constants.dart';
import 'package:vertecx/data/models/services/service_model.dart';

class ServicesService {
  Future<ServicesPageResponse> getServices({
    int page = 1,
    int limit = 50,
    String? token,
  }) async {
    final qp = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final uri = Uri.parse('$kBackendBaseUrl/services').replace(queryParameters: qp);
    final effectiveToken = token ?? SessionContext.accessToken;

    try {
      final response = await ApiHttp.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (effectiveToken != null && effectiveToken.isNotEmpty)
            'Authorization': 'Bearer $effectiveToken',
        },
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        throw Exception(
          'Error al obtener servicios: ${response.statusCode}. Body: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Respuesta inválida del backend (se esperaba objeto).');
      }

      final rawData = decoded['data'];
      final rawMeta = decoded['meta'];

      final List<ServiceModel> services = (rawData is List)
          ? rawData
              .whereType<Map<String, dynamic>>()
              .map(ServiceModel.fromJson)
              .toList()
          : <ServiceModel>[];

      final meta = ServicesMeta.fromJson(
        rawMeta is Map<String, dynamic> ? rawMeta : <String, dynamic>{},
      );

      return ServicesPageResponse(data: services, meta: meta);
    } on SocketException {
      throw Exception('Sin conexión. Verifica red/IP del backend.');
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}

class ServicesMeta {
  final int page;
  final int limit;
  final int total;
  final int pages;

  ServicesMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  factory ServicesMeta.fromJson(Map<String, dynamic> json) {
    final page = _asInt(json['page']);
    final limit = _asInt(json['limit']);
    final pages = _asInt(json['pages']);

    return ServicesMeta(
      page: page == 0 ? 1 : page,
      limit: limit == 0 ? 50 : limit,
      total: _asInt(json['total']),
      pages: pages == 0 ? 1 : pages,
    );
  }
}

class ServicesPageResponse {
  final List<ServiceModel> data;
  final ServicesMeta meta;

  ServicesPageResponse({required this.data, required this.meta});
}