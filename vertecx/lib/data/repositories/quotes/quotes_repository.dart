import 'package:vertecx/data/models/quotes/quote_model.dart';
import 'package:vertecx/data/services/quotes_service.dart';

class QuotesRepository {
  QuotesRepository({QuotesService? service})
      : _service = service ?? const QuotesService();

  final QuotesService _service;

  Future<List<QuoteModel>> fetchQuotes() => _service.fetchQuotes();
}
