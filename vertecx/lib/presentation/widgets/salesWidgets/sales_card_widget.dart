import 'package:flutter/material.dart';
import 'package:vertecx/data/models/sales/sale_model.dart';
import 'package:vertecx/presentation/widgets/salesWidgets/sale_detail_widget.dart';

class SaleCardWidget extends StatelessWidget {
  final SaleModel sale;

  const SaleCardWidget({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 ID y Estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sale.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: sale.status == SaleStatus.finalizado
                        ? Color(0XFFD2F5D3)
                        : Color(0xFFF5D2D2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sale.statusString,
                    style: TextStyle(
                      color: sale.statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 🔹 Nombre del cliente
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 18,
                  color: Colors.black87,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    sale.clientName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold, // en negrilla
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // 🔹 Fecha (único que no va en negrilla)
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.black54,
                ),
                const SizedBox(width: 6),
                Text(
                  sale.formattedDate,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal, // no en negrilla
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 🔹 Precio arriba del botón
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      sale.formattedPrice,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // más grande que todo
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (_) => FractionallySizedBox(
                            heightFactor: 0.9,
                            child: SaleDetailWidget(sale: sale),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        "Ver detalle",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
