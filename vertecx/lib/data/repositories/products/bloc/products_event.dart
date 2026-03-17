abstract class ProductsEvent {}

class LoadProductsEvent extends ProductsEvent {
  final String status;
  final int page;
  final int limit;
  final String? search;
  final int? categoryId;
  final String? token;

  LoadProductsEvent({
    this.status = 'all',
    this.page = 1,
    this.limit = 50,
    this.search,
    this.categoryId,
    this.token,
  });
}