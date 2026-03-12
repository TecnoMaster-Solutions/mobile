enum SaleItemType { product, service }

class SaleItemModel {
  final String name;
  final double price;
  final int quantity;
  final SaleItemType type;

  SaleItemModel({
    required this.name,
    required this.price,
    required this.quantity,
    required this.type,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    String name = "Ítem";
    SaleItemType type = SaleItemType.product;

    if (json['products'] != null) {
      name = json['products']['productname'] ?? "Producto";
      type = SaleItemType.product;
    } else if (json['service'] != null) {
      name = json['service']['servicename'] ?? "Servicio";
      type = SaleItemType.service;
    }

    return SaleItemModel(
      name: name,
      price: _asDouble(json['unitprice']),
      quantity: _asInt(json['quantity']),
      type: type,
    );
  }

  static double _asDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  double get total => price * quantity;

  String get formattedPrice {
    return "\$${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")}";
  }
}
