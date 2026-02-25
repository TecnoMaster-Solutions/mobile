import 'package:flutter/material.dart';
import 'package:vertecx/data/models/orderServices/order_service_models.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
    required this.label,
  });

  final OrderServiceStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (color, bg) = _map(status);
    final text = label.trim().isEmpty ? 'Sin estado' : label.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  (Color, Color) _map(OrderServiceStatus s) {
    switch (s) {
      case OrderServiceStatus.completada:
        return (Colors.green, const Color(0xFFE8F5E9));
      case OrderServiceStatus.pendiente:
        return (Colors.orange, const Color(0xFFFFF3E0));
      case OrderServiceStatus.anulada:
        return (Colors.red, const Color(0xFFFFEBEE));
      case OrderServiceStatus.enProgreso:
        return (Colors.blue, const Color(0xFFE3F2FD));
    }
  }
}
