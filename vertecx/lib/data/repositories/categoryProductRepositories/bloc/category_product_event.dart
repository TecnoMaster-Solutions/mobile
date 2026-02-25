part of 'category_product_bloc.dart';

abstract class CategoryProductEvent {}

class LoadCategories extends CategoryProductEvent {}

class ToggleCategoryStatus extends CategoryProductEvent {
  final int categoryId;
  ToggleCategoryStatus(this.categoryId);
}
