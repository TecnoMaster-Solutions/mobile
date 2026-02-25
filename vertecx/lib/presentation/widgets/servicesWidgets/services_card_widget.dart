import 'package:flutter/material.dart';
import 'package:vertecx/data/models/services/service_model.dart';

class ServiceCardWidget extends StatelessWidget {
  final ServiceModel service;

  const ServiceCardWidget({super.key, required this.service});

  bool get isActive {
    final s = (service.stateName ?? '').toLowerCase().trim();
    if (s == 'activo' || s == 'active') return true;
    if (service.stateId == 1) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: service.image.isNotEmpty
                  ? Image.network(
                      service.image,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackImg(),
                    )
                  : _fallbackImg(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ID: ${service.id}",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: service.typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          service.typeName ?? "Tipo",
                          style: TextStyle(
                            color: service.typeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xffD2F5D3) : const Color(0xffFF8888),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isActive ? "Activo" : "Inactivo",
                          style: TextStyle(
                            color: isActive ? const Color(0xff168700) : const Color(0xff870000),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackImg() {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xffEFEFEF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.miscellaneous_services, color: Color(0xffB20000)),
    );
  }
}
