enum TechnicianStatus { activo, inactivo }

class TechnicianModel {
  final int id;
  final String name;
  final String phone;
  final String email;
  final TechnicianStatus status;
  final String? image;
  final List<String> types;

  TechnicianModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    required this.types,
    this.image,
  });

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static String _asString(dynamic v) => (v ?? '').toString();

  static TechnicianStatus _parseStatus(dynamic raw) {
    final v = (raw ?? '').toString().toLowerCase().trim();
    if (v == 'activo' || v == 'active' || v == '1' || v == 'true') {
      return TechnicianStatus.activo;
    }
    if (v == 'inactivo' || v == 'inactive' || v == '0' || v == 'false') {
      return TechnicianStatus.inactivo;
    }
    return TechnicianStatus.activo;
  }

  factory TechnicianModel.fromJson(Map<String, dynamic> json) {
    final user = (json['users'] as Map?) ?? <String, dynamic>{};

    final rawStates = user['states'];
    Map<String, dynamic> stateMap = {};
    if (rawStates is Map<String, dynamic>) {
      stateMap = rawStates;
    } else if (rawStates is List && rawStates.isNotEmpty) {
      final first = rawStates.first;
      if (first is Map<String, dynamic>) stateMap = first;
    }

    final firstName = _asString(user['name']).trim();
    final lastName = _asString(user['lastname']).trim();
    final fullName = [firstName, lastName]
        .where((p) => p.isNotEmpty)
        .join(' ')
        .trim();

    final rawTypes = json['technicianTypeMaps'];
    final List<String> types;
    if (rawTypes is List) {
      types = rawTypes
          .map((e) {
            if (e is Map &&
                e['techniciantype'] is Map &&
                (e['techniciantype'] as Map)['name'] != null) {
              return (e['techniciantype']['name']).toString();
            }
            return '';
          })
          .where((s) => s.isNotEmpty)
          .toList();
    } else {
      types = const [];
    }

    return TechnicianModel(
      id: _asInt(json['technicianid'] ?? json['id']),
      name: fullName,
      phone: _asString(user['phone']),
      email: _asString(user['email']),
      image: user['image']?.toString(),
      status: _parseStatus(stateMap['name'] ?? stateMap['status']),
      types: types,
    );
  }
}
