import 'package:vertecx/data/models/purchases/purchase_order_model.dart';

final List<PurchaseOrderModel> mockPurchaseOrders = [
  PurchaseOrderModel(
    id: "001",
    supplier: "Viva Solar",
    service: "Instalación de cámara",
    date: DateTime(2025, 7, 11),
    status: PurchaseOrderStatus.recibida,
  ),
  PurchaseOrderModel(
    id: "002",
    supplier: "Comercial XYZ",
    service: "Limpieza eléctrica",
    date: DateTime(2025, 8, 19),
    status: PurchaseOrderStatus.pendiente,
  ),
  PurchaseOrderModel(
    id: "003",
    supplier: "Suministros QPS",
    service: "Cambios de switch",
    date: DateTime(2025, 7, 11),
    status: PurchaseOrderStatus.aprobada,
  ),
  PurchaseOrderModel(
    id: "004",
    supplier: "Viva Solar",
    service: "Instalación de cámara",
    date: DateTime(2025, 7, 11),
    status: PurchaseOrderStatus.recibida,
  ),
];
