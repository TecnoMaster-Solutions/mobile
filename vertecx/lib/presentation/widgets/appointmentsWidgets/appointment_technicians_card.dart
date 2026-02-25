import 'package:flutter/material.dart';
import 'package:vertecx/data/models/appointments/appointment_model.dart';

class AppointmentTechniciansCard extends StatelessWidget {
  final List<Technician> tecnicos;

  const AppointmentTechniciansCard({super.key, required this.tecnicos});

  @override
  Widget build(BuildContext context) {
    if (tecnicos.isEmpty) {
      return const SizedBox();
    }

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
            "Técnicos",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 12),

          // 🔹 Grid adaptable con Wrap
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: tecnicos.map(
              (tec) {
                return Container(
                  width: MediaQuery.of(context).size.width / 2 - 40,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tec.nombre,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tec.titulo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }
}
