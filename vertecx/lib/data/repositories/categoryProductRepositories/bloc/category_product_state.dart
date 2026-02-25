part of 'category_product_bloc.dart';

abstract class CategoryProductState {}

class CategoryProductInitial extends CategoryProductState {}

class CategoryProductLoading extends CategoryProductState {}

class CategoryProductLoaded extends CategoryProductState {
  final List<CategoryProduct> categories;
  CategoryProductLoaded(this.categories);
}

class CategoryProductError extends CategoryProductState {
  final String message;
  CategoryProductError(this.message);
}
