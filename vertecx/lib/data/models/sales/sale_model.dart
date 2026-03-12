import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../clients/customer_model.dart';
import 'sale_item_model.dart';
import 'sale_payment_model.dart';

enum SaleStatus { pending, completed, cancelled, unknown }

class SaleModel {
  final int saleId;
  final String saleCode;
  final DateTime saleDate;
  final int customerId;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String? paymentMethod;
  final String currency;
  final String status;
  final String paymentStatus;
  final double paidAmount;
  final String? createdBy;
  final String? createdDate;
  final String? updatedDate;
  final String? notes;
  final CustomerModel? customer;
  final List<SaleItemModel> items;
  final List<SalePaymentModel> payments;

  SaleModel({
    required this.saleId,
    required this.saleCode,
    required this.saleDate,
    required this.customerId,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    this.paymentMethod,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    this.paidAmount = 0.0,
    this.createdBy,
    this.createdDate,
    this.updatedDate,
    this.notes,
    this.customer,
    this.items = const [],
    this.payments = const [],
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    var itemsList = <SaleItemModel>[];
    if (json['salesdetail'] != null && json['salesdetail'] is List) {
      itemsList = (json['salesdetail'] as List)
          .map((i) => SaleItemModel.fromJson(i))
          .toList();
    }

    var paymentsList = <SalePaymentModel>[];
    if (json['payments'] != null && json['payments'] is List) {
      paymentsList = (json['payments'] as List)
          .map((p) => SalePaymentModel.fromJson(p))
          .toList();
    }

    return SaleModel(
      saleId: _asInt(json['saleid']),
      saleCode: json['salecode']?.toString() ?? '',
      saleDate: DateTime.tryParse(json['saledate']?.toString() ?? '') ?? DateTime.now(),
      customerId: _asInt(json['customerid']),
      subtotal: _asDouble(json['subtotal']),
      taxAmount: _asDouble(json['taxamount']),
      discountAmount: _asDouble(json['discountamount']),
      totalAmount: _asDouble(json['totalamount']),
      paymentMethod: json['paymentmethod']?.toString(),
      currency: json['currency']?.toString() ?? 'COP',
      status: json['salestatus']?.toString() ?? 'Pending',
      paymentStatus: json['paymentstatus']?.toString() ?? 'Pending',
      paidAmount: _asDouble(json['paidamount']),
      createdBy: json['createdby']?.toString(),
      createdDate: json['createddate']?.toString(),
      updatedDate: json['updateddate']?.toString(),
      notes: json['notes']?.toString(),
      customer: json['customer'] != null ? CustomerModel.fromJson(json['customer']) : null,
      items: itemsList,
      payments: paymentsList,
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

  String get formattedTotal {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(totalAmount);
  }

  String get formattedPrice => formattedTotal;

  String get formattedDate => DateFormat('dd/MM/yyyy').format(saleDate);

  double get pendingAmount => totalAmount - paidAmount;

  String get formattedPaidAmount {
    final formatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    return formatter.format(paidAmount);
  }

  String get formattedPendingAmount {
    final formatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    return formatter.format(pendingAmount);
  }

  String get formattedSubtotal {
    final formatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    return formatter.format(subtotal);
  }

  String get formattedTaxAmount {
    final formatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    return formatter.format(taxAmount);
  }

  String get id => saleCode.isNotEmpty ? saleCode : saleId.toString();

  String get clientName => customer?.displayName ?? "Cliente #$customerId";

  String get statusString => status;

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'finalizado':
        return Colors.green;
      case 'pending':
      case 'pendiente':
        return Colors.orange;
      case 'cancelled':
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color get paymentStatusColor {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
      case 'pagado':
        return Colors.green;
      case 'pending':
      case 'pendiente':
        return Colors.orange;
      case 'overdue':
      case 'vencido':
      case 'cancelled':
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

