import 'package:vertecx/data/models/products/products_paginated_response.dart';
import 'package:vertecx/data/services/products_service.dart';

class ProductsRepository {
  final ProductsService _service;

  ProductsRepository({ProductsService? service})
      : _service = service ?? ProductsService();

  Future<ProductsPaginatedResponse> fetchProducts({
    String status = 'all',
    String? token,
    int page = 1,
    int limit = 50,
    String? search,
    int? categoryId,
  }) {
    return _service.getProducts(
      status: status,
      token: token,
      page: page,
      limit: limit,
      search: search,
      categoryId: categoryId,
    );
  }
}