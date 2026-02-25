import 'dart:convert';

import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/data/constants/api_constants.dart';
import 'package:vertecx/data/models/suppliers/supplier_model.dart';

class SuppliersService {
  String get _baseUrl => kBackendBaseUrl;

  Future<List<SupplierModel>> getSuppliers() async {
    final url = Uri.parse('$_baseUrl/suppliers');
    final response = await ApiHttp.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener proveedores: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final payload = decoded is List
        ? decoded
        : (decoded is Map<String, dynamic> ? (decoded['data'] ?? []) : []);

    if (payload is! List) return const <SupplierModel>[];

    return payload
        .whereType<Map<String, dynamic>>()
        .map(SupplierModel.fromJson)
        .toList();
  }

  Future<SupplierModel> updateSupplierState(int supplierId, int stateId) async {
    final url = Uri.parse('$_baseUrl/suppliers/$supplierId');
    final response = await ApiHttp.patch(
      url,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'stateid': stateId}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al actualizar proveedor: ${response.statusCode} - ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    final data = decoded is Map<String, dynamic>
        ? (decoded['data'] ?? decoded)
        : decoded;

    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta invalida al actualizar proveedor');
    }

    return SupplierModel.fromJson(data);
  }
}
