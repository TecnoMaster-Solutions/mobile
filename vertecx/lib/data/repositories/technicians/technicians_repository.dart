import 'package:vertecx/data/models/technicians/technician_model.dart';
import 'package:vertecx/data/services/technicians_service.dart';

class TechniciansRepository {
  final TechniciansService _service = TechniciansService();

  Future<List<TechnicianModel>> fetchTechnicians() {
    return _service.getTechnicians();
  }
}
