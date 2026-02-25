class Sales {
  final int month;
  final double amount;

  Sales({required this.month, required this.amount});

  factory Sales.fromJson(Map<String, dynamic> json) {
    return Sales(
      month: parseDashboardMonth(json['month'] ?? json['mes']),
      amount: parseDashboardDouble(json['total'] ?? json['amount']),
    );
  }
}

class Clients {
  final int month;
  final double amount;

  Clients({required this.month, required this.amount});

  factory Clients.fromJson(Map<String, dynamic> json) {
    return Clients(
      month: parseDashboardMonth(json['month'] ?? json['mes']),
      amount: parseDashboardDouble(json['total'] ?? json['amount']),
    );
  }
}

class Shopping {
  final int month;
  final double amount;

  Shopping({required this.month, required this.amount});

  factory Shopping.fromJson(Map<String, dynamic> json) {
    return Shopping(
      month: parseDashboardMonth(json['month'] ?? json['mes']),
      amount: parseDashboardDouble(json['total'] ?? json['amount']),
    );
  }
}

int parseDashboardMonth(dynamic monthValue) {
  if (monthValue is int) return monthValue;
  if (monthValue is num) return monthValue.toInt();

  if (monthValue is String) {
    final key = monthValue.trim().toLowerCase();
    const months = {
      'jan': 1,
      'ene': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'abr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'ago': 8,
      'sep': 9,
      'set': 9,
      'sept': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
      'dic': 12,
    };

    if (months.containsKey(key)) return months[key]!;

    if (key.length >= 3) {
      final shortKey = key.substring(0, 3);
      if (months.containsKey(shortKey)) return months[shortKey]!;
    }
  }

  return 0;
}

double parseDashboardDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) {
    final sanitized = value.replaceAll(',', '').trim();
    return double.tryParse(sanitized) ?? 0.0;
  }
  return 0.0;
}

int parseDashboardInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value.trim()) ?? 0;
  }
  return 0;
}

