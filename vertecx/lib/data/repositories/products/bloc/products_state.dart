import 'package:vertecx/data/models/products/product_model.dart';

abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<ProductModel> products;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  ProductsLoaded({
    required this.products,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
}

class ProductsError extends ProductsState {
  final String message;
  ProductsError(this.message);
}