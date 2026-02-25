import 'package:flutter/material.dart';
import 'package:vertecx/data/models/products/product_model.dart';

class ProductDetailWidget extends StatelessWidget {
  final ProductModel product;

  const ProductDetailWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(
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
                      product.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            color: const Color(0xFFEFEFEF),
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image, size: 40),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      product.description.isEmpty ? "Sin descripción" : product.description,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(thickness: 1),
                    Row(
                      children: [
                        const Text(
                          "Estado: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xff525252),
                          ),
                        ),
                        Text(
                          product.statusString,
                          style: TextStyle(
                            color: product.status == ProductStatus.activo
                                ? Colors.green
                                : const Color(0xFFB20000),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(thickness: 1),
                    Row(
                      children: [
                        const Text(
                          "Precio: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xff525252),
                          ),
                        ),
                        Text(
                          product.formattedPrice,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (product.priceOfSale != null || product.priceOfSupplier != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.priceOfSale != null)
                            Text(
                              "Venta: ${product.formatMoney(product.priceOfSale)}",
                              style: const TextStyle(fontSize: 14, color: Color(0xff525252)),
                            ),
                          if (product.priceOfSupplier != null)
                            Text(
                              "Proveedor: ${product.formatMoney(product.priceOfSupplier)}",
                              style: const TextStyle(fontSize: 14, color: Color(0xff525252)),
                            ),
                        ],
                      ),
                    const SizedBox(height: 18),
                    const Divider(thickness: 1),
                    Row(
                      children: [
                        const Text(
                          "Stock: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xff525252),
                          ),
                        ),
                        Text(
                          product.stockString,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(thickness: 1),
                    Row(
                      children: [
                        const Text(
                          "Categoría: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xff525252),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            product.category ?? "N/A",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(thickness: 1),
                    if ((product.supplierCategory ?? '').isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Categoría proveedor:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xff525252),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            product.supplierCategory ?? "",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 18),
                          const Divider(thickness: 1),
                        ],
                      ),
                    if ((product.code ?? '').isNotEmpty)
                      Row(
                        children: [
                          const Text(
                            "Código: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xff525252),
                            ),
                          ),
                          Text(
                            product.code ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    if ((product.code ?? '').isNotEmpty) const SizedBox(height: 18),
                    if ((product.code ?? '').isNotEmpty) const Divider(thickness: 1),
                    Row(
                      children: [
                        const Text(
                          "ID: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xff525252),
                          ),
                        ),
                        Text(
                          "${product.id}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const ImageIcon(AssetImage("assets/icons/Close.png")),
                  iconSize: 44,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
