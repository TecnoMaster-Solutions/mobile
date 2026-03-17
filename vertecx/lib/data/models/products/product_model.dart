import 'package:intl/intl.dart';

enum ProductStatus { activo, inactivo }

class ProductCategoryModel {
  final int? id;
  final String name;

  ProductCategoryModel({this.id, required this.name});

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: (json['name'] ?? '').toString().trim(),
    );
  }
}

class ProductModel {
  final int id;
  final String name;
  final ProductStatus status;

  final double price;
  final double? priceOfSale;
  final double? priceOfSupplier;

  final String description;
  final String imageUrl;
  final List<String> images;

  final ProductCategoryModel? category;
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
    required this.images,
    this.priceOfSale,
    this.priceOfSupplier,
    this.category,
    this.categoryId,
    this.stock,
    this.code,
    this.supplierCategory,
  });

  String get statusString =>
      status == ProductStatus.activo ? "Activo" : "Inactivo";

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

  String get categoryName => category?.name ?? "N/A";

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static int? _asNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double _asDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  static String _asString(dynamic v) => (v ?? '').toString();

  static List<String> _asStringList(dynamic v) {
    if (v is List) {
      return v
          .map((e) => (e ?? '').toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return <String>[];
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final isActive = json['isactive'] == true;

    final sale = json['productpriceofsale'];
    final supplier = json['productpriceofsupplier'];

    final double? salePrice = sale == null ? null : _asDouble(sale);
    final double? supplierPrice = supplier == null ? null : _asDouble(supplier);

    final effectivePrice = salePrice ?? supplierPrice ?? 0.0;

    ProductCategoryModel? parsedCategory;
    final cat = json['category'];
    if (cat is Map<String, dynamic>) {
      parsedCategory = ProductCategoryModel.fromJson(cat);
    }

    final parsedImages = _asStringList(json['images']);
    final mainImage = _asString(json['image']).trim();
    final resolvedImages = parsedImages.isNotEmpty
        ? parsedImages
        : (mainImage.isNotEmpty ? [mainImage] : <String>[]);

    return ProductModel(
      id: _asInt(json['productid']),
      name: _asString(json['productname']).trim(),
      status: isActive ? ProductStatus.activo : ProductStatus.inactivo,
      price: effectivePrice,
      priceOfSale: salePrice,
      priceOfSupplier: supplierPrice,
      description: (json['productdescription'] ?? '').toString().trim(),
      imageUrl: resolvedImages.isNotEmpty ? resolvedImages.first : '',
      images: resolvedImages,
      category: parsedCategory,
      categoryId: _asNullableInt(json['categoryid']),
      stock: json['productstock'] == null ? null : _asInt(json['productstock']),
      code: json['productcode']?.toString(),
      supplierCategory: json['suppliercategory']?.toString(),
    );
  }
}
