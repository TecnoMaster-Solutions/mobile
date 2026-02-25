import 'package:vertecx/data/models/sales/sale_model.dart';
import 'package:vertecx/data/models/sales/sale_item_model.dart';

final List<SaleModel> mockSales = [
  SaleModel(
    id: "VEN-001",
    clientName: "Laura Gómez",
    date: DateTime(2025, 7, 11),
    subtotal: 800000,
    iva: 100000,
    discount: 0,
    total: 900000,
    status: SaleStatus.finalizado,
    items: [
      SaleItemModel(
        name: "Monitor LG",
        price: 600000,
        quantity: 1,
        type: SaleItemType.product,
      ),
      SaleItemModel(
        name: "Instalación PC",
        price: 200000,
        quantity: 1,
        type: SaleItemType.service,
      ),
    ],
  ),
  SaleModel(
    id: "VEN-002",
    clientName: "Carlos Rodríguez",
    date: DateTime(2025, 7, 12),
    subtotal: 500000,
    iva: 100000,
    discount: 0,
    total: 600000,
    status: SaleStatus.finalizado,
    items: [
      SaleItemModel(
        name: "Monitor LG",
        price: 600000,
        quantity: 1,
        type: SaleItemType.product,
      ),
    ],
  ),
  SaleModel(
    id: "VEN-003",
    clientName: "Ana Lévez",
    date: DateTime(2025, 7, 13),
    subtotal: 300000,
    iva: 100000,
    discount: 0,
    total: 400000,
    status: SaleStatus.anulado,
    items: [
      SaleItemModel(
        name: "Monitor LG",
        price: 600000,
        quantity: 1,
        type: SaleItemType.product,
      ),
    ],
  ),
];
