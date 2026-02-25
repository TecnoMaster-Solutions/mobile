import 'dart:convert';
import 'dart:io';

import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/data/constants/api_constants.dart';
import 'package:vertecx/data/models/technicians/technician_model.dart';

class TechniciansService {
  Future<List<TechnicianModel>> getTechnicians({String? token}) async {
    final uri = Uri.parse('$kBackendBaseUrl/technicians');
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
          'Error al obtener técnicos: '
          '${response.statusCode}. Body: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        list = decoded['data'] as List;
      } else {
        list = const [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map(TechnicianModel.fromJson)
          .toList();
    } on SocketException {
      throw Exception('Sin conexión. Verifica red/IP del backend.');
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}