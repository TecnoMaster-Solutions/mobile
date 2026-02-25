import 'package:flutter/material.dart';

class ServiceRequestModel {
  final int serviceRequestId;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? scheduledEndAt;
  final String serviceType;
  final String direccion;
  final String description;
  final int? stateId;
  final int? serviceId;
  final int? clientId;
  final Map<String, dynamic>? state;
  final Map<String, dynamic>? service;
  final Map<String, dynamic>? customer;

  const ServiceRequestModel({
    required this.serviceRequestId,
    required this.createdAt,
    required this.serviceType,
    required this.direccion,
    required this.description,
    this.scheduledAt,
    this.scheduledEndAt,
    this.stateId,
    this.serviceId,
    this.clientId,
    this.state,
    this.service,
    this.customer,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v is String && v.isNotEmpty) {
        return DateTime.tryParse(v);
      }
      return null;
    }

    return ServiceRequestModel(
      serviceRequestId: json['serviceRequestId'] as int,
      serviceType: (json['serviceType'] ?? '').toString(),
      direccion: (json['direccion'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
      scheduledAt: parseDate(json['scheduledAt']),
      scheduledEndAt: parseDate(json['scheduledEndAt']),
      stateId: json['stateId'] as int?,
      serviceId: json['serviceId'] as int?,
      clientId: json['clientId'] as int?,
      state: json['state'] is Map
          ? Map<String, dynamic>.from(json['state'] as Map)
          : null,
      service: json['service'] is Map
          ? Map<String, dynamic>.from(json['service'] as Map)
          : null,
      customer: json['customer'] is Map
          ? Map<String, dynamic>.from(json['customer'] as Map)
          : null,
    );
  }

  static List<ServiceRequestModel> listFromJson(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ServiceRequestModel.fromJson)
          .toList();
    }
    return <ServiceRequestModel>[];
  }
}
