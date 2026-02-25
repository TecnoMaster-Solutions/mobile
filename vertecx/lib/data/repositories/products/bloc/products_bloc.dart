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
        final products = await repo.fetchProducts(status: 'all');
        emit(ProductsLoaded(products));
      } catch (e) {
        emit(ProductsError(e.toString()));
      }
    });
  }
}
