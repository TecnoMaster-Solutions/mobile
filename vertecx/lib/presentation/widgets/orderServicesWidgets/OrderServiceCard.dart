import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vertecx/data/models/orderServices/order_service_models.dart';
import 'package:vertecx/presentation/widgets/StatusChip.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  final OrderService order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('dd/MM/yyyy HH:mm');
    final currency = NumberFormat.currency(
      locale: 'es_CO',
      name: 'COP',
      symbol: 'COP ',
      decimalDigits: 0,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
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
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  StatusChip(
                    status: order.estado,
                    label: order.estadoLabel,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                order.titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                'Cliente: ${order.cliente}',
                style: const TextStyle(
                  color: Color(0xFF04652C),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Técnico(s): ${order.techniciansLabel}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                'Fecha creación: ${f.format(order.fechaCreacion)}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              if (order.startAt != null)
                Text(
                  'Inicio: ${f.format(order.startAt!)}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              if (order.total > 0)
                Text(
                  'Valor estimado: ${currency.format(order.total)}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              Text(
                'Estado registrado: ${order.estadoLabel}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
