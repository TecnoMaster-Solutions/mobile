import 'package:vertecx/data/models/products/product_model.dart';

class ProductsMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  ProductsMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory ProductsMeta.fromJson(Map<String, dynamic> json) {
    return ProductsMeta(
      total: (json['total'] ?? 0) is int
          ? json['total']
          : int.tryParse(json['total'].toString()) ?? 0,
      page: (json['page'] ?? 1) is int
          ? json['page']
          : int.tryParse(json['page'].toString()) ?? 1,
      limit: (json['limit'] ?? 8) is int
          ? json['limit']
          : int.tryParse(json['limit'].toString()) ?? 8,
      totalPages: (json['totalPages'] ?? 1) is int
          ? json['totalPages']
          : int.tryParse(json['totalPages'].toString()) ?? 1,
    );
  }
}

class ProductsPaginatedResponse {
  final List<ProductModel> data;
  final ProductsMeta meta;

  ProductsPaginatedResponse({
    required this.data,
    required this.meta,
  });

  factory ProductsPaginatedResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final rawMeta = json['meta'];

    return ProductsPaginatedResponse(
      data: rawData is List
          ? rawData
              .whereType<Map<String, dynamic>>()
              .map(ProductModel.fromJson)
              .toList()
          : <ProductModel>[],
      meta: rawMeta is Map<String, dynamic>
          ? ProductsMeta.fromJson(rawMeta)
          : ProductsMeta(total: 0, page: 1, limit: 8, totalPages: 1),
    );
  }
}