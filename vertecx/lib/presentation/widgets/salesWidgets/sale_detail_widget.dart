import 'package:flutter/material.dart';
import 'package:vertecx/data/models/sales/sale_item_model.dart';
import 'package:vertecx/data/models/sales/sale_model.dart';

class SaleDetailWidget extends StatelessWidget {
  final SaleModel sale;

  const SaleDetailWidget({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔙 Botón volver
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                const Text(
                  "Detalle venta",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
              ],
            ),

            const SizedBox(height: 10),

            // 📋 Encabezado
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow("Código venta", sale.id),
                  _buildRow(
                    "Estado venta",
                    sale.statusString,
                    valueColor: sale.statusColor,
                  ),
                  _buildRow("Cliente", sale.clientName),
                  _buildRow("Fecha venta", sale.formattedDate),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Productos y servicios",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: [
                  ...sale.items.map(
                    (item) => ListTile(
                      leading: SizedBox(
                        width: 32,
                        height: 32,
                        child: item.type == SaleItemType.product
                            ? Image.asset("assets/icons/proteccion1.png")
                            : Image.asset("assets/icons/tools.png"),
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${item.type == SaleItemType.product ? "Producto" : "Servicio"} • Cantidad: ${item.quantity}",
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Precio",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            item.formattedPrice,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(),
                  _buildRow("Subtotal", sale.formattedPrice),
                  _buildRow("IVA (19%)", sale.formattedPrice),
                  _buildRow("Descuento", sale.formattedPrice),
                  _buildRow(
                    "TOTAL",
                    sale.formattedPrice,
                    bold: true,
                    big: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Observaciones",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: "Ingrese su observación",
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A8A8A),
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cerrar",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    Color? valueColor,
    bool bold = false,
    bool big = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: big ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
