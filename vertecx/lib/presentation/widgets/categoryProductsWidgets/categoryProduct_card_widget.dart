import 'package:flutter/material.dart';
import 'package:vertecx/data/models/categoryProducts/categoryProducts_model.dart';
import 'package:vertecx/presentation/animations/animated_status_chip.dart';
import '../../helpers/app_dialogs.dart';

class CategoryCard extends StatelessWidget {
  final CategoryProduct category;
  final VoidCallback? onToggleStatus;

  const CategoryCard({super.key, required this.category, this.onToggleStatus});

  Color _getStatusBgColor(CategoryStatus status) {
    return status == CategoryStatus.activo
        ? const Color(0xFFD2F5D3)
        : const Color(0xABFF8888);
  }

  Color _getStatusTextColor(CategoryStatus status) {
    return status == CategoryStatus.activo
        ? const Color(0xFF168700)
        : const Color(0xFF870000);
  }

  @override
  Widget build(BuildContext context) {
    final statusBgColor = _getStatusBgColor(category.estado);
    final statusTextColor = _getStatusTextColor(category.estado);

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF4F4F4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono
              // Icono
              (category.imagenPath != null &&
                      category.imagenPath!.startsWith('http'))
                  ? Image.network(
                      category.imagenPath!,
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.category,
                        size: 40,
                        color: Colors.grey,
                      ),
                    )
                  : Image.asset(
                      'assets/icons/tag.png',
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.category,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),

              const SizedBox(width: 8),

              // ID + Nombre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ID: ${category.id}",
                      style: const TextStyle(
                        fontSize: 17,
                        color: Color(0xFF797979),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              // Chip de estado animado
              AnimatedStatusChip(
                label: category.statusString,
                bgColor: statusBgColor,
                textColor: statusTextColor,
                onPressed: () {
                  if (onToggleStatus == null) return;
                  AppDialogs.showConfirmChangeStatus(
                    context: context,
                    title: "Confirmar cambio",
                    message: category.estado == CategoryStatus.activo
                        ? "¿Quieres marcar la categoría '${category.nombre}' como INACTIVA?"
                        : "¿Quieres marcar la categoría '${category.nombre}' como ACTIVA?",
                    onConfirm: () {
                      onToggleStatus!();
                      AppDialogs.showSuccessMessage(
                        context,
                        "Estado de '${category.nombre}' cambiado correctamente",
                      );
                    },
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Descripción
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              category.descripcion?.isNotEmpty == true
                  ? category.descripcion!
                  : "No hay descripción",
              style: const TextStyle(fontSize: 15, color: Color(0xFF312C2C)),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
