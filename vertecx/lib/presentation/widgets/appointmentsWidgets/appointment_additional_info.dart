import 'package:flutter/material.dart';
import 'package:vertecx/data/models/appointments/appointment_model.dart';

class AppointmentAdditionalInfo extends StatelessWidget {
  final AppointmentEvent cita;

  const AppointmentAdditionalInfo({super.key, required this.cita});

  @override
  Widget build(BuildContext context) {
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
            "Información adicional",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 10),

          // Observación
          if (cita.observaciones.isNotEmpty)
            _buildInfoCard(
              icon: Icons.warning_amber_rounded,
              title: "Observación",
              content: cita.observaciones,
            ),

          const SizedBox(height: 8),

          // Materiales
          if (cita.orden.materiales != null &&
              cita.orden.materiales!.isNotEmpty)
            _buildInfoCard(
              icon: Icons.inventory_2,
              title: "Materiales",
              content: cita.orden.materiales!
                  .map((m) => "- ${m.nombre} (${m.cantidad})")
                  .join("\n"),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFC20000)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$title:",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
                Text(
                  content,
                  style: const TextStyle(color: Color(0xFF666666)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
