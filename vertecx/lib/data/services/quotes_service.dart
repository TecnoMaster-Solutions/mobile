import 'dart:convert';

import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/data/constants/api_constants.dart';
import 'package:vertecx/data/models/quotes/quote_model.dart';

class QuotesService {
  const QuotesService();

  Future<List<QuoteModel>> fetchQuotes() async {
    final Uri uri = Uri.parse('$kBackendBaseUrl/quotes');
    final response = await ApiHttp.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('No se pudieron cargar las cotizaciones');
    }

    final dynamic decoded = jsonDecode(response.body);
    final List rawList = decoded is List
        ? decoded
        : decoded is Map<String, dynamic> && decoded['data'] is List
            ? decoded['data'] as List
            : const [];

    return rawList
        .whereType<Object>()
        .map(
          (item) => QuoteModel.fromJson(
            item is Map<String, dynamic>
                ? item
                : Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);
  }
}
