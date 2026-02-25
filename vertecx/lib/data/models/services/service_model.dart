import 'package:flutter/material.dart';

class ServiceModel {
  final int id;
  final String name;
  final String description;
  final String image;
  final int typeId;
  final String? typeName;
  final int stateId;
  final String? stateName;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.typeId,
    required this.typeName,
    required this.stateId,
    required this.stateName,
  });

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static String _asString(dynamic v) => (v ?? '').toString();

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: _asInt(json['serviceid'] ?? json['id']),
      name: _asString(json['name']).trim(),
      description: _asString(json['description']).trim(),
      image: _asString(json['image']).trim(),
      typeId: _asInt(json['typeofserviceid']),
      typeName: json['typeofservicename']?.toString(),
      stateId: _asInt(json['stateid']),
      stateName: json['statename']?.toString(),
    );
  }

  Color get typeColor {
    final t = (typeName ?? '').toLowerCase();
    if (t.contains('instal')) return const Color(0xffC48600);
    if (t.contains('prevent')) return Colors.blue;
    if (t.contains('correct')) return const Color(0xffB20000);
    if (t.contains('manten')) return const Color(0xffB20000);
    return const Color(0xff7A7A7A);
  }
}

class ServiceTypeModel {
  final int id;
  final String name;

  ServiceTypeModel({required this.id, required this.name});

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) {
    return ServiceTypeModel(
      id: _asInt(json['typeofserviceid'] ?? json['id']),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class ServiceStateModel {
  final int id;
  final String name;
  final String? description;

  ServiceStateModel({required this.id, required this.name, this.description});

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  factory ServiceStateModel.fromJson(Map<String, dynamic> json) {
    return ServiceStateModel(
      id: _asInt(json['stateid'] ?? json['id']),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
    );
  }
}
