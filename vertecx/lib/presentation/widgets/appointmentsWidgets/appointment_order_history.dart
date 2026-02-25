import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vertecx/data/models/appointments/appointment_model.dart';
import 'package:vertecx/presentation/widgets/appointmentsWidgets/appointment_service_detail.dart';

class AppointmentOrderHistory extends StatelessWidget {
  final Future<AppointmentDetailData> detailFuture;

  const AppointmentOrderHistory({super.key, required this.detailFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppointmentDetailData>(
      future: detailFuture,
      builder: (context, snapshot) {
        final history = snapshot.data?.history;
        if (history == null || history.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Historial",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 10),
              ...history.asMap().entries.map((entry) {
                final actionLabel = entry.value.actionLabel.trim();
                final description = entry.value.description?.trim();
                final title =
                    actionLabel.isNotEmpty ? actionLabel : "Orden actualizada";
                final detail = (description != null && description.isNotEmpty)
                    ? description
                    : "Por: Sistema";
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat(
                        'dd/MM/yyyy, h:mm a',
                        'es',
                      ).format(entry.value.createdAt),
                      style: const TextStyle(color: Color(0xFF6E6E6E)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: const TextStyle(color: Color(0xFF666666)),
                    ),
                    if (entry.key != history.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: Color(0xFFE0E0E0)),
                      ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
