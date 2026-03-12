import '../../models/clients/customer_model.dart';
import '../../services/customers_service.dart';

class CustomerRepository {
  final CustomersService _service;

  CustomerRepository({CustomersService? service})
      : _service = service ?? CustomersService();

  Future<List<CustomerModel>> fetchCustomers() {
    return _service.getCustomers();
  }
}
