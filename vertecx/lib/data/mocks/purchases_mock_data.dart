import 'package:vertecx/data/models/purchases/purchase_model.dart';

final List<PurchaseModel> mockPurchases = [
  PurchaseModel(
    id: "OC-2025-001",
    factura: "FAC-2025-1001",
    proveedor: "Proveedor A",
    fecha: DateTime(2025, 8, 20),
    total: 1200.50,
    estado: PurchaseStatus.anulado,
  ),
  PurchaseModel(
    id: "OC-2025-002",
    factura: "FAC-2025-1002",
    proveedor: "Proveedor A",
    fecha: DateTime(2025, 8, 20),
    total: 1200.50,
    estado: PurchaseStatus.aprobado,
  ),
  PurchaseModel(
    id: "OC-2025-003",
    factura: "FAC-2025-1003",
    proveedor: "Proveedor A",
    fecha: DateTime(2025, 8, 20),
    total: 1200.50,
    estado: PurchaseStatus.anulado,
  ),
];
