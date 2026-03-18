import 'package:vertecx/core/session_user_scope.dart';
import 'package:vertecx/data/models/quotes/quote_model.dart';
import 'package:vertecx/data/services/quotes_service.dart';

class QuotesRepository {
  QuotesRepository({QuotesService? service})
      : _service = service ?? const QuotesService();

  final QuotesService _service;

  Future<List<QuoteModel>> fetchQuotes() async {
    final scope = await SessionUserScopeResolver.resolve();
    final query = <String, dynamic>{};

    if (scope.isClientRole && scope.customerId != null) {
      query['customerid'] = scope.customerId;
    } else if (scope.isTechnicianRole && scope.technicianId != null) {
      query['technicianid'] = scope.technicianId;
    }

    return _service.fetchQuotes(query: query);
  }
}
