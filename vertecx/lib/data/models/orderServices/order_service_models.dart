import 'package:vertecx/data/models/orderServices/order_service_history_model.dart';

enum OrderServiceStatus { pendiente, enProgreso, completada, anulada }

class OrderService {
  final int id;
  final String titulo;
  final String tecnico;
  final String cliente;
  final DateTime fechaCreacion;
  final OrderServiceStatus estado;
  final String estadoLabel;
  final int total;
  final DateTime? startAt;
  final DateTime? endAt;
  final List<String> technicians;
  final List<Map<String, dynamic>> products;
  final String description;
  final Map<String, dynamic>? client;
  final Map<String, dynamic>? state;
  final String? serviceType;
  final List<OrderServiceHistoryEntry> history;

  const OrderService({
    required this.id,
    required this.titulo,
    required this.tecnico,
    required this.cliente,
    required this.fechaCreacion,
    required this.estado,
    this.estadoLabel = '',
    this.total = 0,
    this.startAt,
    this.endAt,
    this.technicians = const [],
    this.products = const [],
    this.description = '',
    this.client,
    this.state,
    this.serviceType,
    required this.history,
  });

  String get techniciansLabel {
    if (technicians.isEmpty) return 'Sin asignar';
    return technicians.join(', ');
  }

  factory OrderService.fromJson(Map<String, dynamic> json) {
    final idRaw =
        json['ordersservicesid'] ?? json['ordersServiceId'] ?? json['orderId'];
    final createdAtRaw = json['createdat'] ?? json['createdAt'];
    final stateName = (json['state']?['name'] ?? json['state']?['nombre'] ?? '')
        .toString()
        .trim();
    final description = (json['description'] ?? '').toString();
    final totalRaw = json['total'];
    final viaticosRaw = json['viaticos'] ?? json['viaticos'];
    final techniciansRaw = (json['technicians'] as List<dynamic>?) ?? [];
    final clientRaw = _asMap(json['client']);
    final stateRaw = _asMap(json['state']);

    final int totalBase = totalRaw is num ? totalRaw.toInt() : 0;
    final int viaticos = viaticosRaw is num ? viaticosRaw.toInt() : 0;
    final int total = totalBase + viaticos;

    String titulo;
    String? serviceType;
    final servicesRaw = (json['services'] as List<dynamic>?) ?? [];
    if (servicesRaw.isNotEmpty) {
      final first = servicesRaw.first;
      if (first is Map<String, dynamic>) {
        final service = _asMap(first['service']);
        final serviceName = (service?['name'] ?? '').toString().trim();
        final typeName = (service?['typeofservice']?['name'] ?? '')
            .toString()
            .trim();
        if (typeName.isNotEmpty) {
          serviceType = typeName;
        }
        if (serviceName.isNotEmpty) {
          titulo = serviceName;
        } else if (description.isNotEmpty) {
          titulo = description;
        } else {
          titulo = 'Orden #${_parseInt(idRaw)}';
        }
      } else {
        titulo =
            description.isNotEmpty ? description : 'Orden #${_parseInt(idRaw)}';
      }
    } else {
      titulo =
          description.isNotEmpty ? description : 'Orden #${_parseInt(idRaw)}';
    }

    return OrderService(
      id: _parseInt(idRaw),
      titulo: titulo,
      tecnico: _firstTechnicianName(techniciansRaw),
      cliente: _clientName(clientRaw),
      fechaCreacion: DateTime.parse(
        createdAtRaw?.toString() ?? DateTime.now().toIso8601String(),
      ),
      estado: _statusFromState(stateName),
      estadoLabel: stateName.isEmpty ? 'Estado desconocido' : stateName,
      total: total,
      startAt: _parseDateTime(json['fechainicio'], json['horainicio']),
      endAt: _parseDateTime(json['fechafin'], json['horafin']),
      technicians: techniciansRaw
          .whereType<Map<String, dynamic>>()
          .map(_technicianName)
          .where((s) => s.isNotEmpty)
          .toList(),
      products: ((json['products'] as List<dynamic>?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList(),
      description: description,
      client: clientRaw,
      state: stateRaw,
      serviceType: serviceType,
      history: ((json['history'] as List<dynamic>?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(OrderServiceHistoryEntry.fromJson)
          .toList(),
    );
  }

  static OrderServiceStatus _statusFromState(String stateName) {
    final lower = stateName.toLowerCase();
    if (lower.contains('pend')) return OrderServiceStatus.pendiente;
    if (lower.contains('prog') ||
        lower.contains('progreso') ||
        lower.contains('en proceso')) {
      return OrderServiceStatus.enProgreso;
    }
    if (lower.contains('compl') ||
        lower.contains('finaliz') ||
        lower.contains('exit')) {
      return OrderServiceStatus.completada;
    }
    if (lower.contains('cancel') || lower.contains('anul')) {
      return OrderServiceStatus.anulada;
    }
    if (lower.contains('activo')) return OrderServiceStatus.enProgreso;
    return OrderServiceStatus.pendiente;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    return value is Map<String, dynamic> ? value : null;
  }

  static String _firstTechnicianName(List<dynamic> list) {
    for (final item in list.whereType<Map<String, dynamic>>()) {
      final name = _technicianName(item);
      if (name.isNotEmpty) return name;
    }
    return '';
  }

  static String _technicianName(Map<String, dynamic> raw) {
    final user = _asMap(raw['users']);
    final name = _normalizeName(user);
    if (name.isNotEmpty) return name;
    final fallback = (raw['name'] ?? raw['fullname'])?.toString() ?? '';
    return fallback.trim();
  }

  static String _clientName(Map<String, dynamic>? raw) {
    final user = _asMap(raw?['users']);
    final name = _normalizeName(user);
    if (name.isNotEmpty) return name;
    final fallback =
        (raw?['customercity'] ?? raw?['customername'] ?? raw?['name'])
            ?.toString() ??
        '';
    return fallback.trim().isEmpty ? 'Sin definir' : fallback.trim();
  }

  static String _normalizeName(Map<String, dynamic>? user) {
    if (user == null) return '';
    final first =
        (user['name'] ?? user['firstname'] ?? user['firstName'])
            ?.toString()
            .trim() ??
        '';
    final last =
        (user['lastname'] ?? user['lastName'])?.toString().trim() ?? '';
    final joined = [first, last].where((s) => s.isNotEmpty).join(' ');
    return joined;
  }

  static DateTime? _parseDateTime(dynamic date, dynamic time) {
    if (date == null) return null;
    final datePart = date.toString().trim();
    if (datePart.isEmpty) return null;
    final timePart = (time ?? '').toString().trim();
    final value = timePart.isEmpty ? datePart : '$datePart $timePart';
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }
}
