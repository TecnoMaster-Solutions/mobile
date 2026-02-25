import 'dart:convert';
import 'dart:io';

import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/data/constants/api_constants.dart';
import 'package:vertecx/data/models/products/product_model.dart';

class ProductsService {
  Future<List<ProductModel>> getProducts({
    String status = 'all',
    String? token,
  }) async {
    final uri = Uri.parse('$kBackendBaseUrl/products')
        .replace(queryParameters: {'status': status});

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

      if (decoded is! List) {
        throw Exception(
          'Respuesta inválida del backend (se esperaba lista).',
        );
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
    } on SocketException {
      throw Exception('Sin conexión. Verifica red/IP del backend.');
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}