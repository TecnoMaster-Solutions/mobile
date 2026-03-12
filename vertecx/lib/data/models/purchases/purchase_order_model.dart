import 'package:intl/intl.dart';

class PurchaseOrderModel {
  final int id;
  final String orderNumber;
  final int supplierId;
  final int? stateId;
  final DateTime createdAt;
  final DateTime? estimatedDeliveryDate;
  final double total;
  final String? observations;
  final String? supplierName;
  final String? stateName;

  PurchaseOrderModel({
    required this.id,
    required this.orderNumber,
    required this.supplierId,
    this.stateId,
    required this.createdAt,
    this.estimatedDeliveryDate,
    required this.total,
    this.observations,
    this.supplierName,
    this.stateName,
  });

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderModel(
      id: _asInt(json['id']),
      orderNumber: json['numeroOrden']?.toString() ?? '',
      supplierId: _asInt(json['proveedorId']),
      stateId: json['estadoId'] != null ? _asInt(json['estadoId']) : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      estimatedDeliveryDate: json['fechaEstimadaEntrega'] != null 
          ? DateTime.tryParse(json['fechaEstimadaEntrega'].toString()) 
          : null,
      total: _asDouble(json['total']),
      observations: json['observaciones']?.toString(),
      supplierName: json['supplier']?['name']?.toString(),
      stateName: json['state']?['name']?.toString(),
    );
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  String get formattedTotal {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(total);
  }

  String get formattedDate => DateFormat('dd/MM/yyyy').format(createdAt);
  
  String get formattedEstimatedDeliveryDate => estimatedDeliveryDate != null 
      ? DateFormat('dd/MM/yyyy').format(estimatedDeliveryDate!) 
      : "No informada";

  String get orderIdString => orderNumber.isNotEmpty ? orderNumber : id.toString();

  String get idString => orderIdString;

  @override
  String toString() => idString;

  String get supplier => supplierName ?? "Proveedor #$supplierId";

  String get service => observations ?? "Compra de productos";

  String get statusString => stateName ?? "Pendiente";

  int get statusColorValue {
    switch (statusString.toLowerCase()) {
      case 'completada':
      case 'entregada':
      case 'recibida':
        return 0xFF4CAF50;
      case 'cancelada':
        return 0xFFF44336;
      default:
        return 0xFF2196F3;
    }
  }

  int get statusBgColorValue {
    switch (statusString.toLowerCase()) {
      case 'completada':
      case 'entregada':
      case 'recibida':
        return 0xFFE8F5E9;
      case 'cancelada':
        return 0xFFFFEBEE;
      default:
        return 0xFFE3F2FD;
    }
  }
}
