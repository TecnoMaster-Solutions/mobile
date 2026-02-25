import 'package:vertecx/data/models/products/product_model.dart';
import 'package:vertecx/data/services/products_service.dart';

class ProductsRepository {
  final ProductsService _service;

  ProductsRepository({ProductsService? service})
      : _service = service ?? ProductsService();

  Future<List<ProductModel>> fetchProducts({String status = 'all', String? token}) {
    return _service.getProducts(status: status, token: token);
  }
}
