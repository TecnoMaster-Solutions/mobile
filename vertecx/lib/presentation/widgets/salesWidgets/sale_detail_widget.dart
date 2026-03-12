import 'package:flutter/material.dart';
import 'package:vertecx/data/models/sales/sale_item_model.dart';
import 'package:vertecx/data/models/sales/sale_model.dart';
import 'package:url_launcher/url_launcher.dart';

class SaleDetailWidget extends StatelessWidget {
  final SaleModel sale;

  const SaleDetailWidget({super.key, required this.sale});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $urlString');
    }
  }

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
                  "Detalle de la venta",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
              ],
            ),

            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Información del cliente
                    _buildSectionTitle("Información del cliente"),
                    _buildCard([
                      _buildRow("Nombre completo", sale.customer?.displayName ?? "N/A"),
                      _buildRow("Documento", sale.customer?.documentNumber ?? "N/A"),
                      _buildRow("Teléfono", sale.customer?.phone ?? "N/A"),
                      _buildRow("Correo", sale.customer?.email ?? "N/A"),
                      _buildRow("Ciudad", sale.customer?.city ?? "N/A"),
                    ]),

                    // 2. Datos de la venta
                    _buildSectionTitle("Datos de la venta"),
                    _buildCard([
                      _buildRow("Número de venta", sale.id),
                      _buildRow("Fecha", sale.formattedDate),
                      _buildRow("Estado de venta", sale.statusString, valueColor: sale.statusColor, bold: true),
                      _buildRow("Estado de pago", sale.paymentStatus, valueColor: sale.paymentStatusColor, bold: true),
                      _buildRow("Método de pago", sale.paymentMethod ?? "N/A"),
                      _buildRow("Creado por", sale.createdBy ?? "Sistema"),
                      _buildRow("Fecha de creación", sale.createdDate ?? sale.formattedDate),
                      _buildRow("Fecha actualización", sale.updatedDate ?? "N/A"),
                    ]),

                    // 3. Resumen de pago
                    _buildSectionTitle("Resumen de pago"),
                    _buildCard([
                      _buildRow("Total", sale.formattedTotal),
                      _buildRow("Pagado", sale.formattedPaidAmount, valueColor: Colors.green),
                      _buildRow("Pendiente", sale.formattedPendingAmount, valueColor: Colors.red),
                      _buildRow("Pagos reales", sale.payments.length.toString()),
                    ]),

                    // 4. Resumen general
                    _buildSectionTitle("Resumen general"),
                    _buildCard([
                      _buildRow("Subtotal", sale.formattedSubtotal),
                      _buildRow("Impuestos", sale.formattedTaxAmount),
                      _buildRow("TOTAL FINAL", sale.formattedTotal, bold: true, big: true),
                    ]),

                    // 5. Productos y servicios
                    _buildSectionTitle("Productos y servicios"),
                    ...sale.items.map((item) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8)
                              ),
                              child: Icon(
                                item.type == SaleItemType.product ? Icons.inventory_2 : Icons.build,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${item.type == SaleItemType.product ? "Producto" : "Servicio"} • Cantidad: ${item.quantity}"),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text("Precio unitario", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                Text(item.formattedPrice, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                          ),
                        )),

                    // 6. Pagos registrados
                    if (sale.payments.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildSectionTitle("Pagos registrados"),
                      ...sale.payments.map((p) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildRow("Monto", p.formattedAmount, valueColor: Colors.green, bold: true),
                                  _buildRow("Método", p.paymentMethod ?? "N/A"),
                                  _buildRow("Referencia", p.reference ?? "N/A"),
                                  _buildRow("Fecha", p.formattedDate),
                                  if (p.invoiceUrl != null && p.invoiceUrl!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: InkWell(
                                        onTap: () => _launchUrl(p.invoiceUrl!),
                                        child: const Text(
                                          "Ver comprobante",
                                          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )),
                    ],

                    const SizedBox(height: 10),

                    const Text(
                      "Observaciones",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        sale.notes?.isNotEmpty == true ? sale.notes! : "Sin observaciones",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF089642),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cerrar",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
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
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                fontSize: big ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
