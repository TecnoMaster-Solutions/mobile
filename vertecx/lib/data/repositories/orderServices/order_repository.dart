import 'package:vertecx/data/constants/api_constants.dart';
import 'package:vertecx/data/models/orderServices/order_service_history_model.dart';
import 'package:vertecx/data/models/orderServices/order_service_models.dart';
import 'package:vertecx/data/services/order_services_service.dart';

class OrderRepository {
  OrderRepository({OrderServicesService? service})
    : _service = service ?? OrderServicesService(baseUrl: kBackendBaseUrl);

  final OrderServicesService _service;

  Future<List<OrderService>> getAll() async {
    final data = await _service.getOrders();
    final orders = data.map(OrderService.fromJson).toList();
    orders.sort((a, b) {
      final byDate = b.fechaCreacion.compareTo(a.fechaCreacion);
      if (byDate != 0) return byDate;
      return b.id.compareTo(a.id);
    });
    return orders;
  }

  Future<OrderService> getById(int id) async {
    final json = await _service.getOrderById(id);
    return OrderService.fromJson(json);
  }

  Future<List<OrderServiceHistoryEntry>> getHistory(int id) async {
    final json = await _service.getOrderHistory(id);
    return json.map(OrderServiceHistoryEntry.fromJson).toList();
  }
}
