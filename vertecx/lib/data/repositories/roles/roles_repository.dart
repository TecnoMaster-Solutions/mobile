import 'package:vertecx/data/models/roles/role_model.dart';
import 'package:vertecx/data/services/roles_service.dart';

class RolesRepository {
  final RolesService _service;

  RolesRepository({RolesService? service}) : _service = service ?? RolesService();

  Future<List<RoleModel>> fetchRoles({String? token}) {
    return _service.getRoles(token: token);
  }
}
