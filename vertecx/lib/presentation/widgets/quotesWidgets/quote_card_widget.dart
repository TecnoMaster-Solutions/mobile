import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vertecx/data/models/quotes/quote_model.dart';

class QuoteCardWidget extends StatelessWidget {
  const QuoteCardWidget({
    super.key,
    required this.quote,
  });

  final QuoteModel quote;

  @override
  Widget build(BuildContext context) {
    final NumberFormat currency = NumberFormat.currency(
      locale: 'es_CO',
      name: 'COP',
      symbol: 'COP ',
      decimalDigits: 0,
    );

    final (Color, Color) chipColors = _statusColors(quote.status);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFD7E2DA)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Id: ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${quote.id}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: chipColors.$1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    quote.status,
                    style: TextStyle(
                      color: chipColors.$2,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              quote.serviceType,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D141C),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Cliente: ${quote.customerName}',
              style: const TextStyle(
                color: Color(0xFF04652C),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Tecnico: ${quote.technicianName}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 2),
            Text(
              'Items: ${quote.detailsCount}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 2),
            Text(
              'Total: ${currency.format(quote.total)}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            if (quote.createdAt != null) ...[
              const SizedBox(height: 2),
              Text(
                'Fecha: ${DateFormat('dd/MM/yyyy').format(quote.createdAt!)}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
            if (quote.observation.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                quote.observation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ],
        ),
      ),
    );
  }

  (Color, Color) _statusColors(String status) {
    final String value = status.toLowerCase();
    if (value.contains('aprob')) {
      return (const Color(0xFFE8F6EE), const Color(0xFF04652C));
    }
    if (value.contains('pend')) {
      return (const Color(0xFFFFF4DD), const Color(0xFF9B6A00));
    }
    if (value.contains('cancel') || value.contains('anulad')) {
      return (const Color(0xFFFFE6E6), const Color(0xFFB42318));
    }
    if (value.contains('complet')) {
      return (const Color(0xFFE6F4EA), const Color(0xFF0F7A35));
    }
    return (const Color(0xFFF1F3F4), const Color(0xFF5F6368));
  }
}
