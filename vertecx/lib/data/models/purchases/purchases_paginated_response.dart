import 'package:vertecx/data/models/purchases/purchase_model.dart';

class PurchasesMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PurchasesMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PurchasesMeta.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, int fallback) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    return PurchasesMeta(
      total: parseInt(json['total'], 0),
      page: parseInt(json['page'], 1),
      limit: parseInt(json['limit'], 8),
      totalPages: parseInt(json['totalPages'], 1),
    );
  }
}

class PurchasesPaginatedResponse {
  final List<PurchaseModel> data;
  final PurchasesMeta meta;

  PurchasesPaginatedResponse({
    required this.data,
    required this.meta,
  });

  factory PurchasesPaginatedResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final rawMeta = json['meta'];

    return PurchasesPaginatedResponse(
      data: rawData is List
          ? rawData
              .whereType<Map<String, dynamic>>()
              .map(PurchaseModel.fromJson)
              .toList()
          : <PurchaseModel>[],
      meta: rawMeta is Map<String, dynamic>
          ? PurchasesMeta.fromJson(rawMeta)
          : PurchasesMeta(total: 0, page: 1, limit: 8, totalPages: 1),
    );
  }
}