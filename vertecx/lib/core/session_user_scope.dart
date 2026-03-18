import 'dart:convert';

import 'package:vertecx/core/api_config.dart';
import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/core/session_context.dart';

class SessionUserScope {
  final int? userId;
  final String roleName;
  final int? customerId;
  final int? technicianId;

  const SessionUserScope({
    required this.userId,
    required this.roleName,
    required this.customerId,
    required this.technicianId,
  });

  bool get isClientRole {
    final role = _normalizeRole(roleName);
    return role == 'cliente' || role == 'client' || role == 'customer';
  }

  bool get isTechnicianRole {
    final role = _normalizeRole(roleName);
    return role == 'tecnico' || role == 'technician' || role == 'technical';
  }

  static String _normalizeRole(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }
}

class SessionUserScopeResolver {
  const SessionUserScopeResolver._();

  static Future<SessionUserScope> resolve() async {
    await SessionContext.ensureHydrated();

    final cachedRole = SessionContext.roleName ?? '';
    final needsCustomer =
        SessionContext.isClientRole && SessionContext.customerId == null;
    final needsTechnician =
        SessionContext.isTechnicianRole && SessionContext.technicianId == null;
    final hasCachedUser = SessionContext.userId != null && cachedRole.isNotEmpty;

    if (hasCachedUser && !needsCustomer && !needsTechnician) {
      return SessionUserScope(
        userId: SessionContext.userId,
        roleName: cachedRole,
        customerId: SessionContext.customerId,
        technicianId: SessionContext.technicianId,
      );
    }

    final meUri = Uri.parse('${ApiConfig.baseUrl}/auth/me');
    final meResponse = await ApiHttp.get(
      meUri,
      headers: const {'Accept': 'application/json'},
    );

    if (meResponse.statusCode != 200 && meResponse.statusCode != 201) {
      throw Exception('No se pudo obtener la sesion del usuario');
    }

    final meBody = _asMap(jsonDecode(meResponse.body));
    final userId = _toInt(meBody['userid']);
    final roleName = _toStr(meBody['rolename']);
    final rawPermissions = meBody['permissions'];
    if (rawPermissions is List) {
      SessionContext.permissions = rawPermissions.map((e) => e.toString()).toList();
    }

    int? customerId = SessionContext.customerId;
    int? technicianId = SessionContext.technicianId;

    if (userId != null) {
      final userUri = Uri.parse('${ApiConfig.baseUrl}/users/$userId');
      final userResponse = await ApiHttp.get(
        userUri,
        headers: const {'Accept': 'application/json'},
      );

      if (userResponse.statusCode == 200 || userResponse.statusCode == 201) {
        final userBody = _asMap(jsonDecode(userResponse.body));
        final data = _asMap(userBody['data']);
        customerId = _firstId(data['customers'], 'customerid') ?? customerId;
        technicianId = _firstId(data['technicians'], 'technicianid') ?? technicianId;
      }
    }

    if (userId != null && roleName.isNotEmpty) {
      SessionContext.setUser(
        userId: userId,
        roleName: roleName,
        customerId: customerId,
        technicianId: technicianId,
      );
    }

    return SessionUserScope(
      userId: userId,
      roleName: roleName,
      customerId: customerId,
      technicianId: technicianId,
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  static String _toStr(dynamic value) => value?.toString().trim() ?? '';

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static int? _firstId(dynamic rawList, String key) {
    if (rawList is! List) return null;
    for (final item in rawList) {
      final map = _asMap(item);
      final id = _toInt(map[key] ?? map['id']);
      if (id != null) return id;
    }
    return null;
  }
}
