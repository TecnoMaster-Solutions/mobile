import 'dart:convert';
import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/data/constants/api_constants.dart';
import 'package:vertecx/data/models/categoryProducts/categoryProducts_model.dart';


class CategoryProductsService {
  String get _baseUrl => kBackendBaseUrl;

  Future<List<CategoryProduct>> getCategories() async {
    final url = Uri.parse('$_baseUrl/products-categories');
    final response = await ApiHttp.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List<dynamic> payload = jsonData is List
          ? jsonData
          : (jsonData is Map<String, dynamic>
              ? List<dynamic>.from(jsonData['data'] ?? [])
              : []);

      return payload
          .map((e) => CategoryProduct.fromJson(e))
          .toList();
    }

    throw Exception(
      'Error al obtener categorías: ${response.statusCode}',
    );
  }

  Future<void> createCategory(CategoryProduct category) async {
    final url = Uri.parse('$_baseUrl/products-categories');

    final response = await ApiHttp.post(
      url,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': category.nombre,
        'description': category.descripcion,
        'status': category.estado == CategoryStatus.activo,
        'icon': category.imagenPath,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Error al crear categoría: ${response.statusCode}',
      );
    }
  }

  Future<CategoryProduct> updateStatus(int id, bool newStatus) async {
    final url = Uri.parse('$_baseUrl/products-categories/$id');

    final response = await ApiHttp.patch(
      url,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'status': newStatus}),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return CategoryProduct.fromJson(jsonData['data']);
    }

    throw Exception(
      'Error al actualizar estado: ${response.statusCode} - ${response.body}',
    );
  }
}
