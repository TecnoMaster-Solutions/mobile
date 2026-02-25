import 'package:flutter/material.dart';
import 'package:vertecx/data/models/purchases/purchase_model.dart';

class PurchaseCardWidget extends StatelessWidget {
  final PurchaseModel compra;

  const PurchaseCardWidget({super.key, required this.compra});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Encabezado: Código y total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Código OC y factura
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compra.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      compra.factura,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                // Total y fecha
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      compra.precioFormateado,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      compra.fechaFormateada,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 🔹 Proveedor
            Text(
              compra.proveedor,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),

            const SizedBox(height: 10),

            // 🔹 Estado + Iconos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: compra.estadoColorFondo,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    compra.estadoTexto,
                    style: TextStyle(
                      color: compra.estadoColorTexto,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

                // Íconos (ver detalle y acción secundaria)
                Row(
                  children: const [
                    Icon(
                      Icons.remove_red_eye_outlined,
                      size: 20,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.more_horiz, size: 20, color: Colors.black54),
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
