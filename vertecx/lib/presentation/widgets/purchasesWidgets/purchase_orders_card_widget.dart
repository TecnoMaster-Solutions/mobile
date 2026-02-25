import 'package:flutter/material.dart';
import 'package:vertecx/data/models/purchases/purchase_order_model.dart';

class PurchaseOrderCardWidget extends StatelessWidget {
  final PurchaseOrderModel order;

  const PurchaseOrderCardWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row("N° orden", order.id, boldValue: true),
          _row("Proveedor", order.supplier),
          _row("Producto/servicio", order.service),
          _row("Fecha", order.formattedDate),
          Row(
            children: [
              const Text(
                "Estado",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 175),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Color(order.statusBgColorValue),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.statusString,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(order.statusColorValue),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool boldValue = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 220,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: boldValue ? FontWeight.bold : FontWeight.normal, color: Color(0xFF474747),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
