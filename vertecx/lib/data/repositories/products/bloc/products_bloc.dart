import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/data/repositories/products/products_repository.dart';
import 'products_event.dart';
import 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsRepository repo;

  ProductsBloc(this.repo) : super(ProductsInitial()) {
    on<LoadProductsEvent>((event, emit) async {
      emit(ProductsLoading());
      try {
        final response = await repo.fetchProducts(
          status: event.status,
          token: event.token,
          page: event.page,
          limit: event.limit,
          search: event.search,
          categoryId: event.categoryId,
        );

        emit(
          ProductsLoaded(
            products: response.data,
            total: response.meta.total,
            page: response.meta.page,
            limit: response.meta.limit,
            totalPages: response.meta.totalPages,
          ),
        );
      } catch (e) {
        emit(ProductsError(e.toString()));
      }
    });
  }
}