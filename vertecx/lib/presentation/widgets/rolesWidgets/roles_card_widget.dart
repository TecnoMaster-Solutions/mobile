import 'package:flutter/material.dart';
import 'package:vertecx/data/models/roles/role_model.dart';

class RoleCardWidget extends StatelessWidget {
  final RoleModel role;

  const RoleCardWidget({super.key, required this.role});

  bool get isActive => role.status == RoleStatus.activo;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "ID: ${role.id}",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xffD2F5D3) // verde suave
                    : const Color(0xffFF8888), // rojo suave
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isActive ? "Activo" : "Inactivo",
                style: TextStyle(
                  color: isActive
                      ? const Color(0xff168700)
                      : const Color(0xff870000),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
