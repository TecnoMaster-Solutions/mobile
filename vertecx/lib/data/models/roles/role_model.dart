enum RoleStatus { activo, inactivo }

class RoleModel {
  final int id;
  final String name;
  final RoleStatus status;

  RoleModel({
    required this.id,
    required this.name,
    required this.status,
  });

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static RoleStatus _parseStatus(dynamic v) {
    final raw = (v ?? '').toString().toLowerCase().trim();
    if (raw == 'active' || raw == 'activo' || raw == '1' || raw == 'true') return RoleStatus.activo;
    if (raw == 'inactive' || raw == 'inactivo' || raw == '0' || raw == 'false') return RoleStatus.inactivo;
    if (raw.isEmpty) return RoleStatus.activo;
    return RoleStatus.inactivo;
  }

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: _asInt(json['roleid'] ?? json['roleId'] ?? json['id']),
      name: (json['name'] ?? json['rolename'] ?? '').toString(),
      status: _parseStatus(json['status']),
    );
  }
}
