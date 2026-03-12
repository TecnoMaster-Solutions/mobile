import 'dart:convert';
import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/data/constants/api_constants.dart';
import '../models/sales/sale_model.dart';

class SalesService {
  String get _baseUrl => kBackendBaseUrl;

  Future<List<SaleModel>> getSales() async {
    final url = Uri.parse('$_baseUrl/sales');
    final response = await ApiHttp.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List<dynamic> payload = jsonData is List
          ? jsonData
          : (jsonData is Map<String, dynamic>
              ? List<dynamic>.from(jsonData['data'] ?? [])
              : []);

      return payload
          .map((e) => SaleModel.fromJson(e))
          .toList();
    }

    throw Exception(
      'Error al obtener ventas: ${response.statusCode}',
    );
  }
}
