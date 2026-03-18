import 'package:vertecx/data/models/purchases/purchases_paginated_response.dart';
import 'package:vertecx/data/services/purchases_service.dart';
import 'package:vertecx/data/models/purchases/purchase_model.dart';

class PurchasesRepository {
  final PurchasesService _service;

  PurchasesRepository({PurchasesService? service})
    : _service = service ?? PurchasesService();

  Future<PurchasesPaginatedResponse> fetchPurchases({
    String? token,
    int page = 1,
    int limit = 50,
    String? search,
  }) {
    return _service.getPurchases(
      token: token,
      page: page,
      limit: limit,
      search: search,
    );
  }

  Future<PurchaseModel> fetchPurchaseById(int id, {String? token}) {
    return _service.getPurchaseById(id, token: token);
  }
}
