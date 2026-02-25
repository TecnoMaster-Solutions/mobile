import 'package:intl/intl.dart';

enum ProductStatus { activo, inactivo }

class ProductModel {
  final int id;
  final String name;
  final ProductStatus status;

  final double price;
  final double? priceOfSale;
  final double? priceOfSupplier;

  final String description;
  final String imageUrl;

  final String? category;
  final int? categoryId;

  final int? stock;
  final String? code;
  final String? supplierCategory;

  ProductModel({
    required this.id,
    required this.name,
    required this.status,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.priceOfSale,
    this.priceOfSupplier,
    this.category,
    this.categoryId,
    this.stock,
    this.code,
    this.supplierCategory,
  });

  String get statusString => status == ProductStatus.activo ? "Activo" : "Inactivo";

  String get formattedPrice {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  String formatMoney(double? value) {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(value ?? 0);
  }

  String get stockString {
    if (stock == null) return "N/A";
    return stock! > 0 ? "$stock" : "Agotado";
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  static String _asString(dynamic v) => (v ?? '').toString();

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final isActive = json['isactive'] == true;

    final sale = json['productpriceofsale'];
    final supplier = json['productpriceofsupplier'];

    final double? salePrice = (sale == null) ? null : _asDouble(sale);
    final double? supplierPrice = (supplier == null) ? null : _asDouble(supplier);

    final effectivePrice = salePrice ?? supplierPrice ?? 0.0;

    String? categoryName;
    final cat = json['category'];
    if (cat is Map<String, dynamic>) {
      categoryName = (cat['name'] ?? cat['categoryname'] ?? cat['nombre'])?.toString();
    }

    return ProductModel(
      id: _asInt(json['productid']),
      name: _asString(json['productname']).trim(),
      status: isActive ? ProductStatus.activo : ProductStatus.inactivo,
      price: effectivePrice,
      priceOfSale: salePrice,
      priceOfSupplier: supplierPrice,
      description: (json['productdescription'] ?? '').toString(),
      imageUrl: _asString(json['image']).trim(),
      category: categoryName,
      categoryId: json['categoryid'] == null ? null : _asInt(json['categoryid']),
      stock: json['productstock'] == null ? null : _asInt(json['productstock']),
      code: json['productcode']?.toString(),
      supplierCategory: json['suppliercategory']?.toString(),
    );
  }
}
