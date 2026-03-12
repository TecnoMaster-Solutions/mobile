class QuoteModel {
  final int id;
  final String serviceType;
  final String status;
  final String customerName;
  final String technicianName;
  final String observation;
  final double total;
  final DateTime? createdAt;
  final int detailsCount;

  const QuoteModel({
    required this.id,
    required this.serviceType,
    required this.status,
    required this.customerName,
    required this.technicianName,
    required this.observation,
    required this.total,
    required this.createdAt,
    required this.detailsCount,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    String readText(dynamic value) => value?.toString().trim() ?? '';

    Map<String, dynamic> readMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.map((key, val) => MapEntry(key.toString(), val));
      }
      return <String, dynamic>{};
    }

    String fullName(Map<String, dynamic> map) {
      final String name = readText(map['name']);
      final String lastname = readText(map['lastname']);
      return <String>[name, lastname]
          .where((part) => part.isNotEmpty)
          .join(' ')
          .trim();
    }

    final Map<String, dynamic> state = readMap(json['state']);
    final Map<String, dynamic> customer = readMap(json['customer']);
    final Map<String, dynamic> technician = readMap(json['technician']);
    final Map<String, dynamic> customerUser = readMap(customer['users']);
    final Map<String, dynamic> technicianUser = readMap(technician['users']);
    final List details = json['details'] is List ? json['details'] as List : const [];

    final dynamic totalRaw = json['total'];
    final double total = totalRaw is num
        ? totalRaw.toDouble()
        : double.tryParse(readText(totalRaw)) ?? 0;

    final String customerName = fullName(customerUser);
    final String technicianName = fullName(technicianUser);

    return QuoteModel(
      id: (json['quotesid'] as num?)?.toInt() ?? 0,
      serviceType: readText(json['servicetype']).isNotEmpty
          ? readText(json['servicetype'])
          : 'Sin tipo',
      status: readText(state['name']).isNotEmpty
          ? readText(state['name'])
          : 'Sin estado',
      customerName: customerName.isNotEmpty ? customerName : 'Sin cliente',
      technicianName:
          technicianName.isNotEmpty ? technicianName : 'Sin tecnico',
      observation: readText(json['observation']),
      total: total,
      createdAt: DateTime.tryParse(readText(json['createdat'])),
      detailsCount: details.length,
    );
  }
}
