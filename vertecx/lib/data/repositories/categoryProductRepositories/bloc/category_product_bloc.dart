import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/data/models/categoryProducts/categoryProducts_model.dart';
import 'package:vertecx/data/services/category_products_service.dart';

part 'category_product_event.dart';
part 'category_product_state.dart';

class CategoryProductBloc extends Bloc<CategoryProductEvent, CategoryProductState> {
  final CategoryProductsService _service;

  CategoryProductBloc(this._service) : super(CategoryProductInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<ToggleCategoryStatus>(_onToggleCategoryStatus);
  }

  Future<void> _onLoadCategories(
      LoadCategories event, Emitter<CategoryProductState> emit) async {
    emit(CategoryProductLoading());
    try {
      final categories = await _service.getCategories();
      emit(CategoryProductLoaded(categories));
    } catch (e) {
      emit(CategoryProductError(e.toString()));
    }
  }

  Future<void> _onToggleCategoryStatus(
      ToggleCategoryStatus event, Emitter<CategoryProductState> emit) async {
    if (state is! CategoryProductLoaded) return;

    final currentState = state as CategoryProductLoaded;
    final categories = List<CategoryProduct>.from(currentState.categories);

    final index = categories.indexWhere((c) => c.id == event.categoryId);
    if (index == -1) return;

    final category = categories[index];
    final newStatus =
        category.estado == CategoryStatus.activo ? false : true; 

    try {
      final updatedCategory =
          await _service.updateStatus(category.id, newStatus);

      categories[index] = updatedCategory;
      emit(CategoryProductLoaded(categories));
    } catch (e) {
      emit(CategoryProductError("Error al cambiar estado: $e"));
      emit(currentState); 
    }
  }
}
