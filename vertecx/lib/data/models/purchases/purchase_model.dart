import 'dart:ui';
import 'package:intl/intl.dart';

enum PurchaseStatus { aprobado, anulado, otro }

class PurchaseProductItemModel {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  PurchaseProductItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  factory PurchaseProductItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'];

    return PurchaseProductItemModel(
      productId: _asInt(json['productid']),
      productName: product is Map<String, dynamic>
          ? (product['productname'] ?? 'Producto sin nombre').toString()
          : 'Producto sin nombre',
      quantity: _asInt(json['quantity']),
      unitPrice: _asDouble(json['unitprice']),
    );
  }
}

class PurchaseModel {
  final int id;
  final String orderNumber;
  final String factura;
  final String proveedor;
  final DateTime fecha;
  final double total;
  final PurchaseStatus estado;
  final int? stateId;
  final String? observation;
  final List<PurchaseProductItemModel> items;

  PurchaseModel({
    required this.id,
    required this.orderNumber,
    required this.factura,
    required this.proveedor,
    required this.fecha,
    required this.total,
    required this.estado,
    this.stateId,
    this.observation,
    this.items = const [],
  });

  String get estadoTexto {
    switch (estado) {
      case PurchaseStatus.aprobado:
        return "Aprobado";
      case PurchaseStatus.anulado:
        return "Anulado";
      case PurchaseStatus.otro:
        return "Otro";
    }
  }

  Color get estadoColorFondo {
    switch (estado) {
      case PurchaseStatus.aprobado:
        return const Color(0xFFD2F5D3);
      case PurchaseStatus.anulado:
        return const Color(0xFFF5D2D2);
      case PurchaseStatus.otro:
        return const Color(0xFFE8E8E8);
    }
  }

  Color get estadoColorTexto {
    switch (estado) {
      case PurchaseStatus.aprobado:
        return const Color(0xFF168700);
      case PurchaseStatus.anulado:
        return const Color(0xFF870000);
      case PurchaseStatus.otro:
        return const Color(0xFF525252);
    }
  }

  String get precioFormateado {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(total);
  }

  String formatMoney(double value) {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  String get fechaFormateada {
    return DateFormat('yyyy-MM-dd').format(fecha);
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

  static PurchaseStatus _mapStatus(dynamic stateId, dynamic stateObj) {
    final id = _asInt(stateId);
    final stateName = (stateObj is Map<String, dynamic>
            ? (stateObj['name'] ?? stateObj['statename'] ?? '')
            : '')
        .toString()
        .toLowerCase()
        .trim();

    if (id == 3 || stateName.contains('aprob')) {
      return PurchaseStatus.aprobado;
    }

    if (id == 8 ||
        stateName.contains('anulad') ||
        stateName.contains('cancel')) {
      return PurchaseStatus.anulado;
    }

    return PurchaseStatus.otro;
  }

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    final supplier = json['supplier'];
    final state = json['state'];
    final rawItems = json['purchaseProducts'];

    return PurchaseModel(
      id: _asInt(json['purchaseorderid']),
      orderNumber: (json['numberoforder'] ?? '').toString(),
      factura: (json['reference'] ?? '').toString(),
      proveedor: supplier is Map<String, dynamic>
          ? (supplier['name'] ??
                  supplier['suppliername'] ??
                  supplier['supplierName'] ??
                  'Sin proveedor')
              .toString()
          : 'Sin proveedor',
      fecha: DateTime.tryParse((json['createdat'] ?? '').toString()) ??
          DateTime.now(),
      total: _asDouble(json['amount']),
      estado: _mapStatus(json['stateid'], state),
      stateId: json['stateid'] == null ? null : _asInt(json['stateid']),
      observation: json['observation']?.toString(),
      items: rawItems is List
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(PurchaseProductItemModel.fromJson)
              .toList()
          : const [],
    );
  }
}