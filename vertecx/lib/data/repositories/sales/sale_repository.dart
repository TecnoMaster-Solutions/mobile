import '../../models/sales/sale_model.dart';
import '../../services/sales_service.dart';

class SaleRepository {
  final SalesService _service;

  SaleRepository({SalesService? service})
      : _service = service ?? SalesService();

  Future<List<SaleModel>> fetchSales() {
    return _service.getSales();
  }
}
