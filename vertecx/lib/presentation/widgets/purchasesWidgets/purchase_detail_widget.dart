import 'package:flutter/material.dart';
import 'package:vertecx/data/models/purchases/purchase_model.dart';
import 'package:vertecx/data/repositories/purchases/purchases_repository.dart';

class PurchaseDetailWidget extends StatefulWidget {
  final int purchaseId;

  const PurchaseDetailWidget({
    super.key,
    required this.purchaseId,
  });

  @override
  State<PurchaseDetailWidget> createState() => _PurchaseDetailWidgetState();
}

class _PurchaseDetailWidgetState extends State<PurchaseDetailWidget> {
  late Future<PurchaseModel> _futurePurchase;
  final PurchasesRepository _repository = PurchasesRepository();

  @override
  void initState() {
    super.initState();
    _futurePurchase = _repository.fetchPurchaseById(widget.purchaseId);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.60,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: FutureBuilder<PurchaseModel>(
            future: _futurePurchase,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFB20000),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }

              final purchase = snapshot.data;
              if (purchase == null) {
                return const Center(
                  child: Text('No se pudo cargar el detalle de la compra'),
                );
              }

              return Stack(
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            height: 5,
                            width: 50,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Text(
                          purchase.orderNumber,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Factura: ${purchase.factura}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF525252),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: purchase.estadoColorFondo,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                purchase.estadoTexto,
                                style: TextStyle(
                                  color: purchase.estadoColorTexto,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        _detailRow('Proveedor', purchase.proveedor),
                        _detailRow('Fecha', purchase.fechaFormateada),
                        _detailRow('Total', purchase.precioFormateado),
                        _detailRow('Número de Orden', purchase.orderNumber,),
                        if ((purchase.observation ?? '').trim().isNotEmpty)
                          _detailRow('Observación', purchase.observation!.trim()),
                        const SizedBox(height: 20),
                        const Text(
                          'Productos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (purchase.items.isEmpty)
                          const Text(
                            'Esta compra no tiene productos asociados.',
                            style: TextStyle(color: Color(0xFF525252)),
                          )
                        else
                          ...purchase.items.map(
                            (item) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F6F6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE2E2E2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Cantidad: ${item.quantity}'),
                                  Text(
                                    'Precio unitario: ${purchase.formatMoney(item.unitPrice)}',
                                  ),
                                  Text(
                                    'Subtotal: ${purchase.formatMoney(item.subtotal)}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const ImageIcon(
                        AssetImage("assets/icons/Close.png"),
                      ),
                      iconSize: 44,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF525252),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}