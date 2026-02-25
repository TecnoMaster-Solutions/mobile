class ServiceRequestModel {
  final int serviceRequestId;
  final DateTime? scheduledAt;
  final DateTime? scheduledEndAt;
  final String serviceType;
  final String description;
  final DateTime createdAt;
  final int stateId;
  final int serviceId;
  final int clientId;
  final String? direccion;
  final Map<String, dynamic>? state;
  final Map<String, dynamic>? service;
  final Map<String, dynamic>? customer;

  ServiceRequestModel({
    required this.serviceRequestId,
    required this.scheduledAt,
    this.scheduledEndAt,
    required this.serviceType,
    required this.description,
    required this.createdAt,
    required this.stateId,
    required this.serviceId,
    required this.clientId,
    required this.direccion,
    required this.state,
    required this.service,
    required this.customer,
  });

  String get customerName {
    final c = customer;
    if (c == null) return 'Sin definir';

    final u = c['users'];
    if (u is Map) {
      final name = (u['name'] ?? '').toString().trim();
      final last = (u['lastname'] ?? '').toString().trim();
      final full = [name, last].where((s) => s.isNotEmpty).join(' ');
      if (full.isNotEmpty) return full;
    }

    final n = (c['name'] ?? c['fullname'] ?? c['fullName'])?.toString().trim();
    if (n != null && n.isNotEmpty) return n;

    final fn = (c['firstname'] ?? c['firstName'])?.toString().trim();
    final ln = (c['lastname'] ?? c['lastName'])?.toString().trim();
    final joined = [fn, ln].where((s) => s != null && s.isNotEmpty).join(' ');
    return joined.isNotEmpty ? joined : 'Sin definir';
  }

  factory ServiceRequestModel.fromJson(Map<String, dynamic> j) {
    Map<String, dynamic>? asMap(dynamic v) =>
        v is Map<String, dynamic> ? v : null;

    final rawId = j['serviceRequestId'] ?? j['servicerequestid'];
    final rawCreated = j['createdAt'] ?? j['createdat'];
    final rawScheduled = j['scheduledAt'] ?? j['scheduledat'];
    final rawStateId = j['stateId'] ?? j['stateid'];
    final rawServiceId = j['serviceId'] ?? j['serviceid'];
    final rawClientId = j['clientId'] ?? j['clientid'];
    final rawScheduledEnd = j['scheduledEndAt'] ?? j['scheduledendat'];
    final rawDireccion = j['direccion'] ?? j['address'] ?? j['location'];

    return ServiceRequestModel(
      serviceRequestId: rawId is int ? rawId : int.parse(rawId.toString()),
      scheduledAt: rawScheduled != null
          ? DateTime.parse(rawScheduled.toString())
          : null,
      serviceType: (j['serviceType'] ?? j['servicetype'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      createdAt: DateTime.parse(rawCreated.toString()),
      stateId: rawStateId is int
          ? rawStateId
          : int.parse(rawStateId.toString()),
      serviceId: rawServiceId is int
          ? rawServiceId
          : int.parse(rawServiceId.toString()),
      clientId: rawClientId is int
          ? rawClientId
          : int.parse(rawClientId.toString()),
      direccion: rawDireccion?.toString(),
      scheduledEndAt: rawScheduledEnd != null
          ? DateTime.parse(rawScheduledEnd.toString())
          : null,
      state: asMap(j['state']),
      service: asMap(j['service']),
      customer:
          asMap(j['customer']) ??
          asMap(j['client']) ??
          asMap(j['customerData']) ??
          asMap(j['clientData']),
    );
  }
}
