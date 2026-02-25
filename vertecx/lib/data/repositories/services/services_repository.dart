import 'package:vertecx/data/models/services/service_model.dart';
import 'package:vertecx/data/services/services_service.dart';

class ServicesRepository {
  final ServicesService _service;

  ServicesRepository({ServicesService? service})
      : _service = service ?? ServicesService();

  Future<ServicesListResult> fetchServices({
    int page = 1,
    int limit = 50,
    String? token,
  }) async {
    final res = await _service.getServices(
      page: page,
      limit: limit,
      token: token,
    );

    return ServicesListResult(
      services: res.data,
      meta: res.meta,
    );
  }
}

class ServicesListResult {
  final List<ServiceModel> services;
  final ServicesMeta meta;

  ServicesListResult({required this.services, required this.meta});
}
