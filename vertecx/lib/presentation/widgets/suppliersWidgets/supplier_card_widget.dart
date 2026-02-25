import 'package:flutter/material.dart';
import 'package:vertecx/data/models/suppliers/supplier_model.dart';

class SupplierCardWidget extends StatelessWidget {
  const SupplierCardWidget({
    super.key,
    required this.supplier,
    required this.onToggleStatus,
    this.isUpdating = false,
  });

  final SupplierModel supplier;
  final VoidCallback onToggleStatus;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final isActive = supplier.status == SupplierStatus.active;
    final chipBg = isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final chipColor = isActive ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14000000),
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
              _SupplierAvatar(imageUrl: supplier.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            supplier.statusString,
                            style: TextStyle(
                              color: chipColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFFFEBEE)
                                : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFFEF9A9A)
                                  : const Color(0xFFA5D6A7),
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: isUpdating ? null : onToggleStatus,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isUpdating)
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else
                                    Icon(
                                      isActive ? Icons.block : Icons.check,
                                      size: 15,
                                      color: isActive
                                          ? const Color(0xFFC62828)
                                          : const Color(0xFF2E7D32),
                                    ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isActive ? 'Inactivar' : 'Activar',
                                    style: TextStyle(
                                      color: isActive
                                          ? const Color(0xFFC62828)
                                          : const Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _InfoRow(label: 'ID', value: supplier.id.toString()),
          _InfoRow(label: 'NIT', value: supplier.nit),
          _InfoRow(label: 'Contacto', value: supplier.contactName),
          _InfoRow(label: 'Telefono', value: supplier.phone),
          _InfoRow(label: 'Email', value: supplier.email),
          if (supplier.address.isNotEmpty)
            _InfoRow(label: 'Direccion', value: supplier.address),
        ],
      ),
    );
  }
}

class _SupplierAvatar extends StatelessWidget {
  const _SupplierAvatar({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stackTrace) =>
                    const Icon(Icons.store, color: Color(0xFFB20000), size: 34),
              ),
            )
          : const Icon(Icons.store, color: Color(0xFFB20000), size: 34),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
