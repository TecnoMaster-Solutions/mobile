import 'dart:ui';

enum PurchaseStatus { aprobado, anulado }

class PurchaseModel {
  final String id;
  final String factura;
  final String proveedor;
  final DateTime fecha;
  final double total;
  final PurchaseStatus estado;

  PurchaseModel({
    required this.id,
    required this.factura,
    required this.proveedor,
    required this.fecha,
    required this.total,
    required this.estado,
  });

  // 🔹 Texto del estado
  String get estadoTexto =>
      estado == PurchaseStatus.aprobado ? "Aprobado" : "Anulado";

  // 🔹 Color de fondo del estado
  Color get estadoColorFondo => estado == PurchaseStatus.aprobado
      ? const Color(0xFFD2F5D3)
      : const Color(0xFFF5D2D2);

  // 🔹 Color del texto del estado
  Color get estadoColorTexto => estado == PurchaseStatus.aprobado
      ? const Color(0xFF168700)
      : const Color(0xFF870000);

  // 🔹 Formato del precio
  String get precioFormateado {
    return "\$${total.toStringAsFixed(2)}";
  }

  // 🔹 Formato de fecha (yyyy-MM-dd)
  String get fechaFormateada {
    return "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
  }
}
