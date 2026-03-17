import 'dart:convert';
import 'dart:io';

import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/data/constants/api_constants.dart';
import 'package:vertecx/data/models/products/products_paginated_response.dart';

class ProductsService {
  Future<ProductsPaginatedResponse> getProducts({
    String status = 'all',
    String? token,
    int page = 1,
    int limit = 50,
    String? search,
    int? categoryId,
  }) async {
    final queryParams = <String, String>{
      'status': status,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    if (categoryId != null) {
      queryParams['categoryid'] = categoryId.toString();
    }

    final uri = Uri.parse('$kBackendBaseUrl/products')
        .replace(queryParameters: queryParams);

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
          'Error al obtener productos: ${response.statusCode}. Body: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Respuesta inválida del backend (se esperaba objeto con data y meta).',
        );
      }

      return ProductsPaginatedResponse.fromJson(decoded);
    } on SocketException {
      throw Exception('Sin conexión. Verifica red/IP del backend.');
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}