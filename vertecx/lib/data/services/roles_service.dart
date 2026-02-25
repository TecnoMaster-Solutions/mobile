import 'dart:convert';
import 'dart:io';

import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/data/constants/api_constants.dart';
import 'package:vertecx/data/models/roles/role_model.dart';

class RolesService {
  Future<List<RoleModel>> getRoles({String? token}) async {
    final uri = Uri.parse('$kBackendBaseUrl/roles/list');
    final effectiveToken = token ?? SessionContext.accessToken;

    try {
      final response = await ApiHttp.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (effectiveToken != null && effectiveToken.isNotEmpty)
            'Authorization': 'Bearer $effectiveToken',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Error al obtener roles: ${response.statusCode}. Body: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);
      final data = (decoded is Map<String, dynamic>) ? decoded['data'] : null;
      if (data is! List) return [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(RoleModel.fromJson)
          .toList();
    } on SocketException {
      throw Exception('Sin conexión. Verifica red/IP del backend.');
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}