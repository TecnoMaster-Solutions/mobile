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

  double get total => price * quantity;

  String get formattedPrice {
    return "\$${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")}";
  }
}
