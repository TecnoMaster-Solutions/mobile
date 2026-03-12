import 'dart:convert';
import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/data/constants/api_constants.dart';
import '../models/purchases/purchase_order_model.dart';

class PurchaseOrdersService {
  String get _baseUrl => kBackendBaseUrl;

  Future<List<PurchaseOrderModel>> getPurchaseOrders() async {
    final url = Uri.parse('$_baseUrl/purchase-orders');
    final response = await ApiHttp.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List<dynamic> payload = jsonData is List
          ? jsonData
          : (jsonData is Map<String, dynamic>
              ? List<dynamic>.from(jsonData['data'] ?? [])
              : []);

      return payload
          .map((e) => PurchaseOrderModel.fromJson(e))
          .toList();
    }

    throw Exception(
      'Error al obtener órdenes de compra: ${response.statusCode}',
    );
  }
}
