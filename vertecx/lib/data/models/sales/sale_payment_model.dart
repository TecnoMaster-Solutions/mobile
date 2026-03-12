import 'package:intl/intl.dart';

class SalePaymentModel {
  final int paymentId;
  final double amount;
  final String? paymentMethod;
  final String? reference;
  final String? invoiceUrl;
  final DateTime createdAt;

  SalePaymentModel({
    required this.paymentId,
    required this.amount,
    this.paymentMethod,
    this.reference,
    this.invoiceUrl,
    required this.createdAt,
  });

  factory SalePaymentModel.fromJson(Map<String, dynamic> json) {
    return SalePaymentModel(
      paymentId: _asInt(json['paymentid']),
      amount: _asDouble(json['amount']),
      paymentMethod: json['paymentmethod']?.toString(),
      reference: json['reference']?.toString(),
      invoiceUrl: json['invoiceurl']?.toString(),
      createdAt: DateTime.tryParse(json['createdat']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  String get formattedAmount {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String get formattedDate => DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
}
