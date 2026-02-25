enum PurchaseOrderStatus { recibida, pendiente, aprobada }

class PurchaseOrderModel {
  final String id;
  final String supplier;
  final String service;
  final DateTime date;
  final PurchaseOrderStatus status;

  PurchaseOrderModel({
    required this.id,
    required this.supplier,
    required this.service,
    required this.date,
    required this.status,
  });

  String get formattedDate =>
      "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";

  String get statusString {
    switch (status) {
      case PurchaseOrderStatus.recibida:
        return "Recibida";
      case PurchaseOrderStatus.pendiente:
        return "Pendiente";
      case PurchaseOrderStatus.aprobada:
        return "Aprobada";
    }
  }

  // Colores por estado
  int get statusColorValue {
    switch (status) {
      case PurchaseOrderStatus.recibida:
        return 0xFF168700; // verde
      case PurchaseOrderStatus.pendiente:
        return 0xFFC47900; // amarillo
      case PurchaseOrderStatus.aprobada:
        return 0xFF3A3A3A; // gris oscuro
    }
  }

  int get statusBgColorValue {
    switch (status) {
      case PurchaseOrderStatus.recibida:
        return 0xFFD2F5D3;
      case PurchaseOrderStatus.pendiente:
        return 0xFFE8D298;
      case PurchaseOrderStatus.aprobada:
        return 0xFF999999;
    }
  }
}
