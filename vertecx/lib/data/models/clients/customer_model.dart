import '../users/user_model.dart';

class CustomerModel {
  final int customerId;
  final int userId;
  final String? city;
  final String? zipCode;
  final UserModel? user;

  CustomerModel({
    required this.customerId,
    required this.userId,
    this.city,
    this.zipCode,
    this.user,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerId: json['customerid'] is int 
          ? json['customerid'] 
          : int.tryParse(json['customerid']?.toString() ?? '') ?? 0,
      userId: json['userid'] is int 
          ? json['userid'] 
          : int.tryParse(json['userid']?.toString() ?? '') ?? 0,
      city: json['customercity']?.toString(),
      zipCode: json['customerzipcode']?.toString(),
      user: json['users'] != null ? UserModel.fromJson(json['users']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerid': customerId,
      'userid': userId,
      'customercity': city,
      'customerzipcode': zipCode,
    };
  }

  String get displayName => user?.nombreCompleto ?? "Cliente #$customerId";
  String get name => user?.nombreCompleto ?? "Cliente #$customerId";
  String get phone => user?.telefono ?? "N/A";
  String get email => user?.email ?? "N/A";
  String get statusString => user?.statusString ?? "Desconocido";
  String get roleString => user?.roleString ?? "Cliente";
  bool get isActive => user?.estado == UserStatus.activo;
  String get id => customerId.toString();
  String get documentNumber => user?.documentoId ?? "N/A";
}
