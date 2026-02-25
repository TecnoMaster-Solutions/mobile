import 'package:vertecx/data/constants/api_constants.dart';
import 'package:vertecx/data/models/request/request_model.dart';
import 'package:vertecx/data/services/service_requests_service.dart';

abstract class IRequestRepository {
  Future<List<ServiceRequestModel>> getAll();
  Future<ServiceRequestModel> getById(int id);
}

class RequestsRepository implements IRequestRepository {
  final ServiceRequestsService _api;

  RequestsRepository([ServiceRequestsService? api])
      : _api = api ?? ServiceRequestsService(baseUrl: kBackendBaseUrl);

  @override
  Future<List<ServiceRequestModel>> getAll() {
    return _api.getRequests(page: 1, limit: 50);
  }

  @override
  Future<ServiceRequestModel> getById(int id) async {
    final Map<String, dynamic> json = await _api.getRequestById(id);
    return ServiceRequestModel.fromJson(json);
  }
}
