enum SupplierStatus { active, inactive }

class SupplierModel {
  final int id;
  final String name;
  final String nit;
  final String phone;
  final String email;
  final String address;
  final String contactName;
  final String? imageUrl;
  final double rating;
  final int stateId;

  const SupplierModel({
    required this.id,
    required this.name,
    required this.nit,
    required this.phone,
    required this.email,
    required this.address,
    required this.contactName,
    required this.imageUrl,
    required this.rating,
    required this.stateId,
  });

  SupplierStatus get status =>
      stateId == 1 ? SupplierStatus.active : SupplierStatus.inactive;

  String get statusString =>
      status == SupplierStatus.active ? 'Activo' : 'Inactivo';

  SupplierModel copyWith({
    int? id,
    String? name,
    String? nit,
    String? phone,
    String? email,
    String? address,
    String? contactName,
    String? imageUrl,
    double? rating,
    int? stateId,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nit: nit ?? this.nit,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      contactName: contactName ?? this.contactName,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      stateId: stateId ?? this.stateId,
    );
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double _asDouble(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    final rawStateId = json['stateid'] ?? json['stateId'] ?? json['status'];
    final parsedStateId = _asInt(rawStateId, fallback: 1);
    final normalizedStateId = parsedStateId == 1 ? 1 : 2;

    return SupplierModel(
      id: _asInt(json['supplierid'] ?? json['id']),
      name: (json['name'] ?? '').toString(),
      nit: (json['nit'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      contactName: (json['contactname'] ?? json['contactName'] ?? '')
          .toString(),
      imageUrl: json['image']?.toString(),
      rating: _asDouble(json['rating']),
      stateId: normalizedStateId,
    );
  }
}

extension SupplierSearch on SupplierModel {
  bool matchesQuery(String query) {
    final q = _normalize(query);
    if (q.isEmpty) return true;

    return _normalize(id.toString()).contains(q) ||
        _normalize(name).contains(q) ||
        _normalize(nit).contains(q) ||
        _normalize(phone).contains(q) ||
        _normalize(email).contains(q) ||
        _normalize(contactName).contains(q) ||
        _normalize(statusString).contains(q);
  }
}

String _normalize(String value) {
  var out = value.toLowerCase().trim();
  const from = ['á', 'é', 'í', 'ó', 'ú', 'ñ'];
  const to = ['a', 'e', 'i', 'o', 'u', 'n'];
  for (var i = 0; i < from.length; i++) {
    out = out.replaceAll(from[i], to[i]);
  }
  out = out.replaceAll(RegExp(r'\s+'), ' ');
  return out;
}
