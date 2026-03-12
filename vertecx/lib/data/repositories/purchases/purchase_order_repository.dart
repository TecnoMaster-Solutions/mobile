import '../../models/purchases/purchase_order_model.dart';
import '../../services/purchase_orders_service.dart';

class PurchaseOrderRepository {
  final PurchaseOrdersService _service;

  PurchaseOrderRepository({PurchaseOrdersService? service})
      : _service = service ?? PurchaseOrdersService();

  Future<List<PurchaseOrderModel>> fetchPurchaseOrders() {
    return _service.getPurchaseOrders();
  }
}
