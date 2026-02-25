import 'package:flutter/material.dart';
import 'package:vertecx/data/models/request/request_model.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.data,
    this.onTap,
  });

  final ServiceRequestModel data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String stateLabel = _stateLabel(data);
    final (Color, Color) colors = _stateColors(stateLabel);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 0,
        color: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
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
                    '${data.serviceRequestId}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.$1,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      stateLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.$2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                data.serviceType,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Servicio: ${_serviceName(data)}',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Cliente: ${_customerName(data)}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Fecha creacion: ${_fmt(data.createdAt)}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              if (data.scheduledAt != null)
                Text(
                  'Programada: ${_fmt(data.scheduledAt!)}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              Text(
                'Estado registrado: $stateLabel',
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

  String _serviceName(ServiceRequestModel d) {
    final dynamic v = d.service?['name'] ?? d.service?['nombre'] ?? '';
    final String s = v.toString().trim();
    return s.isEmpty ? 'Sin definir' : s;
  }

  String _customerName(ServiceRequestModel d) {
    final Map<String, dynamic>? c = d.customer;
    if (c == null) {
      return 'Sin definir';
    }

    Map<String, dynamic>? asMap(dynamic v) {
      if (v is Map) {
        return Map<String, dynamic>.from(v as Map);
      }
      return null;
    }

    final Map<String, dynamic>? u = asMap(c['users']);
    final String name = (u?['name'] ??
            u?['firstname'] ??
            u?['firstName'] ??
            c['name'] ??
            c['firstname'] ??
            c['firstName'] ??
            '')
        .toString()
        .trim();
    final String last = (u?['lastname'] ??
            u?['lastName'] ??
            c['lastname'] ??
            c['lastName'] ??
            '')
        .toString()
        .trim();

    final String full = <String>[name, last]
        .where((e) => e.isNotEmpty)
        .join(' ')
        .trim();
    return full.isEmpty ? 'Sin definir' : full;
  }

  String _stateLabel(ServiceRequestModel d) {
    final dynamic v = d.state?['name'] ?? d.state?['nombre'] ?? '';
    final String s = v.toString().trim();
    return s.isEmpty ? 'Estado ${d.stateId}' : s;
  }

  (Color, Color) _stateColors(String label) {
    final String l = label.toLowerCase();
    if (l.contains('pend')) {
      return (const Color(0xFFFFF4DD), const Color(0xFF9B6A00));
    }
    if (l.contains('proceso') || l.contains('en proc')) {
      return (const Color(0xFFE6F0FF), const Color(0xFF0B57D0));
    }
    if (l.contains('activo')) {
      return (const Color(0xFFE9F7EC), const Color(0xFF2E7D32));
    }
    if (l.contains('compl') || l.contains('final')) {
      return (const Color(0xFFE9F7EC), const Color(0xFF2E7D32));
    }
    if (l.contains('cancel')) {
      return (const Color(0xFFFFE6E6), const Color(0xFFB00020));
    }
    return (const Color(0xFFF1F3F4), const Color(0xFF5F6368));
  }

  String _fmt(DateTime d) {
    final String dd = d.day.toString().padLeft(2, '0');
    final String mm = d.month.toString().padLeft(2, '0');
    final String yy = d.year.toString();
    return '$dd/$mm/$yy';
  }
}
