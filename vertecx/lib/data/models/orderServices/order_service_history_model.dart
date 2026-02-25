class OrderServiceHistoryEntry {
  final int id;
  final String action;
  final String actionLabel;
  final String? description;
  final DateTime createdAt;

  const OrderServiceHistoryEntry({
    required this.id,
    required this.action,
    required this.actionLabel,
    this.description,
    required this.createdAt,
  });

  factory OrderServiceHistoryEntry.fromJson(Map<String, dynamic> json) {
    final rawId =
        json['ordersserviceshistoryid'] ?? json['historyid'] ?? json['id'];
    final createdAtRaw = json['createdat'] ?? json['createdAt'];
    final action = (json['action'] ?? '').toString();
    final actionLabel = (json['actionlabel'] ?? '').toString();
    final description = (json['description'] ?? json['detalle'])?.toString();

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return OrderServiceHistoryEntry(
      id: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0,
      action: action,
      actionLabel: actionLabel.isNotEmpty ? actionLabel : action,
      description: description?.trim().isEmpty == true
          ? null
          : description?.trim(),
      createdAt: parseDate(createdAtRaw),
    );
  }
}
